-- Contrôles de métadonnées sans afficher les données des chauffeurs.
-- À lancer après les cinq fiches ; relancer les fiches puis ces contrôles pour vérifier la rejouabilité.
USE SECONDARY ROLES NONE;
USE ROLE TRANSFORMER;
USE WAREHOUSE NYC_TAXI_WH;
SELECT CURRENT_ROLE(), CURRENT_WAREHOUSE();

-- Attendu : 0 ligne (description table absente).
SELECT table_schema, table_name
FROM NYC_TAXI.INFORMATION_SCHEMA.TABLES
WHERE ((table_schema = 'RAW' AND table_name IN ('DRIVERS', 'DRIVER_SHIFTS'))
    OR (table_schema = 'MARTS' AND table_name IN ('DIM_DRIVER', 'MART_DRIVER_MONTHLY', 'DIM_DEPOT')))
  AND NULLIF(TRIM(comment), '') IS NULL;

-- Attendu : 0 ligne (description colonne absente sur les trois fiches complètes).
SELECT table_schema, table_name, column_name
FROM NYC_TAXI.INFORMATION_SCHEMA.COLUMNS
WHERE ((table_schema = 'RAW' AND table_name = 'DRIVERS')
    OR (table_schema = 'MARTS' AND table_name IN ('DIM_DRIVER', 'DIM_DEPOT')))
  AND NULLIF(TRIM(comment), '') IS NULL;

-- Attendu : 5 tables ; 28 colonnes décrites dans les trois fiches complètes.
SELECT COUNT(*) AS nb_tables, COUNT_IF(NULLIF(TRIM(comment), '') IS NOT NULL) AS nb_tables_decrites
FROM NYC_TAXI.INFORMATION_SCHEMA.TABLES
WHERE (table_schema = 'RAW' AND table_name IN ('DRIVERS', 'DRIVER_SHIFTS'))
   OR (table_schema = 'MARTS' AND table_name IN ('DIM_DRIVER', 'MART_DRIVER_MONTHLY', 'DIM_DEPOT'));
SELECT COUNT(*) AS nb_colonnes, COUNT_IF(NULLIF(TRIM(comment), '') IS NOT NULL) AS nb_colonnes_decrites
FROM NYC_TAXI.INFORMATION_SCHEMA.COLUMNS
WHERE (table_schema = 'RAW' AND table_name = 'DRIVERS')
   OR (table_schema = 'MARTS' AND table_name IN ('DIM_DRIVER', 'DIM_DEPOT'));

-- Attendu : 18 lignes OK ; couverture limitée aux catégories établies de l’inventaire.
WITH attendus AS (
 SELECT column1 AS objet, column2 AS colonne, column3 AS valeur FROM VALUES
    ('RAW.DRIVERS', 'DRIVER_ID', 'identifiant_interne'),
    ('RAW.DRIVERS', 'FIRST_NAME', 'nom'),
    ('RAW.DRIVERS', 'LAST_NAME', 'nom'),
    ('RAW.DRIVERS', 'EMAIL', 'email'),
    ('RAW.DRIVERS', 'PHONE', 'telephone'),
    ('RAW.DRIVERS', 'BIRTH_DATE', 'date_naissance'),
    ('RAW.DRIVERS', 'TLC_LICENSE_NUMBER', 'identifiant_officiel'),
    ('MARTS.DIM_DRIVER', 'DRIVER_ID', 'identifiant_interne'),
    ('MARTS.DIM_DRIVER', 'FIRST_NAME', 'nom'),
    ('MARTS.DIM_DRIVER', 'LAST_NAME', 'nom'),
    ('MARTS.DIM_DRIVER', 'EMAIL', 'email'),
    ('MARTS.DIM_DRIVER', 'PHONE', 'telephone'),
    ('MARTS.DIM_DRIVER', 'BIRTH_DATE', 'date_naissance'),
    ('MARTS.DIM_DRIVER', 'TLC_LICENSE_NUMBER', 'identifiant_officiel'),
    ('RAW.DRIVER_SHIFTS', 'SHIFT_ID', 'identifiant_interne'),
    ('RAW.DRIVER_SHIFTS', 'DRIVER_ID', 'identifiant_interne'),
    ('MARTS.MART_DRIVER_MONTHLY', 'DRIVER_ID', 'identifiant_interne'),
    ('MARTS.MART_DRIVER_MONTHLY', 'DRIVER_NAME', 'nom')
), tags AS (
SELECT 'RAW.DRIVERS' AS objet, column_name, tag_name, tag_value
FROM TABLE(NYC_TAXI.INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS('NYC_TAXI.RAW.DRIVERS', 'TABLE'))
UNION ALL
SELECT 'RAW.DRIVER_SHIFTS' AS objet, column_name, tag_name, tag_value
FROM TABLE(NYC_TAXI.INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS('NYC_TAXI.RAW.DRIVER_SHIFTS', 'TABLE'))
UNION ALL
SELECT 'MARTS.DIM_DRIVER' AS objet, column_name, tag_name, tag_value
FROM TABLE(NYC_TAXI.INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS('NYC_TAXI.MARTS.DIM_DRIVER', 'TABLE'))
UNION ALL
SELECT 'MARTS.MART_DRIVER_MONTHLY' AS objet, column_name, tag_name, tag_value
FROM TABLE(NYC_TAXI.INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS('NYC_TAXI.MARTS.MART_DRIVER_MONTHLY', 'TABLE'))
UNION ALL
SELECT 'MARTS.DIM_DEPOT' AS objet, column_name, tag_name, tag_value
FROM TABLE(NYC_TAXI.INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS('NYC_TAXI.MARTS.DIM_DEPOT', 'TABLE'))
)
SELECT a.*, t.tag_value AS obtenu, IFF(t.tag_value = a.valeur, 'OK', 'ECART') AS statut
FROM attendus a LEFT JOIN tags t
 ON t.objet = a.objet AND t.column_name = a.colonne AND t.tag_name = 'DONNEE_PERSONNELLE'
