USE Bibliotheque;

DELETE FROM Bibliotheque.Emprunt;
DELETE FROM Bibliotheque.Historique;
DELETE FROM Bibliotheque.Demande;


INSERT IGNORE INTO Bibliotheque.Emprunt
VALUES
(1,100100,CURRENT_DATE,DATE_ADD(CURRENT_DATE,INTERVAL 15 DAY),0),
(1,100400,CURRENT_DATE,DATE_ADD(CURRENT_DATE,INTERVAL 15 DAY),0),
(1,100200,CURRENT_DATE,DATE_ADD(CURRENT_DATE,INTERVAL 7 DAY),0),
(1,100300,CURRENT_DATE,DATE_ADD(CURRENT_DATE,INTERVAL 7 DAY),0),
(1,100500,CURRENT_DATE,DATE_ADD(CURRENT_DATE,INTERVAL 7 DAY),0),
(3,100201,CURRENT_DATE,DATE_ADD(CURRENT_DATE,INTERVAL 7 DAY),0),
(3,102000,'2023-12-01', '2023-12-15',0);

INSERT IGNORE INTO Bibliotheque.Historique
VALUES
(32, 100600, '2022-01-01', '2022-01-15', 1),
(32, 100700, '2022-02-01', '2022-02-14', 1),
(32, 100800, '2022-03-01', '2022-03-15', 1);

INSERT IGNORE INTO Bibliotheque.Demande
VALUES
(22, 1001, '2024-01-01'),
(22, 1015, '2024-01-01'),
(22, 1000, '2024-01-01');


DELIMITER //

-- On teste le refus d'emprunt si plus de 5 emprunts sont actifs
CREATE PROCEDURE test_trig_nombre_emprunts()
    BEGIN
        CALL GestionPrets(1,1010,'Album',0,'IUT', 0);
    END //

-- On teste le refus d'emprunt si plus de 3 demandes sont actives
CREATE PROCEDURE test_trig_nombre_demande()
    BEGIN
        CALL GestionPrets(22,1031,'Livre',0,'ENSSAT', 0);
    END //

-- On teste le refus d'emprunt si le contenu a déjà été emprunté par un autre utilisateur
CREATE PROCEDURE test_trig_deja_emprunte()
    BEGIN
        CALL GestionPrets(3,1005,'Film',0,'IUT', 0);
    END //

-- On teste si le refus d'emprunt si la personne n'est pas abonnée
CREATE PROCEDURE test_trig_est_abonnee()
    BEGIN
        CALL GestionPrets(2,1005,'Film',0,'ENSSAT', 0);
    END //

-- Pour tester si GestionPrets propose bien les lieux où le contenu est disponible si l'oeuvre n'est pas disponible dans le lieu demandé
CREATE PROCEDURE test_dispo_autre()
    BEGIN
        CALL GestionPrets(3,1007,'Magazine',0,'ENSSAT', 0);
    END //

-- On teste la fonctionnalité d'attente
CREATE PROCEDURE test_en_attente()
    BEGIN
        CALL GestionPrets(6,1002,'Film',1,'ENSSAT', 0);
    END //

-- On teste le résultat lorsque la saisie en entrée est incorrecte ou inexistante
CREATE PROCEDURE test_existence()
    BEGIN
        CALL GestionPrets(6,1002,'Film',1,'ENSSAT', 0);
    END //

-- On teste que GestionPrêts ne propose pas de lieux où le contenu est disponible si l'utilisateur a demandé des oeuvres uniquement dans son lieu et est donc ici mis en attente à sa demande
CREATE PROCEDURE test_lieu_demandé_uniquement()
    BEGIN
        CALL GestionPrets(15,1013,'Film',1,'ENSSAT', 1);
    END //

-- On teste que GestionPrêts ne propose pas de lieux où le contenu est disponible si l'utilisateur a demandé des oeuvres uniquement dans son lieu
CREATE PROCEDURE test_banni()
    BEGIN
        CALL GestionPrets(32,1013,'Film',1,'ENSSAT', 1);
    END //

-- On teste si le trigger trig_contenu_deja_demande fonctionne
CREATE PROCEDURE test_trig_contenu_deja_demande()
    BEGIN
        CALL GestionPrets(25,1000,'Livre',0,'Lycée Le Dantec', 0);
    END // 

-- On teste le Rendu de l'emprunt en retard et la pénalité
CREATE PROCEDURE test__rendu_penalite
    BEGIN
        CALL RenduContenu(3,102000);
    END //
DELIMITER ;