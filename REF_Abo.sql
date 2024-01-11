USE Bibliotheque;

DELIMITER //

CREATE PROCEDURE Refresh_Abo(IN num_Abo INT) -- renouvelle l'abonnement d'un abonné
BEGIN

    -- Mise à jour des abonnés
    UPDATE Abonnes
    SET est_abonne = 1, 
        date_adhesion = CURRENT_DATE -- On met à jour la date d'adhésion
    WHERE numero = num_Abo; 
END //

DELIMITER ;