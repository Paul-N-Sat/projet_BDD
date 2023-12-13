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
    DECLARE rendu_emprunt DATE;
    DECLARE code_barre_exemplaire INT;
    DECLARE somme INT;
    DECLARE somme2 INT;
    DECLARE nb_contenu_pas_emprunte INT;


    -- On calcule le nombre de contenu emprunter
    SELECT COUNT(Emprunt.code_barre) INTO nb_contenu_pas_emprunte
    FROM Emprunt
    JOIN Exemplaires ON Exemplaires.code_barre = Emprunt.code_barre 
    WHERE Emprunt.code_barre = Exemplaires.code_barre;

    -- On determine la durée de l'emprunt en fonction du type de contenu
    IF type_contenu = 'Livre' THEN
        SET rendu_emprunt = DATE_ADD(CURRENT_DATE, INTERVAL 15 DAY);
    ELSE
        SET rendu_emprunt = DATE_ADD(CURRENT_DATE, INTERVAL 7 DAY);
    END IF;

    -- On calcule le nombre d exemplaires disponibles dans le lieu demande 
    SELECT COUNT(Exemplaires.code_barre) INTO somme
    FROM Exemplaires
    WHERE ((SELECT COUNT(Emprunt.code_barre) FROM Emprunt JOIN Exemplaires ON Exemplaires.code_barre = Emprunt.code_barre WHERE Emprunt.code_barre = Exemplaires.code_barre) = 0) 
    AND code_catalogue = contenu_id 
    AND etablissement = Lieu;

    -- On calcule le nombre d'exemplaires disponibles dans tous les lieux 
    SELECT COUNT(Exemplaires.code_barre) INTO somme2
    FROM Exemplaires
    WHERE ((SELECT COUNT(Emprunt.code_barre) FROM Emprunt JOIN Exemplaires ON Exemplaires.code_barre = Emprunt.code_barre WHERE Emprunt.code_barre = Exemplaires.code_barre) = 0) 
    AND code_catalogue = contenu_id;

    -- On enregistre dans une variable le code_barre de l'exemplaire disponible 
    SELECT Exemplaires.code_barre INTO code_barre_exemplaire
        FROM Exemplaires
        WHERE ((SELECT COUNT(Emprunt.code_barre) FROM Emprunt JOIN Exemplaires ON Exemplaires.code_barre = Emprunt.code_barre WHERE Emprunt.code_barre = Exemplaires.code_barre) = 0) 
        AND code_catalogue = contenu_id 
        AND etablissement = Lieu
        LIMIT 1;

    -- Vérifier si des exemplaires du contenu sont disponibles, dans le lieu demandé
    IF somme > 0 THEN

        -- Effectuer l'emprunt
        INSERT INTO Emprunt
        VALUES (utilisateur_id, code_barre_exemplaire, CURRENT_DATE, rendu_emprunt, 0);


    -- Sinon, vérifier si des exemplaires du contenu sont disponibles, dans un autre lieu
    ELSEIF somme2 = 0 THEN

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
        WHERE (nb_contenu_pas_emprunte = 0) AND (code_catalogue = contenu_id);
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'L exemplaire est disponible dans les etablissements ci-dessus:';
    END IF;
END //

-- Le trigger permet de vérifier si l'utilisateur a déjà 5 prêts en cours 
CREATE TRIGGER trig_nombre_prets
BEFORE INSERT ON Emprunt
FOR EACH ROW
BEGIN
    DECLARE nb_prets INT;

    -- Vérifier le nombre de prêts actuels de l'utilisateur
    SELECT COUNT(code_barre) INTO nb_prets
    FROM Emprunt
    WHERE num_abonné = NEW.num_abonné;

    IF nb_prets >= 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Vous avez déjà 5 prêts en cours.';
    END IF;
END //


DELIMITER ;
