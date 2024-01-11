USE Bibliotheque;   
DELIMITER //

-- Le trigger permet de vérifier si l'utilisateur a déjà 3 demandes en cours
CREATE TRIGGER trig_nombre_demandes
BEFORE INSERT ON Demande
FOR EACH ROW
BEGIN
    DECLARE nb_demande INT;

    -- NB_DEMANDE : Vérifier le nombre de demande actuels de l'utilisateur
    SELECT COUNT(code_catalogue_dem) INTO nb_demande
    FROM Demande
    WHERE Demande.num_abonné = NEW.num_abonné;

    IF nb_demande >= 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Vous avez déjà 3 Demandes en cours. Vous ne pouvez pas en faire plus.';
    END IF;
END //

DELIMITER ;