USE Bibliotheque;

DELIMITER //

CREATE PROCEDURE Ajout_Abonne(IN nom VARCHAR(16), prenom VARCHAR(16)) -- ajoute un nouvel abonné
BEGIN

    DECLARE numeroAbo INT;
    
    -- Recherche du dernier numéro d'abonné utilisé et incrémentation
    SELECT MAX(numero) + 1 INTO numeroAbo FROM Abonnes;

    -- Ajout d'un nouvel abonné dans la table
    INSERT INTO Abonnes (numero, nom, prenom, date_adhesion,est_penalise, est_abonne)
    VALUES (numeroAbo, nom, prenom , CURRENT_DATE, 0, 1); 
END //

DELIMITER ;
