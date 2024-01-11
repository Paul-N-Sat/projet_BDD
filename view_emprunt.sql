USE Bibliotheque;

CREATE VIEW View_Emprunt AS
SELECT Emprunt.code_barre_emprunt, Exemplaires.etablissement
FROM Emprunt
JOIN Exemplaires ON Emprunt.code_barre_emprunt = Exemplaires.code_barre;

