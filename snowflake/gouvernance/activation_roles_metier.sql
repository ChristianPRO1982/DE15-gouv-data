-- Étape 5 : préparation locale ; validation effective à effectuer dans Snowsight.
-- Attendus : docs/ACCES.md. Aucun secret ni valeur personnelle dans les sorties.
-- Après contrôle des politiques ; aucune attribution si les 29 associations ne sont pas actives.
-- Ce contrôle d’attachement ne remplace pas les tests fonctionnels qui suivent.
USE SECONDARY ROLES NONE;
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE NYC_TAXI_WH;
EXECUTE IMMEDIATE $$
DECLARE
  incomplet EXCEPTION (-20003, 'Activation refusée : protections absentes ou inattendues ; exécuter verification_politiques.sql.');
  nb NUMBER;
  erreurs NUMBER;
  utilisateur_test VARCHAR;
  commande VARCHAR;
BEGIN
WITH attendus AS (
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
), actuels AS (
  SELECT objet,
         CASE WHEN policy_kind = 'ROW_ACCESS_POLICY'
              THEN REGEXP_REPLACE(UPPER(COALESCE(ref_arg_column_names, ref_column_name, '')), '[^A-Z0-9_]', '')
              ELSE ref_column_name END AS colonne,
         policy_kind AS genre, policy_db, policy_schema, policy_name AS politique,
         tag_name, policy_status
  FROM references_actuelles
), controle AS (
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
  FROM attendus e FULL OUTER JOIN actuels a
    ON a.objet = e.objet AND a.colonne = e.colonne AND a.genre = e.genre
)
SELECT COUNT(*), COALESCE(COUNT_IF(statut <> 'OK'), 0) INTO :nb, :erreurs FROM controle;
  IF (nb <> 29 OR erreurs <> 0) THEN
    RAISE incomplet;
  END IF;
  utilisateur_test := '"' || REPLACE(CURRENT_USER(), '"', '""') || '"';
  commande := 'GRANT ROLE RH_PAIE TO USER ' || utilisateur_test;
  EXECUTE IMMEDIATE :commande;
  commande := 'GRANT ROLE RESP_DEPOT_QUEENS TO USER ' || utilisateur_test;
  EXECUTE IMMEDIATE :commande;
  commande := 'GRANT ROLE RESP_DEPOT_BRONX TO USER ' || utilisateur_test;
  EXECUTE IMMEDIATE :commande;
  commande := 'GRANT ROLE ANALYSTE TO USER ' || utilisateur_test;
  EXECUTE IMMEDIATE :commande;
  RETURN 'Quatre rôles attribués à l’utilisateur courant ; tester un rôle principal à la fois.';
END;
$$;
