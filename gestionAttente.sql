USE Bibliotheque;

DELIMITER //

CREATE PROCEDURE gestionAttente()
BEGIN
    DECLARE date_seuil DATE;

    -- Définir la date seuil (7 jours avant la date actuelle)
    SET date_seuil = DATE_SUB(CURRENT_DATE, INTERVAL 7 DAY);

    -- Supprimer les demandes obsolètes
    DELETE FROM Demande
    WHERE Demande.code_catalogue_dem IN (
        SELECT code_cat
        FROM Exemplaires
        WHERE Exemplaires.code_barre IN(
            SELECT DISTINCT h.code_barre_histo
            FROM Historique h
            WHERE h.date_retour = (
                SELECT MAX(date_retour)
                FROM Bibliotheque.Historique
                WHERE code_barre_histo = h.code_barre_histo
            )
            AND h.date_retour <= date_seuil
        )
    );
END //
DELIMITER ;