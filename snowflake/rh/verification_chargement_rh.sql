-- Vérification en lecture seule de l'étape 3, avant toute purge.
-- À exécuter après les deux chargements, les vues STAGING et les trois MARTS.
-- Un objet absent provoque une erreur : terminer les scripts précédents avant de poursuivre.
USE SECONDARY ROLES NONE;
USE ROLE TRANSFORMER;
USE WAREHOUSE NYC_TAXI_WH;

SELECT CURRENT_ROLE() AS role_actif,
       CURRENT_WAREHOUSE() AS warehouse_actif;

-- Attendu : six lignes avec le statut OK. Aucun détail personnel n'est affiché.
WITH volumes AS (
    SELECT 1 AS ordre, 'RAW.DRIVERS' AS objet,
           400 AS lignes_attendues, COUNT(*) AS lignes_obtenues
    FROM NYC_TAXI.RAW.DRIVERS
    UNION ALL
    SELECT 2, 'RAW.DRIVER_SHIFTS', 25951, COUNT(*)
    FROM NYC_TAXI.RAW.DRIVER_SHIFTS
    UNION ALL
    SELECT 3, 'STAGING.STG_RH__DRIVER_SHIFTS', 25933, COUNT(*)
    FROM NYC_TAXI.STAGING.STG_RH__DRIVER_SHIFTS
    UNION ALL
    SELECT 4, 'MARTS.DIM_DEPOT', 3, COUNT(*)
    FROM NYC_TAXI.MARTS.DIM_DEPOT
    UNION ALL
    SELECT 5, 'MARTS.DIM_DRIVER', 400, COUNT(*)
    FROM NYC_TAXI.MARTS.DIM_DRIVER
    UNION ALL
    SELECT 6, 'MARTS.MART_DRIVER_MONTHLY', 914, COUNT(*)
    FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY
)
SELECT objet, lignes_attendues, lignes_obtenues,
       CASE WHEN lignes_obtenues = lignes_attendues THEN 'OK' ELSE 'ECART' END AS statut
FROM volumes
ORDER BY ordre;

-- Attendu : aucun fichier. Un stage non vide empêche la validation de l'étape.
LIST @NYC_TAXI.RAW.RH_STAGE;
