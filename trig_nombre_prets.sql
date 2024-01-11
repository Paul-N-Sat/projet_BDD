USE Bibliotheque;   
DELIMITER //

-- Le trigger permet de vérifier si l'utilisateur a déjà 5 prêts en cours 
CREATE TRIGGER trig_nombre_prets
BEFORE INSERT ON Emprunt
FOR EACH ROW
BEGIN
    DECLARE nb_prets INT;

    -- NB_PRETS : Vérifier le nombre de prêts actuels de l'utilisateur
    SELECT COUNT(code_barre_emprunt) INTO nb_prets
    FROM Emprunt
    WHERE num_abonné_emprunt = NEW.num_abonné_emprunt;

    IF nb_prets >= 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Vous avez déjà 5 prêts en cours. Vous ne pouvez pas en faire plus.';
    END IF;
END //

DELIMITER ;