ORDER BY a.objet, a.colonne;

SELECT 'RAW.DRIVERS' AS objet,
 SYSTEM$GET_TAG('NYC_TAXI.GOUVERNANCE.SENSIBILITE', 'NYC_TAXI.RAW.DRIVERS', 'TABLE') AS sensibilite,
 SYSTEM$GET_TAG('NYC_TAXI.GOUVERNANCE.DUREE_CONSERVATION', 'NYC_TAXI.RAW.DRIVERS', 'TABLE') AS duree_conservation;
SELECT 'RAW.DRIVER_SHIFTS' AS objet,
 SYSTEM$GET_TAG('NYC_TAXI.GOUVERNANCE.SENSIBILITE', 'NYC_TAXI.RAW.DRIVER_SHIFTS', 'TABLE') AS sensibilite,
 SYSTEM$GET_TAG('NYC_TAXI.GOUVERNANCE.DUREE_CONSERVATION', 'NYC_TAXI.RAW.DRIVER_SHIFTS', 'TABLE') AS duree_conservation;
SELECT 'MARTS.DIM_DRIVER' AS objet,
 SYSTEM$GET_TAG('NYC_TAXI.GOUVERNANCE.SENSIBILITE', 'NYC_TAXI.MARTS.DIM_DRIVER', 'TABLE') AS sensibilite,
 SYSTEM$GET_TAG('NYC_TAXI.GOUVERNANCE.DUREE_CONSERVATION', 'NYC_TAXI.MARTS.DIM_DRIVER', 'TABLE') AS duree_conservation;
SELECT 'MARTS.MART_DRIVER_MONTHLY' AS objet,
 SYSTEM$GET_TAG('NYC_TAXI.GOUVERNANCE.SENSIBILITE', 'NYC_TAXI.MARTS.MART_DRIVER_MONTHLY', 'TABLE') AS sensibilite,
 SYSTEM$GET_TAG('NYC_TAXI.GOUVERNANCE.DUREE_CONSERVATION', 'NYC_TAXI.MARTS.MART_DRIVER_MONTHLY', 'TABLE') AS duree_conservation;
SELECT 'MARTS.DIM_DEPOT' AS objet,
 SYSTEM$GET_TAG('NYC_TAXI.GOUVERNANCE.SENSIBILITE', 'NYC_TAXI.MARTS.DIM_DEPOT', 'TABLE') AS sensibilite,
 SYSTEM$GET_TAG('NYC_TAXI.GOUVERNANCE.DUREE_CONSERVATION', 'NYC_TAXI.MARTS.DIM_DEPOT', 'TABLE') AS duree_conservation;

-- Aucun SELECT RH ne doit être accordé à GOUVERNANCE. Examiner aussi ses rôles hérités.
USE ROLE ACCOUNTADMIN;
SHOW GRANTS TO ROLE GOUVERNANCE;
SHOW GRANTS OF ROLE GOUVERNANCE;
SHOW GRANTS TO ROLE TRANSFORMER;
SHOW TAGS IN SCHEMA NYC_TAXI.GOUVERNANCE;
