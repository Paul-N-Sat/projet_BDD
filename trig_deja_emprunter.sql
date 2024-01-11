USE Bibliotheque;
DELIMITER //

-- Le trigger fait office de "MISE DE COTE"
-- Le trigger permet de vérifier si l'utilisateur est le premier a formuler une demande
CREATE TRIGGER trig_contenu_deja_emprunter
BEFORE INSERT ON Emprunt
FOR EACH ROW
BEGIN

    -- On vérifie si le contenu a déjà été emprunter par un autre utilisateur
    IF EXISTS (SELECT code_barre_emprunt FROM Emprunt WHERE Emprunt.code_barre_emprunt = NEW.code_barre_emprunt) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Le contenu a déjà été emprunté par un autre utilisateur avant vous.';
    END IF;
END //

DELIMITER ;