USE Bibliotheque;

DELIMITER //

CREATE PROCEDURE echeancier()
BEGIN
    SELECT Emprunt.num_abonné_emprunt, Contenus.titre 
    FROM Emprunt
    JOIN Exemplaires ON Emprunt.code_barre = Exemplaires.code_barre
    JOIN Contenus ON Exemplaires.code_cat = Contenus.code_catalogue;
END //

DELIMITER ;