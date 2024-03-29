USE Bibliotheque;
DELIMITER //

-- Le trigger fait office de "MISE DE COTE"
-- Le trigger permet de vérifier si l'utilisateur peut emprunter le livre tout de suite ou si quelqu'un est déjà en attente
CREATE TRIGGER trig_contenu_deja_demande
BEFORE INSERT ON Emprunt
FOR EACH ROW
BEGIN
    DECLARE code_catalogue_demande INT;

    SELECT code_cat INTO code_catalogue_demande FROM Exemplaires WHERE code_barre = NEW.code_barre;

    -- On vérifie si le contenu a déjà été demandé par un autre utilisateur
    IF code_catalogue_demande IN (SELECT code_catalogue_dem FROM Demande) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Le contenu a déjà été demandé par un autre utilisateur avant vous.';
    END IF;
END //

DELIMITER ;