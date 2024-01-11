USE Bibliotheque;

DELIMITER //

CREATE PROCEDURE test_ajout_abonne()
BEGIN 
    CALL Ajout_Abonne(' ', ' '); -- test avec des champs vides
END //

CREATE PROCEDURE test_ajout_abonne2()
BEGIN
    CALL Ajout_Abonne("Dupuis", "45"); -- test avec un prénom qui ne sont pas des chaînes de caractères
END //

DELIMITER ;
