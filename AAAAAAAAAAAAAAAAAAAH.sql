-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema Bibliotheque
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema Bibliotheque
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `Bibliotheque` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `Bibliotheque` ;

-- -----------------------------------------------------
-- Table `Bibliotheque`.`Abonnes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Bibliotheque`.`Abonnes` (
  `numero` INT NOT NULL,
  `nom` VARCHAR(16) NOT NULL,
  `prenom` VARCHAR(16) NOT NULL,
  `date_adhesion` DATE NOT NULL,
  `est_penalise` TINYINT NULL DEFAULT NULL,
  `est_abonne` TINYINT NULL DEFAULT '0',
  PRIMARY KEY (`numero`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `Bibliotheque`.`Contenus`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Bibliotheque`.`Contenus` (
  `code_catalogue` INT NOT NULL,
  `titre` VARCHAR(55) NULL DEFAULT NULL,
  `auteur` VARCHAR(45) NOT NULL,
  `type_contenu` VARCHAR(55) NULL DEFAULT NULL,
  `genre` VARCHAR(16) NOT NULL,
  PRIMARY KEY (`code_catalogue`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `Bibliotheque`.`Demande`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Bibliotheque`.`Demande` (
  `num_abonné` INT NOT NULL,
  `code_catalogue_dem` INT NOT NULL,
  `date_demande` DATE NOT NULL,
  PRIMARY KEY (`num_abonné`),
  INDEX `code_catalogue_idx` (`code_catalogue_dem` ASC) VISIBLE,
  CONSTRAINT `code_catalogue_dem`
    FOREIGN KEY (`code_catalogue_dem`)
    REFERENCES `Bibliotheque`.`Contenus` (`code_catalogue`),
  CONSTRAINT `num_abonné`
    FOREIGN KEY (`num_abonné`)
    REFERENCES `Bibliotheque`.`Abonnes` (`numero`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `Bibliotheque`.`Exemplaires`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Bibliotheque`.`Exemplaires` (
  `code_barre` INT NOT NULL,
  `code_cat` INT NOT NULL,
  `etablissement` VARCHAR(16) NULL DEFAULT NULL,
  `edition` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`code_barre`, `code_cat`),
  INDEX `code_catalogue_idx` (`code_cat` ASC) VISIBLE,
  CONSTRAINT `code_catalogue`
    FOREIGN KEY (`code_cat`)
    REFERENCES `Bibliotheque`.`Contenus` (`code_catalogue`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `Bibliotheque`.`Emprunt`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Bibliotheque`.`Emprunt` (
  `num_abonné_emprunt` INT NOT NULL,
  `code_barre` INT NOT NULL,
  `date_emprunt` DATE NOT NULL,
  `date_retour` DATE NULL DEFAULT NULL,
  `renouvelable` TINYINT NULL DEFAULT NULL,
  PRIMARY KEY (`num_abonné_emprunt`, `code_barre`),
  INDEX `numero_idx` (`num_abonné_emprunt` ASC) VISIBLE,
  INDEX `code_barre_idx` (`code_barre` ASC) VISIBLE,
  CONSTRAINT `code_barre`
    FOREIGN KEY (`code_barre`)
    REFERENCES `Bibliotheque`.`Exemplaires` (`code_barre`),
  CONSTRAINT `numero`
    FOREIGN KEY (`num_abonné_emprunt`)
    REFERENCES `Bibliotheque`.`Abonnes` (`numero`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `Bibliotheque`.`Historique`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Bibliotheque`.`Historique` (
  `num_abonné_histo` INT NOT NULL,
  `code_barre_histo` INT NOT NULL,
  `date_emprunt` DATE NOT NULL,
  `date_retour` DATE NOT NULL,
  `penalite` TINYINT NULL DEFAULT NULL,
  PRIMARY KEY (`num_abonné_histo`, `code_barre_histo`),
  INDEX `code_barre_idx` (`code_barre_histo` ASC) VISIBLE,
  CONSTRAINT `code_barre_histo`
    FOREIGN KEY (`code_barre_histo`)
    REFERENCES `Bibliotheque`.`Exemplaires` (`code_barre`),
  CONSTRAINT `num_abonné_histo`
    FOREIGN KEY (`num_abonné_histo`)
    REFERENCES `Bibliotheque`.`Abonnes` (`numero`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

USE `Bibliotheque` ;

-- -----------------------------------------------------
-- procedure AjoutAbonnes
-- -----------------------------------------------------

DELIMITER $$
USE `Bibliotheque`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AjoutAbonnes`(IN nom VARCHAR(16), prenom VARCHAR(16))
BEGIN

    DECLARE numeroAbo INT;
    
    -- Recherche du numéro d'abonné
    SELECT MAX(numero) + 1 INTO numeroAbo FROM Abonnes;

    -- Ajout d'un nouvel abonné
    INSERT INTO Abonnes (numero, nom, prenom, date_adhesion, est_abonne)
    VALUES (numeroAbo, nom, prenom , CURRENT_DATE, 1);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GestionPrets
-- -----------------------------------------------------

DELIMITER $$
USE `Bibliotheque`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GestionPrets`(
    -- IN num_abonné INT,
    IN utilisateur_id INT,

    -- IN code_cat INT,
    IN contenu_id INT,

    -- IN type_contenu VARCHAR(50),
    IN type_contenu VARCHAR(50),

    -- Boolean pour savoir si l'utilisateur souhaite être en attente
    IN attente TINYINT,

    -- Lieu où l'utilisateur souhaite emprunter le contenu
    IN Lieu VARCHAR(50)
)
BEGIN
    DECLARE rendu_emprunt DATE;
    DECLARE code_barre_exemplaire INT;
    DECLARE somme INT;  
    DECLARE somme2 INT;


    -- On enregistre dans une variable le code_barre de l'exemplaire disponible 
    SELECT Exemplaires.code_barre INTO code_barre_exemplaire
        FROM Exemplaires
        WHERE code_barre NOT IN (SELECT code_barre FROM Emprunt)
        AND Exemplaires.code_cat = contenu_id 
        AND etablissement = Lieu
        LIMIT 1;

    -- RENDU_EMPRUNT : On determine la durée de l'emprunt en fonction du type de contenu
    IF type_contenu = 'Livre' THEN
        SET rendu_emprunt = DATE_ADD(CURRENT_DATE, INTERVAL 15 DAY);
    ELSE
        SET rendu_emprunt = DATE_ADD(CURRENT_DATE, INTERVAL 7 DAY);
    END IF;

    -- SOMME : On calcule le nombre d exemplaires disponibles dans le lieu demande 
    SELECT COUNT(Exemplaires.code_barre) INTO somme
    FROM Exemplaires
    WHERE code_barre NOT IN (SELECT code_barre FROM Emprunt)
    AND Exemplaires.code_cat = contenu_id 
    AND etablissement = Lieu;

    -- SOMME2 : On calcule le nombre d'exemplaires disponibles dans tous les lieux 
    SELECT COUNT(Exemplaires.code_barre) INTO somme2
    FROM Exemplaires
    WHERE code_barre NOT IN (SELECT code_barre FROM Emprunt)
    AND Exemplaires.code_cat = contenu_id;


    -- Vérifier si des exemplaires du contenu sont disponibles, dans le lieu demandé
    IF somme > 0 THEN

        -- Effectuer l'emprunt
        INSERT INTO Emprunt
        VALUES (utilisateur_id, code_barre_exemplaire, CURRENT_DATE, rendu_emprunt, 0);

    -- Sinon, vérifier si des exemplaires du contenu sont disponibles, dans un autre lieu
    ELSE 
        IF somme2 = 0 THEN

            -- Aucun exemplaire disponible, demander à l'utilisateur s'il souhaite se mettre en attente
            IF attente = 1 THEN

                INSERT INTO Demande
                VALUES (utilisateur_id, contenu_id, CURRENT_DATE);

                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Aucun exemplaire disponible. Vous êtes en attente.';

            ELSE
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Aucun exemplaire disponible. Vous n êtes pas inscrit en attente.';
            END IF;
        ELSE
            SELECT etablissement FROM Exemplaires
            WHERE code_barre NOT IN (SELECT code_barre FROM Emprunt)
            AND (Exemplaires.code_cat = contenu_id);

            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'L exemplaire est disponible dans les etablissements ci-dessus:';
        END IF;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure MiseAJourAbonnes
-- -----------------------------------------------------

DELIMITER $$
USE `Bibliotheque`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `MiseAJourAbonnes`()
BEGIN
    -- Mise à jour des abonnés
    UPDATE Abonnes
    SET est_abonne = 1
    WHERE DATE_ADD(date_adhesion,INTERVAL 365 DAY) > CURRENT_DATE;
    
	-- Mise à jour des abonnés
    UPDATE Abonnes
    SET est_abonne = 0
    WHERE DATE_ADD(date_adhesion,INTERVAL 365 DAY) < CURRENT_DATE;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure Refresh_Abo
-- -----------------------------------------------------

DELIMITER $$
USE `Bibliotheque`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Refresh_Abo`(IN num_Abo INT)
BEGIN

    -- Mise à jour des abonnés
    UPDATE Abonnes
    SET est_abonne = 1,
        date_adhesion = CURRENT_DATE 
    WHERE numero = num_Abo; 

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure affichageContenu
-- -----------------------------------------------------

DELIMITER $$
USE `Bibliotheque`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `affichageContenu`(IN keyWord VARCHAR(55))
BEGIN
    SELECT * FROM Contenus
    WHERE titre LIKE CONCAT('%', keyWord, '%') 
    OR auteur LIKE CONCAT('%', keyWord, '%') 
    OR type_contenu LIKE CONCAT('%', keyWord, '%') 
    OR genre LIKE CONCAT('%', keyWord, '%');

    IF (SELECT COUNT(*) FROM Contenus
    WHERE titre LIKE CONCAT('%', keyWord, '%') 
    OR auteur LIKE CONCAT('%', keyWord, '%') 
    OR type_contenu LIKE CONCAT('%', keyWord, '%') 
    OR genre LIKE CONCAT('%', keyWord, '%')) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Aucun exemplaire existant. Vérifier l'écriture du mot clé.";
    END IF;
 
END$$

DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
USE `Bibliotheque`;

DELIMITER $$
USE `Bibliotheque`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `Bibliotheque`.`trig_contenu_deja_demande`
BEFORE INSERT ON `Bibliotheque`.`Emprunt`
FOR EACH ROW
BEGIN
    DECLARE code_catalogue_demande INT;

    SELECT code_cat INTO code_catalogue_demande FROM Exemplaires WHERE code_barre = NEW.code_barre;
    -- On vérifie si le contenu a déjà été demandé par un autre utilisateur
    IF code_catalogue_demande IN (SELECT code_catalogue_dem FROM Demande) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Le contenu a déjà été demandé par un autre utilisateur avant vous.';
    END IF;
END$$

USE `Bibliotheque`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `Bibliotheque`.`trig_est_abonnee`
BEFORE INSERT ON `Bibliotheque`.`Emprunt`
FOR EACH ROW
BEGIN
    IF (SELECT est_abonne FROM Abonnes WHERE numero = NEW.num_abonné_emprunt) = 0 -- Si l'utilisateur n'est pas abonné
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Vous n'êtes pas abonné.";
    END IF;

END$$


DELIMITER ;
