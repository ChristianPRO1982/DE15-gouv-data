-- À exécuter EN ENTIER après la reconstruction, puis après la rejouabilité.
-- Un seul tableau : cinq contrôles de métadonnées, sans ligne personnelle.
-- ACCOUNTADMIN dispose des droits APPLY nécessaires pour voir tous les attachements.
USE SECONDARY ROLES NONE;
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE NYC_TAXI_WH;
WITH tags_attendus AS (
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
    ('MARTS.MART_DRIVER_MONTHLY', 'DRIVER_NAME', 'nom'),
    ('RAW.DRIVERS', 'DEPOT', 'donnee_professionnelle'),
    ('RAW.DRIVERS', 'HIRE_DATE', 'donnee_professionnelle'),
    ('RAW.DRIVERS', 'END_DATE', 'donnee_professionnelle'),
    ('MARTS.DIM_DRIVER', 'DEPOT', 'donnee_professionnelle'),
    ('MARTS.DIM_DRIVER', 'HIRE_DATE', 'donnee_professionnelle'),
    ('MARTS.DIM_DRIVER', 'END_DATE', 'donnee_professionnelle'),
    ('MARTS.DIM_DRIVER', 'IS_ACTIVE', 'donnee_professionnelle'),
    ('MARTS.DIM_DRIVER', 'TENURE_YEARS', 'donnee_professionnelle'),
    ('RAW.DRIVER_SHIFTS', 'SHIFT_DATE', 'donnee_professionnelle'),
    ('RAW.DRIVER_SHIFTS', 'DEPOT', 'donnee_professionnelle'),
    ('RAW.DRIVER_SHIFTS', 'START_HOUR', 'donnee_professionnelle'),
    ('RAW.DRIVER_SHIFTS', 'HOURS_WORKED', 'donnee_professionnelle'),
    ('RAW.DRIVER_SHIFTS', 'TRIPS_COUNT', 'donnee_professionnelle'),
    ('RAW.DRIVER_SHIFTS', 'REVENUE_USD', 'donnee_professionnelle'),
    ('MARTS.MART_DRIVER_MONTHLY', 'ACTIVITY_MONTH', 'donnee_professionnelle'),
    ('MARTS.MART_DRIVER_MONTHLY', 'DEPOT', 'donnee_professionnelle'),
    ('MARTS.MART_DRIVER_MONTHLY', 'NB_SHIFTS', 'donnee_professionnelle'),
    ('MARTS.MART_DRIVER_MONTHLY', 'HOURS_WORKED', 'donnee_professionnelle'),
    ('MARTS.MART_DRIVER_MONTHLY', 'TRIPS_COUNT', 'donnee_professionnelle'),
    ('MARTS.MART_DRIVER_MONTHLY', 'REVENUE_USD', 'donnee_professionnelle')
), tags AS (
SELECT 'RAW.DRIVERS' AS objet, column_name, tag_database, tag_schema, tag_name, tag_value
FROM TABLE(NYC_TAXI.INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS('NYC_TAXI.RAW.DRIVERS', 'TABLE'))
UNION ALL
SELECT 'RAW.DRIVER_SHIFTS' AS objet, column_name, tag_database, tag_schema, tag_name, tag_value
FROM TABLE(NYC_TAXI.INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS('NYC_TAXI.RAW.DRIVER_SHIFTS', 'TABLE'))
UNION ALL
SELECT 'MARTS.DIM_DRIVER' AS objet, column_name, tag_database, tag_schema, tag_name, tag_value
FROM TABLE(NYC_TAXI.INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS('NYC_TAXI.MARTS.DIM_DRIVER', 'TABLE'))
UNION ALL
SELECT 'MARTS.MART_DRIVER_MONTHLY' AS objet, column_name, tag_database, tag_schema, tag_name, tag_value
FROM TABLE(NYC_TAXI.INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS('NYC_TAXI.MARTS.MART_DRIVER_MONTHLY', 'TABLE'))
UNION ALL
SELECT 'MARTS.DIM_DEPOT' AS objet, column_name, tag_database, tag_schema, tag_name, tag_value
FROM TABLE(NYC_TAXI.INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS('NYC_TAXI.MARTS.DIM_DEPOT', 'TABLE'))
), tags_personnels_actuels AS (
  SELECT objet, column_name AS colonne, tag_value AS valeur
  FROM tags WHERE tag_database = 'NYC_TAXI' AND tag_schema = 'GOUVERNANCE'
    AND tag_name = 'DONNEE_PERSONNELLE'
), controle_tags AS (
  SELECT CASE WHEN e.objet IS NOT NULL AND a.valeur = e.valeur THEN 'OK' ELSE 'ECART' END AS statut
  FROM tags_attendus e FULL OUTER JOIN tags_personnels_actuels a
    ON a.objet = e.objet AND a.colonne = e.colonne
), tags_tables AS (
  SELECT 'RAW.DRIVERS' AS objet,
    SYSTEM$GET_TAG('NYC_TAXI.GOUVERNANCE.SENSIBILITE', 'NYC_TAXI.RAW.DRIVERS', 'TABLE') AS sensibilite,
    SYSTEM$GET_TAG('NYC_TAXI.GOUVERNANCE.DUREE_CONSERVATION', 'NYC_TAXI.RAW.DRIVERS', 'TABLE') AS duree
  UNION ALL
  SELECT 'RAW.DRIVER_SHIFTS' AS objet,
    SYSTEM$GET_TAG('NYC_TAXI.GOUVERNANCE.SENSIBILITE', 'NYC_TAXI.RAW.DRIVER_SHIFTS', 'TABLE') AS sensibilite,
    SYSTEM$GET_TAG('NYC_TAXI.GOUVERNANCE.DUREE_CONSERVATION', 'NYC_TAXI.RAW.DRIVER_SHIFTS', 'TABLE') AS duree
  UNION ALL
  SELECT 'MARTS.DIM_DRIVER' AS objet,
    SYSTEM$GET_TAG('NYC_TAXI.GOUVERNANCE.SENSIBILITE', 'NYC_TAXI.MARTS.DIM_DRIVER', 'TABLE') AS sensibilite,
    SYSTEM$GET_TAG('NYC_TAXI.GOUVERNANCE.DUREE_CONSERVATION', 'NYC_TAXI.MARTS.DIM_DRIVER', 'TABLE') AS duree
  UNION ALL
  SELECT 'MARTS.MART_DRIVER_MONTHLY' AS objet,
    SYSTEM$GET_TAG('NYC_TAXI.GOUVERNANCE.SENSIBILITE', 'NYC_TAXI.MARTS.MART_DRIVER_MONTHLY', 'TABLE') AS sensibilite,
    SYSTEM$GET_TAG('NYC_TAXI.GOUVERNANCE.DUREE_CONSERVATION', 'NYC_TAXI.MARTS.MART_DRIVER_MONTHLY', 'TABLE') AS duree
  UNION ALL
  SELECT 'MARTS.DIM_DEPOT' AS objet,
    SYSTEM$GET_TAG('NYC_TAXI.GOUVERNANCE.SENSIBILITE', 'NYC_TAXI.MARTS.DIM_DEPOT', 'TABLE') AS sensibilite,
    SYSTEM$GET_TAG('NYC_TAXI.GOUVERNANCE.DUREE_CONSERVATION', 'NYC_TAXI.MARTS.DIM_DEPOT', 'TABLE') AS duree
), controle_tags_tables AS (
 SELECT CASE
   WHEN objet = 'MARTS.DIM_DEPOT' AND sensibilite = 'interne'
     AND duree = 'sans limite : référentiel de l''entreprise' THEN 'OK'
   WHEN objet <> 'MARTS.DIM_DEPOT' AND sensibilite = 'confidentiel'
     AND duree = '5 ans après la fin du contrat du chauffeur ; application technique au jour 3' THEN 'OK'
   ELSE 'ECART' END AS statut
 FROM tags_tables
), politiques_attendues AS (
  SELECT column1 AS objet, column2 AS colonne, column3 AS genre, column4 AS politique
  FROM VALUES
    ('RAW.DRIVERS', 'DRIVER_ID', 'MASKING_POLICY', 'MASK_RAW_VARCHAR'),
    ('RAW.DRIVERS', 'FIRST_NAME', 'MASKING_POLICY', 'MASK_RAW_VARCHAR'),
    ('RAW.DRIVERS', 'LAST_NAME', 'MASKING_POLICY', 'MASK_RAW_VARCHAR'),
    ('RAW.DRIVERS', 'EMAIL', 'MASKING_POLICY', 'MASK_RAW_VARCHAR'),
    ('RAW.DRIVERS', 'PHONE', 'MASKING_POLICY', 'MASK_RAW_VARCHAR'),
    ('RAW.DRIVERS', 'BIRTH_DATE', 'MASKING_POLICY', 'MASK_RAW_DATE'),
    ('RAW.DRIVERS', 'TLC_LICENSE_NUMBER', 'MASKING_POLICY', 'MASK_RAW_VARCHAR'),
    ('RAW.DRIVERS', 'DEPOT', 'MASKING_POLICY', 'MASK_RAW_VARCHAR'),
    ('RAW.DRIVERS', 'HIRE_DATE', 'MASKING_POLICY', 'MASK_RAW_DATE'),
    ('RAW.DRIVERS', 'END_DATE', 'MASKING_POLICY', 'MASK_RAW_DATE'),
    ('RAW.DRIVER_SHIFTS', 'SHIFT_ID', 'MASKING_POLICY', 'MASK_RAW_VARCHAR'),
    ('RAW.DRIVER_SHIFTS', 'DRIVER_ID', 'MASKING_POLICY', 'MASK_RAW_VARCHAR'),
    ('RAW.DRIVER_SHIFTS', 'SHIFT_DATE', 'MASKING_POLICY', 'MASK_RAW_DATE'),
    ('RAW.DRIVER_SHIFTS', 'DEPOT', 'MASKING_POLICY', 'MASK_RAW_VARCHAR'),
    ('RAW.DRIVER_SHIFTS', 'START_HOUR', 'MASKING_POLICY', 'MASK_RAW_NUMBER'),
    ('RAW.DRIVER_SHIFTS', 'HOURS_WORKED', 'MASKING_POLICY', 'MASK_RAW_FLOAT'),
    ('RAW.DRIVER_SHIFTS', 'TRIPS_COUNT', 'MASKING_POLICY', 'MASK_RAW_NUMBER'),
    ('RAW.DRIVER_SHIFTS', 'REVENUE_USD', 'MASKING_POLICY', 'MASK_RAW_FLOAT'),
    ('MARTS.DIM_DRIVER', 'DRIVER_ID', 'MASKING_POLICY', 'MASK_DRIVER_ID'),
    ('MARTS.DIM_DRIVER', 'FIRST_NAME', 'MASKING_POLICY', 'MASK_CONTACT'),
    ('MARTS.DIM_DRIVER', 'LAST_NAME', 'MASKING_POLICY', 'MASK_CONTACT'),
    ('MARTS.DIM_DRIVER', 'EMAIL', 'MASKING_POLICY', 'MASK_PAIE'),
    ('MARTS.DIM_DRIVER', 'PHONE', 'MASKING_POLICY', 'MASK_CONTACT'),
    ('MARTS.DIM_DRIVER', 'BIRTH_DATE', 'MASKING_POLICY', 'MASK_NAISSANCE'),
    ('MARTS.DIM_DRIVER', 'TLC_LICENSE_NUMBER', 'MASKING_POLICY', 'MASK_PAIE'),
    ('MARTS.MART_DRIVER_MONTHLY', 'DRIVER_ID', 'MASKING_POLICY', 'MASK_DRIVER_ID'),
    ('MARTS.MART_DRIVER_MONTHLY', 'DRIVER_NAME', 'MASKING_POLICY', 'MASK_CONTACT'),
    ('MARTS.DIM_DRIVER', 'DEPOT', 'ROW_ACCESS_POLICY', 'RAP_DEPOT'),
    ('MARTS.MART_DRIVER_MONTHLY', 'DEPOT', 'ROW_ACCESS_POLICY', 'RAP_DEPOT')
), references_actuelles AS (
SELECT 'RAW.DRIVERS' AS objet, p.* FROM TABLE(NYC_TAXI.INFORMATION_SCHEMA.POLICY_REFERENCES(
    REF_ENTITY_NAME => 'NYC_TAXI.RAW.DRIVERS', REF_ENTITY_DOMAIN => 'TABLE')) p
UNION ALL
SELECT 'RAW.DRIVER_SHIFTS' AS objet, p.* FROM TABLE(NYC_TAXI.INFORMATION_SCHEMA.POLICY_REFERENCES(
    REF_ENTITY_NAME => 'NYC_TAXI.RAW.DRIVER_SHIFTS', REF_ENTITY_DOMAIN => 'TABLE')) p
UNION ALL
SELECT 'MARTS.DIM_DRIVER' AS objet, p.* FROM TABLE(NYC_TAXI.INFORMATION_SCHEMA.POLICY_REFERENCES(
    REF_ENTITY_NAME => 'NYC_TAXI.MARTS.DIM_DRIVER', REF_ENTITY_DOMAIN => 'TABLE')) p
UNION ALL
SELECT 'MARTS.MART_DRIVER_MONTHLY' AS objet, p.* FROM TABLE(NYC_TAXI.INFORMATION_SCHEMA.POLICY_REFERENCES(
    REF_ENTITY_NAME => 'NYC_TAXI.MARTS.MART_DRIVER_MONTHLY', REF_ENTITY_DOMAIN => 'TABLE')) p
UNION ALL
SELECT 'MARTS.DIM_DEPOT' AS objet, p.* FROM TABLE(NYC_TAXI.INFORMATION_SCHEMA.POLICY_REFERENCES(
    REF_ENTITY_NAME => 'NYC_TAXI.MARTS.DIM_DEPOT', REF_ENTITY_DOMAIN => 'TABLE')) p
), politiques_actuelles AS (
  SELECT objet,
         CASE WHEN policy_kind = 'ROW_ACCESS_POLICY'
              THEN REGEXP_REPLACE(UPPER(COALESCE(ref_arg_column_names, ref_column_name, '')), '[^A-Z0-9_]', '')
              ELSE ref_column_name END AS colonne,
         policy_kind AS genre, policy_db, policy_schema, policy_name AS politique,
         tag_name, policy_status
  FROM references_actuelles
), controle_politiques AS (
  SELECT COALESCE(e.objet, a.objet) AS objet,
         COALESCE(e.colonne, a.colonne) AS colonne,
         COALESCE(e.genre, a.genre) AS genre,
         e.politique AS politique_attendue, a.politique AS politique_obtenue,
         CASE WHEN e.politique IS NOT NULL AND a.politique = e.politique
                   AND a.policy_db = 'NYC_TAXI' AND a.policy_schema = 'GOUVERNANCE'
                   AND a.tag_name IS NULL
                   AND (a.policy_status = 'ACTIVE'
                        OR (a.genre = 'ROW_ACCESS_POLICY' AND a.policy_status IS NULL))
              THEN 'OK' ELSE 'ECART' END AS statut
  FROM politiques_attendues e FULL OUTER JOIN politiques_actuelles a
    ON a.objet = e.objet AND a.colonne = e.colonne AND a.genre = e.genre
), synthese AS (
  SELECT 1 AS ordre, 'TABLES_DECRITES' AS controle, 5 AS attendu,
         COALESCE(COUNT_IF(NULLIF(TRIM(comment), '') IS NOT NULL), 0) AS obtenu,
         ABS(5 - COALESCE(COUNT_IF(NULLIF(TRIM(comment), '') IS NOT NULL), 0)) AS nb_ecarts
  FROM NYC_TAXI.INFORMATION_SCHEMA.TABLES
  WHERE (table_schema = 'RAW' AND table_name IN ('DRIVERS', 'DRIVER_SHIFTS'))
     OR (table_schema = 'MARTS' AND table_name IN ('DIM_DRIVER', 'MART_DRIVER_MONTHLY', 'DIM_DEPOT'))
  UNION ALL
  SELECT 2, 'COLONNES_DECRITES', 28,
         COALESCE(COUNT_IF(NULLIF(TRIM(comment), '') IS NOT NULL), 0),
         ABS(28 - COALESCE(COUNT_IF(NULLIF(TRIM(comment), '') IS NOT NULL), 0))
  FROM NYC_TAXI.INFORMATION_SCHEMA.COLUMNS
  WHERE (table_schema = 'RAW' AND table_name = 'DRIVERS')
     OR (table_schema = 'MARTS' AND table_name IN ('DIM_DRIVER', 'DIM_DEPOT'))
  UNION ALL
  SELECT 3, 'TABLES_TAGUEES', 5, COALESCE(COUNT_IF(statut = 'OK'), 0),
         COALESCE(COUNT_IF(statut <> 'OK'), 0) FROM controle_tags_tables
  UNION ALL
  SELECT 4, 'TAGS_PERSONNELS', 38, COALESCE(COUNT_IF(statut = 'OK'), 0),
         COALESCE(COUNT_IF(statut <> 'OK'), 0) FROM controle_tags
  UNION ALL
  SELECT 5, 'POLITIQUES_ATTACHEES', 29, COALESCE(COUNT_IF(statut = 'OK'), 0),
         COALESCE(COUNT_IF(statut <> 'OK'), 0) FROM controle_politiques
)
SELECT controle, attendu, obtenu, nb_ecarts,
       IFF(obtenu = attendu AND nb_ecarts = 0, 'OK', 'ECART') AS statut
FROM synthese ORDER BY ordre;
