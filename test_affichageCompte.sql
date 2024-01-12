USE Bibliotheque;

DELIMITER //

CREATE PROCEDURE test_affichageCompte_vide()
BEGIN 
    CALL affichageCompte(' '); -- test avec un mot clé vide
END //

CREATE PROCEDURE test_affichageCompte()
BEGIN
    CALL affichageCompte('David'); -- test avec un mot clé valide
END //

DELIMITER ;