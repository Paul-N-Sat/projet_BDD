USE Bibliotheque;

DELIMITER //

-- Note: Le test associé consiste simplement à appeler la procédure. Si rien ne s'affiche, alors tous le monde à rendu ses oeuvres dans les temps.
CREATE PROCEDURE echeancier()
BEGIN
    SELECT Emprunt.num_abonné_emprunt, Contenus.titre 
    FROM Emprunt
    JOIN Exemplaires ON Emprunt.code_barre = Exemplaires.code_barre
    JOIN Contenus ON Exemplaires.code_cat = Contenus.code_catalogue
    WHERE Emprunt.date_retour < CURRENT_DATE;
END //

DELIMITER ;