USE Bibliotheque;

DELIMITER //

CREATE PROCEDURE test_ajout_abonne_vide()
BEGIN 
    CALL Ajout_Abonne(' ', ' '); -- test avec des champs vides
END //

CREATE PROCEDURE test_ajout_abonne_chiffre()
BEGIN
    CALL Ajout_Abonne("Dupuis", "45"); -- test avec un prénom qui ne sont pas des chaînes de caractères
END //

CREATE PROCEDURE test_ajout_abonne()
BEGIN
    CALL Ajout_Abonne("Dupuis", "Jean"); -- test avec un nom qui ne sont pas des chaînes de caractères
END //

DELIMITER ;
