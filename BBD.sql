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
  `nom` VARCHAR(55) NULL DEFAULT NULL,
  `auteur` VARCHAR(45) NOT NULL,
  `type` VARCHAR(16) NOT NULL,
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
  `code_catalogue` INT NOT NULL,
  `etablissement` VARCHAR(16) NULL DEFAULT NULL,
  `edition` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`code_barre`, `code_catalogue`),
  INDEX `code_catalogue_idx` (`code_catalogue` ASC) VISIBLE,
  CONSTRAINT `code_catalogue`
    FOREIGN KEY (`code_catalogue`)
    REFERENCES `Bibliotheque`.`Contenus` (`code_catalogue`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `Bibliotheque`.`Emprunt`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Bibliotheque`.`Emprunt` (
  `num_abonné` INT NOT NULL,
  `code_barre` INT NOT NULL,
  `date_emprunt` DATE NOT NULL,
  `date_retour` DATE NULL DEFAULT NULL,
  `renouvelable` TINYINT NULL DEFAULT NULL,
  PRIMARY KEY (`num_abonné`, `code_barre`),
  INDEX `numero_idx` (`num_abonné` ASC) VISIBLE,
  INDEX `code_barre_idx` (`code_barre` ASC) VISIBLE,
  CONSTRAINT `code_barre`
    FOREIGN KEY (`code_barre`)
    REFERENCES `Bibliotheque`.`Exemplaires` (`code_barre`),
  CONSTRAINT `numero`
    FOREIGN KEY (`num_abonné`)
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

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
