USE Bibliotheque;

CREATE VIEW View_Emprunt AS
SELECT Emprunt.code_barre, Exemplaires.etablissement
FROM Emprunt
JOIN Exemplaires ON Emprunt.code_barre = Exemplaires.code_barre;

