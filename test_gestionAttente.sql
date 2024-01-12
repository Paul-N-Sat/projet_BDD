
-- Pour ce test, on supposera que la demande enregistré a été effectué lorsque le contenu était emprunter
-- ATTENTION : Importer les données de jeu_test_Pret.sql avant d'executer ce test pour avoir table Historique remplie
INSERT INTO Demande
VALUES (51,1007,CURRENT_DATE);

-- La demande devrait disparaitre de la table Demande du fait que l'oeuvre a été rendu il y a plus de 7 jours et que personne n'est venu la chercher
CALL gestionAttente();