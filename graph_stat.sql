USE Bibliotheque;
DELIMITER //

-- Affiche le nombre d'emprunts en cours, le nombre d'emprunts par établissement et le titre le plus emprunté
CREATE PROCEDURE Graph_Stat()
BEGIN
    SELECT COUNT(*) AS "nombre d'emprunts en cours",
        (SELECT COUNT(*) FROM View_Emprunt
            WHERE etablissement = "Orange"
            GROUP BY etablissement) AS "nombre d'emprunts chez Orange",
        (SELECT COUNT(*) FROM View_Emprunt
            WHERE etablissement = "ENSSAT"
            GROUP BY etablissement) AS "nombre d'emprunts à l'ENSSAT",
        (SELECT COUNT(*) FROM View_Emprunt
            WHERE etablissement = "IUT"
            GROUP BY etablissement) AS "nombre d'emprunts à l'IUT",
        (SELECT COUNT(*) FROM View_Emprunt
            WHERE etablissement = "Lycée Le Dantec"
            GROUP BY etablissement) AS "nombre d'emprunts au lycée Le Dantec",
        (SELECT COUNT(*) FROM View_Emprunt
            WHERE etablissement = "Lannion"
            GROUP BY etablissement) AS "nombre d'emprunts à Lannion",
        (SELECT titre FROM View_Historique
         GROUP BY titre
         ORDER BY COUNT(*) DESC
         LIMIT 1) AS "titre le plus emprunté"
    FROM View_Emprunt;
    
END //

DELIMITER ;

