
DELIMITER //
CREATE PROCEDURE RenduContenu(IN abonne INT, IN code_barre_emprunt INT)
BEGIN
    DECLARE date_retour_emprunt_theorique DATE;
    DECLARE date_emprunt_emprunt DATE;

    -- DATE_RETOUR_EMPRUNT_THEORIQUE : On récupère la date de retour de l'emprunt
    SELECT date_retour INTO date_retour_emprunt_theorique 
    FROM Emprunt 
    WHERE num_abonné = abonne 
    AND code_barre = code_barre_emprunt;

    -- DATE_EMPRUNT_EMPRUNT : On récupère la date d'emprunt de l'emprunt
    SELECT date_emprunt INTO date_emprunt_emprunt
    FROM Emprunt
    WHERE num_abonné = abonne
    AND code_barre = code_barre_emprunt;

    -- Ajouter à la table Historique l'emprunt
    INSERT INTO Historique
    VALUES (abonne, code_barre_emprunt, date_emprunt_emprunt, CURRENT_DATE, 0)

    -- Vérifier si la date de retour est dépassée auquel cas on pénalise l'abonné
    IF date_retour_emprunt_theorique < CURRENT_DATE THEN
        UPDATE Abonnes
        SET est_penalise = 1
        WHERE numero = abonne 
        AND est_penalise = 0;

        UPDATE Historique
        SET penalite = 1
        WHERE num_abonné_histo = abonne
        AND code_barre_histo = code_barre_emprunt;

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Vous avez été pénalisé. Vous devez régler la somme de 1 Euro."

        -- Vérifier si l'abonné a été pénalisé 3 fois auquel cas on le banni
        IF (SELECT COUNT(penalite) FROM Historique WHERE penalite = 1 AND num_abonné_histo = abonne) > 3 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = "Vous avez été pénalisé 3 fois. Vous êtes banni."
        END IF;
    END IF;


    -- Supprimer l'emprunt
    DELETE FROM Emprunt
    WHERE num_abonné = abonne 
    AND code_barre = code_barre_emprunt;


END //
DELIMITER ;
