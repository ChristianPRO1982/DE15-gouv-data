-- Étape 5 : tests à exécuter dans Snowsight ; ne pas inscrire de résultat supposé.
-- Sorties : statuts et volumes uniquement ; aucune valeur personnelle ni empreinte affichée.
-- Exécuter B0 puis B1...B8 séparément, dans LA MÊME SESSION (variables $e5_*).
-- En cas de variable absente : reprendre B0, puis le bloc voulu.
-- Contrôles de valeurs sur toutes les lignes ; D0003 sert de témoin supplémentaire.
-- B0 : références calculées par TRANSFORMER, jamais affichées.
USE SECONDARY ROLES NONE;
USE ROLE TRANSFORMER;
USE WAREHOUSE NYC_TAXI_WH;
SET (e5_dim_paie, e5_temoin_dim_paie, e5_mensuel_paie, e5_temoin_mensuel_paie, e5_dim_queens, e5_temoin_dim_queens, e5_mensuel_queens, e5_temoin_mensuel_queens, e5_dim_bronx, e5_temoin_dim_bronx, e5_mensuel_bronx, e5_temoin_mensuel_bronx, e5_dim_analyste, e5_temoin_dim_analyste, e5_mensuel_analyste, e5_temoin_mensuel_analyste) = (
  SELECT
    (SELECT HASH_AGG(HASH(driver_id, first_name, last_name, email, phone, birth_date, tlc_license_number, depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER),
    (SELECT HASH_AGG(HASH(driver_id, first_name, last_name, email, phone, birth_date, tlc_license_number, depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE driver_id = 'D0003'),
    (SELECT HASH_AGG(HASH(activity_month, driver_id, driver_name, depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY),
    (SELECT HASH_AGG(HASH(activity_month, driver_id, driver_name, depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY WHERE driver_id = 'D0003'),
    (SELECT HASH_AGG(HASH(driver_id, first_name, last_name, IFF(email IS NULL, NULL, '*****'), phone, NULL::DATE, IFF(tlc_license_number IS NULL, NULL, '*****'), depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE depot = 'Queens'),
    (SELECT HASH_AGG(HASH(driver_id, first_name, last_name, IFF(email IS NULL, NULL, '*****'), phone, NULL::DATE, IFF(tlc_license_number IS NULL, NULL, '*****'), depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE driver_id = 'D0003' AND depot = 'Queens'),
    (SELECT HASH_AGG(HASH(activity_month, driver_id, driver_name, depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY WHERE depot = 'Queens'),
    (SELECT HASH_AGG(HASH(activity_month, driver_id, driver_name, depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY WHERE driver_id = 'D0003' AND depot = 'Queens'),
    (SELECT HASH_AGG(HASH(driver_id, first_name, last_name, IFF(email IS NULL, NULL, '*****'), phone, NULL::DATE, IFF(tlc_license_number IS NULL, NULL, '*****'), depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE depot = 'Bronx'),
    (SELECT HASH_AGG(HASH(driver_id, first_name, last_name, IFF(email IS NULL, NULL, '*****'), phone, NULL::DATE, IFF(tlc_license_number IS NULL, NULL, '*****'), depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE driver_id = 'D0003' AND depot = 'Bronx'),
    (SELECT HASH_AGG(HASH(activity_month, driver_id, driver_name, depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY WHERE depot = 'Bronx'),
    (SELECT HASH_AGG(HASH(activity_month, driver_id, driver_name, depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY WHERE driver_id = 'D0003' AND depot = 'Bronx'),
    (SELECT HASH_AGG(HASH(driver_id, IFF(first_name IS NULL, NULL, '*****'), IFF(last_name IS NULL, NULL, '*****'), IFF(email IS NULL, NULL, '*****'), IFF(phone IS NULL, NULL, '*****'), DATE_TRUNC('year', birth_date)::DATE, IFF(tlc_license_number IS NULL, NULL, '*****'), depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER),
    (SELECT HASH_AGG(HASH(driver_id, IFF(first_name IS NULL, NULL, '*****'), IFF(last_name IS NULL, NULL, '*****'), IFF(email IS NULL, NULL, '*****'), IFF(phone IS NULL, NULL, '*****'), DATE_TRUNC('year', birth_date)::DATE, IFF(tlc_license_number IS NULL, NULL, '*****'), depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE driver_id = 'D0003'),
    (SELECT HASH_AGG(HASH(activity_month, driver_id, IFF(driver_name IS NULL, NULL, '*****'), depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY),
    (SELECT HASH_AGG(HASH(activity_month, driver_id, IFF(driver_name IS NULL, NULL, '*****'), depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY WHERE driver_id = 'D0003')
);
SELECT 'B0' AS bloc, IFF((SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER) = 400 AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) = 914, 'OK', 'ECART') AS volumes_reference;

-- B1 : RH_PAIE. Attendu 400 chauffeurs / 914 lignes mensuelles / 3 dépôts référentiels.
USE SECONDARY ROLES NONE;
USE ROLE RH_PAIE;
USE WAREHOUSE NYC_TAXI_WH;
SELECT CURRENT_ROLE() AS role_actif,
  (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER) AS chauffeurs,
  (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) AS lignes_mensuelles,
  IFF((SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER) = 400
      AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) = 914
      AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DEPOT) = 3, 'OK', 'ECART') AS volumes,
  IFF((SELECT HASH_AGG(HASH(driver_id, first_name, last_name, email, phone, birth_date, tlc_license_number, depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER) = $e5_dim_paie
      AND (SELECT HASH_AGG(HASH(activity_month, driver_id, driver_name, depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) = $e5_mensuel_paie, 'OK', 'ECART') AS valeurs_et_perimetre;
SELECT IFF(
  (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE driver_id = 'D0003') = 1
  AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY WHERE driver_id = 'D0003') = 3
  AND (SELECT HASH_AGG(HASH(driver_id, first_name, last_name, email, phone, birth_date, tlc_license_number, depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE driver_id = 'D0003') = $e5_temoin_dim_paie
  AND (SELECT HASH_AGG(HASH(activity_month, driver_id, driver_name, depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY WHERE driver_id = 'D0003') = $e5_temoin_mensuel_paie,
  'OK', 'ECART') AS temoin_valeurs_sans_affichage;
-- SELECT COUNT(*) permet de tester les droits sans afficher de valeur personnelle.
EXECUTE IMMEDIATE $$
DECLARE
  commande VARCHAR;
  resultats ARRAY DEFAULT ARRAY_CONSTRUCT();
  c CURSOR FOR SELECT column1 AS objet FROM VALUES
    ('NYC_TAXI.RAW.DRIVERS'),
    ('NYC_TAXI.RAW.DRIVER_SHIFTS'),
    ('NYC_TAXI.STAGING.STG_RH__DRIVERS'),
    ('NYC_TAXI.STAGING.STG_RH__DRIVER_SHIFTS'),
    ('NYC_TAXI.GOUVERNANCE.ACCES_DEPOT');
BEGIN
  FOR r IN c DO
    commande := 'SELECT COUNT(*) FROM ' || r.objet;
    BEGIN
      EXECUTE IMMEDIATE :commande;
      resultats := ARRAY_APPEND(resultats, OBJECT_CONSTRUCT('objet', r.objet, 'statut', 'ECART : lecture autorisée'));
    EXCEPTION
      WHEN STATEMENT_ERROR THEN
        IF (SQLSTATE IN ('42501', '42S02')) THEN
          resultats := ARRAY_APPEND(resultats, OBJECT_CONSTRUCT('objet', r.objet, 'statut', 'OK : lecture refusée'));
        ELSE
          RAISE; -- une erreur de syntaxe ou d’exécution n’est pas une preuve de restriction
        END IF;
    END;
  END FOR;
  RETURN TO_JSON(resultats);
END;
$$;

-- B2 : RESP_DEPOT_QUEENS. Attendu 161 chauffeurs / 365 lignes mensuelles / 3 dépôts référentiels.
USE SECONDARY ROLES NONE;
USE ROLE RESP_DEPOT_QUEENS;
USE WAREHOUSE NYC_TAXI_WH;
SELECT CURRENT_ROLE() AS role_actif,
  (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER) AS chauffeurs,
  (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) AS lignes_mensuelles,
  IFF((SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER) = 161
      AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) = 365
      AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DEPOT) = 3, 'OK', 'ECART') AS volumes,
  IFF((SELECT HASH_AGG(HASH(driver_id, first_name, last_name, email, phone, birth_date, tlc_license_number, depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER) = $e5_dim_queens
      AND (SELECT HASH_AGG(HASH(activity_month, driver_id, driver_name, depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) = $e5_mensuel_queens, 'OK', 'ECART') AS valeurs_et_perimetre;
SELECT IFF((SELECT COALESCE(COUNT_IF(depot <> 'Queens' OR depot IS NULL), 0) FROM NYC_TAXI.MARTS.DIM_DRIVER) = 0
 AND (SELECT COALESCE(COUNT_IF(depot <> 'Queens' OR depot IS NULL), 0) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) = 0, 'OK', 'ECART') AS depot_exclusif;
SELECT IFF(
  (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE driver_id = 'D0003') = 1
  AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY WHERE driver_id = 'D0003') = 3
  AND (SELECT HASH_AGG(HASH(driver_id, first_name, last_name, email, phone, birth_date, tlc_license_number, depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE driver_id = 'D0003') = $e5_temoin_dim_queens
  AND (SELECT HASH_AGG(HASH(activity_month, driver_id, driver_name, depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY WHERE driver_id = 'D0003') = $e5_temoin_mensuel_queens,
  'OK', 'ECART') AS temoin_valeurs_sans_affichage;
-- SELECT COUNT(*) permet de tester les droits sans afficher de valeur personnelle.
EXECUTE IMMEDIATE $$
DECLARE
  commande VARCHAR;
  resultats ARRAY DEFAULT ARRAY_CONSTRUCT();
  c CURSOR FOR SELECT column1 AS objet FROM VALUES
    ('NYC_TAXI.RAW.DRIVERS'),
    ('NYC_TAXI.RAW.DRIVER_SHIFTS'),
    ('NYC_TAXI.STAGING.STG_RH__DRIVERS'),
    ('NYC_TAXI.STAGING.STG_RH__DRIVER_SHIFTS'),
    ('NYC_TAXI.GOUVERNANCE.ACCES_DEPOT');
BEGIN
  FOR r IN c DO
    commande := 'SELECT COUNT(*) FROM ' || r.objet;
    BEGIN
      EXECUTE IMMEDIATE :commande;
      resultats := ARRAY_APPEND(resultats, OBJECT_CONSTRUCT('objet', r.objet, 'statut', 'ECART : lecture autorisée'));
    EXCEPTION
      WHEN STATEMENT_ERROR THEN
        IF (SQLSTATE IN ('42501', '42S02')) THEN
          resultats := ARRAY_APPEND(resultats, OBJECT_CONSTRUCT('objet', r.objet, 'statut', 'OK : lecture refusée'));
        ELSE
          RAISE; -- une erreur de syntaxe ou d’exécution n’est pas une preuve de restriction
        END IF;
    END;
  END FOR;
  RETURN TO_JSON(resultats);
END;
$$;

-- B3 : RESP_DEPOT_BRONX. Attendu 122 chauffeurs / 290 lignes mensuelles / 3 dépôts référentiels.
USE SECONDARY ROLES NONE;
USE ROLE RESP_DEPOT_BRONX;
USE WAREHOUSE NYC_TAXI_WH;
SELECT CURRENT_ROLE() AS role_actif,
  (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER) AS chauffeurs,
  (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) AS lignes_mensuelles,
  IFF((SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER) = 122
      AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) = 290
      AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DEPOT) = 3, 'OK', 'ECART') AS volumes,
  IFF((SELECT HASH_AGG(HASH(driver_id, first_name, last_name, email, phone, birth_date, tlc_license_number, depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER) = $e5_dim_bronx
      AND (SELECT HASH_AGG(HASH(activity_month, driver_id, driver_name, depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) = $e5_mensuel_bronx, 'OK', 'ECART') AS valeurs_et_perimetre;
SELECT IFF((SELECT COALESCE(COUNT_IF(depot <> 'Bronx' OR depot IS NULL), 0) FROM NYC_TAXI.MARTS.DIM_DRIVER) = 0
 AND (SELECT COALESCE(COUNT_IF(depot <> 'Bronx' OR depot IS NULL), 0) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) = 0, 'OK', 'ECART') AS depot_exclusif;
SELECT IFF(
  (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE driver_id = 'D0003') = 0
  AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY WHERE driver_id = 'D0003') = 0
  AND (SELECT HASH_AGG(HASH(driver_id, first_name, last_name, email, phone, birth_date, tlc_license_number, depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE driver_id = 'D0003') = $e5_temoin_dim_bronx
  AND (SELECT HASH_AGG(HASH(activity_month, driver_id, driver_name, depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY WHERE driver_id = 'D0003') = $e5_temoin_mensuel_bronx,
  'OK', 'ECART') AS temoin_valeurs_sans_affichage;
-- SELECT COUNT(*) permet de tester les droits sans afficher de valeur personnelle.
EXECUTE IMMEDIATE $$
DECLARE
  commande VARCHAR;
  resultats ARRAY DEFAULT ARRAY_CONSTRUCT();
  c CURSOR FOR SELECT column1 AS objet FROM VALUES
    ('NYC_TAXI.RAW.DRIVERS'),
    ('NYC_TAXI.RAW.DRIVER_SHIFTS'),
    ('NYC_TAXI.STAGING.STG_RH__DRIVERS'),
    ('NYC_TAXI.STAGING.STG_RH__DRIVER_SHIFTS'),
    ('NYC_TAXI.GOUVERNANCE.ACCES_DEPOT');
BEGIN
  FOR r IN c DO
    commande := 'SELECT COUNT(*) FROM ' || r.objet;
    BEGIN
      EXECUTE IMMEDIATE :commande;
      resultats := ARRAY_APPEND(resultats, OBJECT_CONSTRUCT('objet', r.objet, 'statut', 'ECART : lecture autorisée'));
    EXCEPTION
      WHEN STATEMENT_ERROR THEN
        IF (SQLSTATE IN ('42501', '42S02')) THEN
          resultats := ARRAY_APPEND(resultats, OBJECT_CONSTRUCT('objet', r.objet, 'statut', 'OK : lecture refusée'));
        ELSE
          RAISE; -- une erreur de syntaxe ou d’exécution n’est pas une preuve de restriction
        END IF;
    END;
  END FOR;
  RETURN TO_JSON(resultats);
END;
$$;

-- B4 : ANALYSTE. Attendu 400 chauffeurs / 914 lignes mensuelles / 3 dépôts référentiels.
USE SECONDARY ROLES NONE;
USE ROLE ANALYSTE;
USE WAREHOUSE NYC_TAXI_WH;
SELECT CURRENT_ROLE() AS role_actif,
  (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER) AS chauffeurs,
  (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) AS lignes_mensuelles,
  IFF((SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER) = 400
      AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) = 914
      AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DEPOT) = 3, 'OK', 'ECART') AS volumes,
  IFF((SELECT HASH_AGG(HASH(driver_id, first_name, last_name, email, phone, birth_date, tlc_license_number, depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER) = $e5_dim_analyste
      AND (SELECT HASH_AGG(HASH(activity_month, driver_id, driver_name, depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) = $e5_mensuel_analyste, 'OK', 'ECART') AS valeurs_et_perimetre;
SELECT IFF(
  (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE driver_id = 'D0003') = 1
  AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY WHERE driver_id = 'D0003') = 3
  AND (SELECT HASH_AGG(HASH(driver_id, first_name, last_name, email, phone, birth_date, tlc_license_number, depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE driver_id = 'D0003') = $e5_temoin_dim_analyste
  AND (SELECT HASH_AGG(HASH(activity_month, driver_id, driver_name, depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY WHERE driver_id = 'D0003') = $e5_temoin_mensuel_analyste,
  'OK', 'ECART') AS temoin_valeurs_sans_affichage;
-- SELECT COUNT(*) permet de tester les droits sans afficher de valeur personnelle.
EXECUTE IMMEDIATE $$
DECLARE
  commande VARCHAR;
  resultats ARRAY DEFAULT ARRAY_CONSTRUCT();
  c CURSOR FOR SELECT column1 AS objet FROM VALUES
    ('NYC_TAXI.RAW.DRIVERS'),
    ('NYC_TAXI.RAW.DRIVER_SHIFTS'),
    ('NYC_TAXI.STAGING.STG_RH__DRIVERS'),
    ('NYC_TAXI.STAGING.STG_RH__DRIVER_SHIFTS'),
    ('NYC_TAXI.GOUVERNANCE.ACCES_DEPOT');
BEGIN
  FOR r IN c DO
    commande := 'SELECT COUNT(*) FROM ' || r.objet;
    BEGIN
      EXECUTE IMMEDIATE :commande;
      resultats := ARRAY_APPEND(resultats, OBJECT_CONSTRUCT('objet', r.objet, 'statut', 'ECART : lecture autorisée'));
    EXCEPTION
      WHEN STATEMENT_ERROR THEN
        IF (SQLSTATE IN ('42501', '42S02')) THEN
          resultats := ARRAY_APPEND(resultats, OBJECT_CONSTRUCT('objet', r.objet, 'statut', 'OK : lecture refusée'));
        ELSE
          RAISE; -- une erreur de syntaxe ou d’exécution n’est pas une preuve de restriction
        END IF;
    END;
  END FOR;
  RETURN TO_JSON(resultats);
END;
$$;

-- B5 : TRANSFORMER. Attendu 400 chauffeurs / 914 lignes mensuelles / 3 dépôts référentiels.
USE SECONDARY ROLES NONE;
USE ROLE TRANSFORMER;
USE WAREHOUSE NYC_TAXI_WH;
SELECT CURRENT_ROLE() AS role_actif,
  (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER) AS chauffeurs,
  (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) AS lignes_mensuelles,
  IFF((SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER) = 400
      AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) = 914
      AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DEPOT) = 3, 'OK', 'ECART') AS volumes,
  IFF((SELECT HASH_AGG(HASH(driver_id, first_name, last_name, email, phone, birth_date, tlc_license_number, depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER) = $e5_dim_paie
      AND (SELECT HASH_AGG(HASH(activity_month, driver_id, driver_name, depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) = $e5_mensuel_paie, 'OK', 'ECART') AS valeurs_et_perimetre;
SELECT IFF(
  (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE driver_id = 'D0003') = 1
  AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY WHERE driver_id = 'D0003') = 3
  AND (SELECT HASH_AGG(HASH(driver_id, first_name, last_name, email, phone, birth_date, tlc_license_number, depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE driver_id = 'D0003') = $e5_temoin_dim_paie
  AND (SELECT HASH_AGG(HASH(activity_month, driver_id, driver_name, depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY WHERE driver_id = 'D0003') = $e5_temoin_mensuel_paie,
  'OK', 'ECART') AS temoin_valeurs_sans_affichage;
SELECT IFF(
  (SELECT COUNT(*) FROM NYC_TAXI.RAW.DRIVERS) = 400
  AND (SELECT COUNT(*) FROM NYC_TAXI.RAW.DRIVER_SHIFTS) = 25951
  AND (SELECT COUNT(*) FROM NYC_TAXI.STAGING.STG_RH__DRIVERS) = 400
  AND (SELECT COUNT(*) FROM NYC_TAXI.STAGING.STG_RH__DRIVER_SHIFTS) = 25933,
  'OK', 'ECART') AS sources_accessibles;
-- Les anomalies du CSV sont conservées ; chercher les masques, pas imposer une qualité non prévue.
SELECT IFF(COUNT(*) = 1 AND COUNT_IF(first_name IS NOT NULL AND first_name <> '*****'
  AND last_name IS NOT NULL AND last_name <> '*****' AND email LIKE '%@%'
  AND phone IS NOT NULL AND phone <> '*****' AND birth_date IS NOT NULL
  AND tlc_license_number IS NOT NULL AND tlc_license_number <> '*****') = 1,
  'OK', 'ECART') AS temoin_source_en_clair
FROM NYC_TAXI.RAW.DRIVERS WHERE driver_id = 'D0003';
-- SELECT COUNT(*) permet de tester les droits sans afficher de valeur personnelle.
EXECUTE IMMEDIATE $$
DECLARE
  commande VARCHAR;
  resultats ARRAY DEFAULT ARRAY_CONSTRUCT();
  c CURSOR FOR SELECT column1 AS objet FROM VALUES
    ('NYC_TAXI.GOUVERNANCE.ACCES_DEPOT');
BEGIN
  FOR r IN c DO
    commande := 'SELECT COUNT(*) FROM ' || r.objet;
    BEGIN
      EXECUTE IMMEDIATE :commande;
      resultats := ARRAY_APPEND(resultats, OBJECT_CONSTRUCT('objet', r.objet, 'statut', 'ECART : lecture autorisée'));
    EXCEPTION
      WHEN STATEMENT_ERROR THEN
        IF (SQLSTATE IN ('42501', '42S02')) THEN
          resultats := ARRAY_APPEND(resultats, OBJECT_CONSTRUCT('objet', r.objet, 'statut', 'OK : lecture refusée'));
        ELSE
          RAISE; -- une erreur de syntaxe ou d’exécution n’est pas une preuve de restriction
        END IF;
    END;
  END FOR;
  RETURN TO_JSON(resultats);
END;
$$;

-- B6 : GOUVERNANCE, attendu sept refus SELECT RH.
USE SECONDARY ROLES NONE;
USE ROLE GOUVERNANCE;
USE WAREHOUSE NYC_TAXI_WH;
-- SELECT COUNT(*) permet de tester les droits sans afficher de valeur personnelle.
EXECUTE IMMEDIATE $$
DECLARE
  commande VARCHAR;
  resultats ARRAY DEFAULT ARRAY_CONSTRUCT();
  c CURSOR FOR SELECT column1 AS objet FROM VALUES
    ('NYC_TAXI.RAW.DRIVERS'),
    ('NYC_TAXI.RAW.DRIVER_SHIFTS'),
    ('NYC_TAXI.STAGING.STG_RH__DRIVERS'),
    ('NYC_TAXI.STAGING.STG_RH__DRIVER_SHIFTS'),
    ('NYC_TAXI.MARTS.DIM_DRIVER'),
    ('NYC_TAXI.MARTS.MART_DRIVER_MONTHLY'),
    ('NYC_TAXI.MARTS.DIM_DEPOT');
BEGIN
  FOR r IN c DO
    commande := 'SELECT COUNT(*) FROM ' || r.objet;
    BEGIN
      EXECUTE IMMEDIATE :commande;
      resultats := ARRAY_APPEND(resultats, OBJECT_CONSTRUCT('objet', r.objet, 'statut', 'ECART : lecture autorisée'));
    EXCEPTION
      WHEN STATEMENT_ERROR THEN
        IF (SQLSTATE IN ('42501', '42S02')) THEN
          resultats := ARRAY_APPEND(resultats, OBJECT_CONSTRUCT('objet', r.objet, 'statut', 'OK : lecture refusée'));
        ELSE
          RAISE; -- une erreur de syntaxe ou d’exécution n’est pas une preuve de restriction
        END IF;
    END;
  END FOR;
  RETURN TO_JSON(resultats);
END;
$$;

-- B7 : ACCOUNTADMIN : MARTS RH vides et RAW/STAGING personnels masqués.
USE SECONDARY ROLES NONE;
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE NYC_TAXI_WH;
SELECT IFF((SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER) = 0
 AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) = 0
 AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DEPOT) = 3, 'OK', 'ECART') AS perimetre_administrateur;
SELECT 'RAW.DRIVERS' AS objet, IFF(COUNT(*) = 400
 AND COALESCE(COUNT_IF((driver_id IS NOT NULL AND driver_id <> '*****')
 OR (first_name IS NOT NULL AND first_name <> '*****')
 OR (last_name IS NOT NULL AND last_name <> '*****')
 OR (email IS NOT NULL AND email <> '*****')
 OR (phone IS NOT NULL AND phone <> '*****')
 OR (birth_date IS NOT NULL)
 OR (tlc_license_number IS NOT NULL AND tlc_license_number <> '*****')
 OR (depot IS NOT NULL AND depot <> '*****')
 OR (hire_date IS NOT NULL)
 OR (end_date IS NOT NULL)), 0) = 0, 'OK', 'ECART') AS toutes_colonnes_personnelles_masquees
FROM NYC_TAXI.RAW.DRIVERS;
SELECT 'RAW.DRIVER_SHIFTS' AS objet, IFF(COUNT(*) = 25951
 AND COALESCE(COUNT_IF((shift_id IS NOT NULL AND shift_id <> '*****')
 OR (driver_id IS NOT NULL AND driver_id <> '*****')
 OR (shift_date IS NOT NULL)
 OR (depot IS NOT NULL AND depot <> '*****')
 OR (start_hour IS NOT NULL)
 OR (hours_worked IS NOT NULL)
 OR (trips_count IS NOT NULL)
 OR (revenue_usd IS NOT NULL)), 0) = 0, 'OK', 'ECART') AS toutes_colonnes_personnelles_masquees
FROM NYC_TAXI.RAW.DRIVER_SHIFTS;
SELECT 'STAGING.STG_RH__DRIVERS' AS objet, IFF(COUNT(*) > 0
 AND COALESCE(COUNT_IF((driver_id IS NOT NULL AND driver_id <> '*****')
 OR (first_name IS NOT NULL AND first_name <> '*****')
 OR (last_name IS NOT NULL AND last_name <> '*****')
 OR (email IS NOT NULL AND email <> '*****')
 OR (phone IS NOT NULL AND phone <> '*****')
 OR (birth_date IS NOT NULL)
 OR (tlc_license_number IS NOT NULL AND tlc_license_number <> '*****')
 OR (depot IS NOT NULL AND depot <> '*****')
 OR (hire_date IS NOT NULL)
 OR (end_date IS NOT NULL)), 0) = 0, 'OK', 'ECART') AS toutes_colonnes_personnelles_masquees
FROM NYC_TAXI.STAGING.STG_RH__DRIVERS;
SELECT 'STAGING.STG_RH__DRIVER_SHIFTS' AS objet, IFF(COUNT(*) > 0
 AND COALESCE(COUNT_IF((shift_id IS NOT NULL AND shift_id <> '*****')
 OR (driver_id IS NOT NULL AND driver_id <> '*****')
 OR (shift_date IS NOT NULL)
 OR (depot IS NOT NULL AND depot <> '*****')
 OR (start_hour IS NOT NULL)
 OR (hours_worked IS NOT NULL)
 OR (trips_count IS NOT NULL)
 OR (revenue_usd IS NOT NULL)), 0) = 0, 'OK', 'ECART') AS toutes_colonnes_personnelles_masquees
FROM NYC_TAXI.STAGING.STG_RH__DRIVER_SHIFTS;

-- B8 : SYSADMIN : MARTS RH vides et RAW/STAGING personnels masqués.
USE SECONDARY ROLES NONE;
USE ROLE SYSADMIN;
USE WAREHOUSE NYC_TAXI_WH;
SELECT IFF((SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER) = 0
 AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) = 0
 AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DEPOT) = 3, 'OK', 'ECART') AS perimetre_administrateur;
SELECT 'RAW.DRIVERS' AS objet, IFF(COUNT(*) = 400
 AND COALESCE(COUNT_IF((driver_id IS NOT NULL AND driver_id <> '*****')
 OR (first_name IS NOT NULL AND first_name <> '*****')
 OR (last_name IS NOT NULL AND last_name <> '*****')
 OR (email IS NOT NULL AND email <> '*****')
 OR (phone IS NOT NULL AND phone <> '*****')
 OR (birth_date IS NOT NULL)
 OR (tlc_license_number IS NOT NULL AND tlc_license_number <> '*****')
 OR (depot IS NOT NULL AND depot <> '*****')
 OR (hire_date IS NOT NULL)
 OR (end_date IS NOT NULL)), 0) = 0, 'OK', 'ECART') AS toutes_colonnes_personnelles_masquees
FROM NYC_TAXI.RAW.DRIVERS;
SELECT 'RAW.DRIVER_SHIFTS' AS objet, IFF(COUNT(*) = 25951
 AND COALESCE(COUNT_IF((shift_id IS NOT NULL AND shift_id <> '*****')
 OR (driver_id IS NOT NULL AND driver_id <> '*****')
 OR (shift_date IS NOT NULL)
 OR (depot IS NOT NULL AND depot <> '*****')
 OR (start_hour IS NOT NULL)
 OR (hours_worked IS NOT NULL)
 OR (trips_count IS NOT NULL)
 OR (revenue_usd IS NOT NULL)), 0) = 0, 'OK', 'ECART') AS toutes_colonnes_personnelles_masquees
FROM NYC_TAXI.RAW.DRIVER_SHIFTS;
SELECT 'STAGING.STG_RH__DRIVERS' AS objet, IFF(COUNT(*) > 0
 AND COALESCE(COUNT_IF((driver_id IS NOT NULL AND driver_id <> '*****')
 OR (first_name IS NOT NULL AND first_name <> '*****')
 OR (last_name IS NOT NULL AND last_name <> '*****')
 OR (email IS NOT NULL AND email <> '*****')
 OR (phone IS NOT NULL AND phone <> '*****')
 OR (birth_date IS NOT NULL)
 OR (tlc_license_number IS NOT NULL AND tlc_license_number <> '*****')
 OR (depot IS NOT NULL AND depot <> '*****')
 OR (hire_date IS NOT NULL)
 OR (end_date IS NOT NULL)), 0) = 0, 'OK', 'ECART') AS toutes_colonnes_personnelles_masquees
FROM NYC_TAXI.STAGING.STG_RH__DRIVERS;
SELECT 'STAGING.STG_RH__DRIVER_SHIFTS' AS objet, IFF(COUNT(*) > 0
 AND COALESCE(COUNT_IF((shift_id IS NOT NULL AND shift_id <> '*****')
 OR (driver_id IS NOT NULL AND driver_id <> '*****')
 OR (shift_date IS NOT NULL)
 OR (depot IS NOT NULL AND depot <> '*****')
 OR (start_hour IS NOT NULL)
 OR (hours_worked IS NOT NULL)
 OR (trips_count IS NOT NULL)
 OR (revenue_usd IS NOT NULL)), 0) = 0, 'OK', 'ECART') AS toutes_colonnes_personnelles_masquees
FROM NYC_TAXI.STAGING.STG_RH__DRIVER_SHIFTS;

-- B9 : examiner aussi les droits futurs, les attributions et les héritages préexistants.
USE SECONDARY ROLES NONE;
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE NYC_TAXI_WH;
SHOW GRANTS TO ROLE RH_PAIE;
SHOW GRANTS OF ROLE RH_PAIE;
SHOW FUTURE GRANTS TO ROLE RH_PAIE;
SHOW GRANTS TO ROLE RESP_DEPOT_QUEENS;
SHOW GRANTS OF ROLE RESP_DEPOT_QUEENS;
SHOW FUTURE GRANTS TO ROLE RESP_DEPOT_QUEENS;
SHOW GRANTS TO ROLE RESP_DEPOT_BRONX;
SHOW GRANTS OF ROLE RESP_DEPOT_BRONX;
SHOW FUTURE GRANTS TO ROLE RESP_DEPOT_BRONX;
SHOW GRANTS TO ROLE ANALYSTE;
SHOW GRANTS OF ROLE ANALYSTE;
SHOW FUTURE GRANTS TO ROLE ANALYSTE;
SHOW GRANTS TO ROLE GOUVERNANCE;
SHOW GRANTS OF ROLE GOUVERNANCE;
-- Attendus : les droits de 02 ; aucun SELECT métier RAW/STAGING ni rôle privilégié hérité.
-- Pas d’héritage TRANSFORMER/métier dans GOUVERNANCE. Les sorties SHOW peuvent contenir
-- l’utilisateur testeur : masquer son identité avant de partager/enregistrer une preuve.
SELECT 'Tests terminés : reporter les résultats observés, puis exécuter les tests dépôt et pipeline.' AS suite;
