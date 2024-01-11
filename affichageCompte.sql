USE Bibliotheque;
DELIMITER //

CREATE PROCEDURE affichageCompte(IN keyWord VARCHAR(16))
BEGIN
    SELECT * FROM Abonnes
    WHERE num_abonné LIKE CONCAT('%', keyWord, '%')
    OR nom LIKE CONCAT('%', keyWord, '%')
    OR prenom LIKE CONCAT('%', keyWord, '%')

    IF (SELECT COUNT(*) FROM Abonnes
            WHERE num_abonné LIKE CONCAT('%', keyWord, '%')
            OR nom LIKE CONCAT('%', keyWord, '%')
            OR prenom LIKE CONCAT('%', keyWord, '%')
        ) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Aucun compte existant. Vérifier l'écriture du mot clé.";
    END IF;
 
END //

DELIMITER ;