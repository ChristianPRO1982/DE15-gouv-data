-- Étape 5 : tests à exécuter dans Snowsight ; ne pas inscrire de résultat supposé.
-- Sorties : statuts et volumes uniquement ; aucune valeur personnelle ni empreinte affichée.
-- À exécuter en entier dans une même session et le même jour ; aucun CSV n’est rechargé.
-- Si le jour change, TENURE_YEARS peut légitimement évoluer : reprendre la référence.
USE SECONDARY ROLES NONE;
USE ROLE TRANSFORMER;
USE WAREHOUSE NYC_TAXI_WH;
SET (e5_avant_dim, e5_avant_mensuel, e5_avant_depot) = (
 SELECT (SELECT HASH_AGG(*) FROM NYC_TAXI.MARTS.DIM_DRIVER),
        (SELECT HASH_AGG(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY),
        (SELECT HASH_AGG(*) FROM NYC_TAXI.MARTS.DIM_DEPOT)
);

-- Reprise de snowflake/rh/staging/stg_rh__drivers.sql, à maintenir identique au fichier métier.
-- À exécuter avec le rôle des outils (vérifiez le rôle affiché en haut à droite de la feuille).
USE ROLE TRANSFORMER;
USE WAREHOUSE NYC_TAXI_WH;

-- Chauffeurs : typage et nettoyage léger du fichier RH.
CREATE OR REPLACE VIEW NYC_TAXI.STAGING.STG_RH__DRIVERS AS
SELECT
    driver_id,
    first_name,
    last_name,
    LOWER(TRIM(email))          AS email,
    NULLIF(TRIM(phone), '')     AS phone,
    birth_date::date            AS birth_date,
    tlc_license_number,
    INITCAP(TRIM(depot))        AS depot,
    hire_date::date             AS hire_date,
    end_date::date              AS end_date,
    _source_file                AS source_file,
    _loaded_at                  AS loaded_at
FROM NYC_TAXI.RAW.DRIVERS;

-- Reprise de snowflake/rh/staging/stg_rh__driver_shifts.sql, à maintenir identique au fichier métier.
-- À exécuter avec le rôle des outils (vérifiez le rôle affiché en haut à droite de la feuille).
USE ROLE TRANSFORMER;
USE WAREHOUSE NYC_TAXI_WH;

-- Services : typage, et une seule ligne par service (la première chargée).
CREATE OR REPLACE VIEW NYC_TAXI.STAGING.STG_RH__DRIVER_SHIFTS AS
SELECT
    shift_id,
    driver_id,
    shift_date::date            AS shift_date,
    INITCAP(TRIM(depot))        AS depot,
    start_hour::integer         AS start_hour,
    hours_worked::float         AS hours_worked,
    trips_count::integer        AS trips_count,
    revenue_usd::float          AS revenue_usd,
    _source_file                AS source_file,
    _loaded_at                  AS loaded_at
FROM NYC_TAXI.RAW.DRIVER_SHIFTS
QUALIFY ROW_NUMBER() OVER (PARTITION BY shift_id ORDER BY _loaded_at) = 1;

-- Reprise de snowflake/rh/marts/dim_depot.sql, à maintenir identique au fichier métier.
-- À exécuter avec le rôle des outils (vérifiez le rôle affiché en haut à droite de la feuille).
USE ROLE TRANSFORMER;
USE WAREHOUSE NYC_TAXI_WH;

-- Référentiel des dépôts : les trois garages d'où partent les taxis.
-- INSERT OVERWRITE vide la table et la remplit, sans la recréer.
INSERT OVERWRITE INTO NYC_TAXI.MARTS.DIM_DEPOT (depot, quartier, ouvert_en, nb_places) VALUES
    ('Bronx',    'Hunts Point',       2009, 140),
    ('Brooklyn', 'East New York',     2011, 120),
    ('Queens',   'Long Island City',  2008, 180);

-- Reprise de snowflake/rh/marts/dim_driver.sql, à maintenir identique au fichier métier.
-- À exécuter avec le rôle des outils (vérifiez le rôle affiché en haut à droite de la feuille).
USE ROLE TRANSFORMER;
USE WAREHOUSE NYC_TAXI_WH;

-- Dimension chauffeur : une ligne par chauffeur.
-- INSERT OVERWRITE vide la table et la remplit, sans la recréer.
INSERT OVERWRITE INTO NYC_TAXI.MARTS.DIM_DRIVER
SELECT
    driver_id,
    first_name,
    last_name,
    email,
    phone,
    birth_date,
    tlc_license_number,
    depot,
    hire_date,
    end_date,
    end_date IS NULL                                                          AS is_active,
    ROUND(DATEDIFF(day, hire_date, COALESCE(end_date, CURRENT_DATE())) / 365.25, 1) AS tenure_years
FROM NYC_TAXI.STAGING.STG_RH__DRIVERS;

-- Reprise de snowflake/rh/marts/mart_driver_monthly.sql, à maintenir identique au fichier métier.
-- À exécuter avec le rôle des outils (vérifiez le rôle affiché en haut à droite de la feuille).
USE ROLE TRANSFORMER;
USE WAREHOUSE NYC_TAXI_WH;

-- Activité mensuelle de chaque chauffeur : services, heures, courses, recette.
INSERT OVERWRITE INTO NYC_TAXI.MARTS.MART_DRIVER_MONTHLY
SELECT
    DATE_TRUNC('month', s.shift_date)::date     AS activity_month,
    s.driver_id,
    d.first_name || ' ' || d.last_name          AS driver_name,
    s.depot,
    COUNT(*)                                    AS nb_shifts,
    ROUND(SUM(s.hours_worked), 1)               AS hours_worked,
    SUM(s.trips_count)                          AS trips_count,
    ROUND(SUM(s.revenue_usd), 2)                AS revenue_usd
FROM NYC_TAXI.STAGING.STG_RH__DRIVER_SHIFTS s
LEFT JOIN NYC_TAXI.MARTS.DIM_DRIVER d ON d.driver_id = s.driver_id
GROUP BY 1, 2, 3, 4;

USE SECONDARY ROLES NONE;
USE ROLE TRANSFORMER;
USE WAREHOUSE NYC_TAXI_WH;
SELECT IFF((SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER) = 400
 AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) = 914
 AND (SELECT HASH_AGG(*) FROM NYC_TAXI.MARTS.DIM_DRIVER) = $e5_avant_dim
 AND (SELECT HASH_AGG(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) = $e5_avant_mensuel
 AND (SELECT HASH_AGG(*) FROM NYC_TAXI.MARTS.DIM_DEPOT) = $e5_avant_depot,
 'OK', 'ECART') AS contenu_conserve;

-- Recalcul indépendant depuis RAW, y compris dates, statut et ancienneté ; pas seulement les volumes.
WITH attendu AS (
 SELECT driver_id, first_name, last_name, LOWER(TRIM(email)) AS email,
        NULLIF(TRIM(phone), '') AS phone, birth_date, tlc_license_number,
        INITCAP(TRIM(depot)) AS depot, hire_date, end_date,
        end_date IS NULL AS is_active,
        ROUND(DATEDIFF(day, hire_date, COALESCE(end_date, CURRENT_DATE())) / 365.25, 1)::FLOAT AS tenure_years
 FROM NYC_TAXI.RAW.DRIVERS
), differences AS (
 (SELECT * FROM attendu MINUS SELECT * FROM NYC_TAXI.MARTS.DIM_DRIVER)
 UNION ALL
 (SELECT * FROM NYC_TAXI.MARTS.DIM_DRIVER MINUS SELECT * FROM attendu)
)
SELECT IFF(COUNT(*) = 0, 'OK', 'ECART') AS dimension_conforme_a_raw, COUNT(*) AS nb_differences
FROM differences;

-- Les services orphelins restent présents : même LEFT JOIN que la transformation fournie.
WITH services AS (
 SELECT shift_id, driver_id, shift_date, INITCAP(TRIM(depot)) AS depot,
        hours_worked, trips_count, revenue_usd
 FROM NYC_TAXI.RAW.DRIVER_SHIFTS
 QUALIFY ROW_NUMBER() OVER (PARTITION BY shift_id ORDER BY _loaded_at) = 1
), attendu AS (
 SELECT DATE_TRUNC('month', s.shift_date)::DATE AS activity_month, s.driver_id,
        d.first_name || ' ' || d.last_name AS driver_name, s.depot,
        COUNT(*) AS nb_shifts, ROUND(SUM(s.hours_worked), 1)::FLOAT AS hours_worked,
        SUM(s.trips_count) AS trips_count, ROUND(SUM(s.revenue_usd), 2)::FLOAT AS revenue_usd
 FROM services s LEFT JOIN NYC_TAXI.RAW.DRIVERS d ON d.driver_id = s.driver_id
 GROUP BY 1, 2, 3, 4
), differences AS (
 (SELECT * FROM attendu MINUS SELECT * FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY)
 UNION ALL
 (SELECT * FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY MINUS SELECT * FROM attendu)
)
SELECT IFF(COUNT(*) = 0, 'OK', 'ECART') AS mensuel_conforme_a_raw, COUNT(*) AS nb_differences
FROM differences;

-- Paie : la reconstruction ne doit pas avoir enregistré les masques.
USE SECONDARY ROLES NONE;
USE ROLE RH_PAIE;
USE WAREHOUSE NYC_TAXI_WH;
SELECT IFF(COUNT(*) = 1 AND COUNT_IF(email LIKE '%@%' AND email <> '*****'
 AND first_name IS NOT NULL AND first_name <> '*****'
 AND last_name IS NOT NULL AND last_name <> '*****') = 1,
 'OK', 'ECART') AS contact_temoin_reste_reel
FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE driver_id = 'D0003';
-- Suite : verification_catalogue.sql avec TRANSFORMER, verification_politiques.sql avec ACCOUNTADMIN,
-- puis refaire B0...B8 de 05_tests_acces.sql après la reconstruction et après la rejouabilité.
