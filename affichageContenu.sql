DELIMITER //

CREATE PROCEDURE affichageContenu(IN keyWord VARCHAR(55))
BEGIN
    SELECT * FROM Contenu
    WHERE titre LIKE CONCAT('%', keyWord, '%') 
    OR auteur LIKE CONCAT('%', keyWord, '%') 
    OR type_contenu LIKE CONCAT('%', keyWord, '%') 
    OR genre LIKE CONCAT('%', keyWord, '%');
END //

DELIMITER ;