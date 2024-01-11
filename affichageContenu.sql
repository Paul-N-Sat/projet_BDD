USE Bibliotheque;
DELIMITER //

CREATE PROCEDURE affichageContenu(IN keyWord VARCHAR(55))
BEGIN
    SELECT * FROM Contenus
    WHERE titre LIKE CONCAT('%', keyWord, '%') 
    OR auteur LIKE CONCAT('%', keyWord, '%') 
    OR type_contenu LIKE CONCAT('%', keyWord, '%') 
    OR genre LIKE CONCAT('%', keyWord, '%');

    IF (SELECT COUNT(*) FROM Contenus
    WHERE titre LIKE CONCAT('%', keyWord, '%') 
    OR auteur LIKE CONCAT('%', keyWord, '%') 
    OR type_contenu LIKE CONCAT('%', keyWord, '%') 
    OR genre LIKE CONCAT('%', keyWord, '%')) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Aucun exemplaire existant. Vérifier l'écriture du mot clé.";
    END IF;
 
END //

DELIMITER ;