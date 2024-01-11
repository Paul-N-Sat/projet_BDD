USE Bibliotheque;

DELIMITER //

CREATE PROCEDURE MiseAJourAbonnes() -- mise a jour des abonnements
BEGIN
    
	-- Mise à jour des utilisateurs qui ne sont plus abonnés
    UPDATE Abonnes
    SET est_abonne = 0
    WHERE DATE_ADD(date_adhesion,INTERVAL 365 DAY) < CURRENT_DATE;
END //

DELIMITER ;