USE Bibliotheque;

CREATE VIEW View_Historique AS
SELECT code_barre_histo,etablissement, titre
FROM Historique 
JOIN Exemplaires ON Historique.code_barre_histo = Exemplaires.code_barre 
JOIN Contenus ON Exemplaires.code_cat = Contenus.code_catalogue;

