USE Bibliotheque;

DELIMITER //

CREATE PROCEDURE GestionPrets(
    -- IN num_abonné INT,
    IN utilisateur_id INT,

    -- IN code_cat INT,
    IN contenu_id INT,

    -- IN type_contenu VARCHAR(50),
    IN type_contenu VARCHAR(50),

    -- Boolean pour savoir si l'utilisateur souhaite être en attente
    -- 1 : Oui / 2 : Non
    IN attente TINYINT,

    -- Lieu où l'utilisateur souhaite emprunter le contenu
    IN Lieu VARCHAR(50)

    -- Boolean pour savoir si l'utilisateur souhaite uniquement les exemplaires disponibles dans le lieu demandé
    -- 1 : Oui / 0 : Non
    IN lieu_demande_uniquement TINYINT
)

BEGIN
    DECLARE rendu_emprunt DATE;
    DECLARE code_barre_exemplaire INT;
    DECLARE somme INT;  
    DECLARE somme2 INT;

    -- Vérifier si l'abonné a été pénalisé 3 fois auquel cas on le banni
    IF (SELECT COUNT(penalite) FROM Historique WHERE Historique.penalite = 1 AND Historique.num_abonné_histo = utilisateur_id) > 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Vous avez été pénalisé 3 fois. Vous êtes banni."
    END IF;

    -- On enregistre dans une variable le code_barre de l'exemplaire disponible 
    SELECT Exemplaires.code_barre INTO code_barre_exemplaire
        FROM Exemplaires
        WHERE code_barre NOT IN (SELECT code_barre FROM Emprunt)
        AND Exemplaires.code_cat = contenu_id 
        AND etablissement = Lieu
        LIMIT 1;

    -- RENDU_EMPRUNT : On determine la durée de l'emprunt en fonction du type de contenu
    IF type_contenu = 'Livre' THEN
        SET rendu_emprunt = DATE_ADD(CURRENT_DATE, INTERVAL 15 DAY);
    ELSE
        SET rendu_emprunt = DATE_ADD(CURRENT_DATE, INTERVAL 7 DAY);
    END IF;

    -- SOMME : On calcule le nombre d exemplaires disponibles dans le lieu demande 
    SELECT COUNT(Exemplaires.code_barre) INTO somme
    FROM Exemplaires
    WHERE code_barre NOT IN (SELECT code_barre FROM Emprunt)
    AND Exemplaires.code_cat = contenu_id 
    AND etablissement = Lieu;

    -- SOMME2 : On calcule le nombre d'exemplaires disponibles dans tous les lieux 
    SELECT COUNT(Exemplaires.code_barre) INTO somme2
    FROM Exemplaires
    WHERE code_barre NOT IN (SELECT code_barre FROM Emprunt)
    AND Exemplaires.code_cat = contenu_id;


    -- Vérifier si des exemplaires du contenu sont disponibles, dans le lieu demandé
    IF somme > 0 THEN

        -- Effectuer l'emprunt
        INSERT INTO Emprunt
        VALUES (utilisateur_id, code_barre_exemplaire, CURRENT_DATE, rendu_emprunt, 0);

    -- Sinon, vérifier si des exemplaires du contenu sont disponibles, dans un autre lieu et si cela peut interesser notre client
    ELSE 
        IF somme2 = 0 AND NOT lieu_demande_uniquement THEN

            -- Aucun exemplaire disponible, demander à l'utilisateur s'il souhaite se mettre en attente
            IF attente = 1 THEN

                INSERT INTO Demande
                VALUES (utilisateur_id, contenu_id, CURRENT_DATE);

                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Aucun exemplaire disponible. Vous êtes en attente.';

            ELSE
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Aucun exemplaire disponible. Vous n êtes pas inscrit en attente.';
            END IF;
        ELSE
            SELECT etablissement FROM Exemplaires
            WHERE code_barre NOT IN (SELECT code_barre FROM Emprunt)
            AND (Exemplaires.code_cat = contenu_id);

            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'L exemplaire est disponible dans les etablissements ci-dessus:';
        END IF;
    END IF;
END //



DELIMITER ;
