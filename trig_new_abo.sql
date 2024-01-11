USE Bibliotheque;
DELIMITER //

-- Le trigger permet de vérifier si l'utilisateur est abonné
CREATE TRIGGER trig_new_abonne
BEFORE INSERT ON Abonnes
FOR EACH ROW
BEGIN
    -- Si les champs nom et prénom sont vides   
    IF NEW.nom = ' ' OR NEW.prenom=' ' OR NEW.nom ='' OR NEW.prenom='' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Veuillez compléter les champs nom et prénom.';
    END IF;

    -- Vérification des caractères du nom et du prénom
    IF NEW.nom REGEXP '[^a-zA-Z ]' OR NEW.prenom REGEXP '[^a-zA-Z ]' THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Caractère(s) invalide dans le nom ou le prénom.';
    END IF;


END //

DELIMITER ;