USE Bibliotheque;
DELIMITER //

-- Le trigger permet de vérifier si l'utilisateur est abonné
CREATE TRIGGER trig_est_abonnee
BEFORE INSERT ON Emprunt
FOR EACH ROW
BEGIN
    IF (SELECT est_abonne FROM Abonnes WHERE numero = NEW.num_abonné_emprunt) = 0 -- Si l'utilisateur n'est pas abonné
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Vous n\'êtes pas abonné.";
    END IF;

END //

DELIMITER ;