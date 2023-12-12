DELIMITER //

CREATE PROCEDURE GestionPrets(
    -- IN num_abonné INT,
    IN utilisateur_id INT,

    -- IN code_catalogue INT,
    IN contenu_id INT,

    -- IN type_contenu VARCHAR(50),
    IN type_contenu VARCHAR(50),

    -- Boolean pour savoir si l'utilisateur souhaite être en attente
    IN attente TINYINT,

    -- Lieu où l'utilisateur souhaite emprunter le contenu
    IN Lieu VARCHAR(50)
)

BEGIN
    DECLARE nb_prets INT;
    DECLARE rendu_emprunt DATE;

    -- On determine la durée de l'emprunt en fonction du type de contenu
    IF type_contenu = 'Livre' THEN
        SET rendu_emprunt = DATE_ADD(CURRENT_DATE, INTERVAL 15 DAY);
    ELSE
        SET rendu_emprunt = DATE_ADD(CURRENT_DATE, INTERVAL 7 DAY);
    END IF;

    -- Vérifier le nombre de prêts actuels de l'utilisateur
    SELECT COUNT(code_barre) INTO nb_prets
    FROM Emprunts
    WHERE utilisateur_id = num_abonné;

    IF nb_prets >= 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Vous avez déjà 5 prêts en cours.';
    ELSE
        -- Vérifier si des exemplaires du contenu sont disponibles
        IF EXISTS (
            SELECT code_barre
            FROM Exmplaires
            WHERE ((SELECT COUNT(code_barre) FROM Emprunts WHERE code_barre = Exemplaires.code_barre) = 0) AND code_catalogue = contenu_id
        ) THEN
            -- Vérifier si un exemplaire est disponible dans la ville de l'utilisateur
            IF (SELECT etablissement FROM Exemplaires WHERE (code_catalogue = contenu_id)) = Lieu THEN
                -- Effectuer l'emprunt
                INSERT INTO Emprunts
                VALUES (utilisateur_id, contenu_id, CURRENT_DATE, rendu_emprunt, 0);
            ELSE
                -- Signaler à l'utilisateur qu'aucun exemplaire les établissements qui propose le contenu
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Aucun exemplaire disponible dans le lieu demandé. Voici les lieux où le contenu est disponible :';
                SELECT etablissement FROM Exemplaires WHERE code_catalogue = contenu_id;
            END IF;

            -- Effectuer l'emprunt
            INSERT INTO Emprunts
            VALUES (utilisateur_id, contenu_id, CURRENT_DATE, rendu_emprunt, 0);

        ELSE
            -- Aucun exemplaire disponible, demander à l'utilisateur s'il souhaite se mettre en attente
            IF attente = 1 THEN
                INSERT INTO Demandes
                VALUES (utilisateur_id, contenu_id, CURRENT_DATE);
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Aucun exemplaire disponible. Vous êtes en attente.';
            ELSE
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Aucun exemplaire disponible. Vous n êtes pas inscrit en attente.';
            END IF;
        END IF;
    END IF;
END //

DELIMITER ;
