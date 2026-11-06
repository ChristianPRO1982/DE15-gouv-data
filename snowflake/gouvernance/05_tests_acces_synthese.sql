-- Étape 5 : lancer ce fichier EN ENTIER. Un seul tableau final, huit rôles.
-- Prérequis : 01 à 04 déployés et activation_roles_metier.sql exécuté.
-- Les requêtes de 05_tests_acces.sql sont enchaînées et leurs résultats regroupés ici.
-- Ce fichier prépare ses références : aucun B0 préalable ni changement manuel de rôle.
-- Les refus attendus sont vérifiés ; une erreur imprévue donne ERREUR, jamais OK.
-- Aucun droit, table, politique ou donnée modifié. Les variables $e5_* sont des références
-- de session temporaires ; aucune donnée nominative ni empreinte dans le tableau final.
-- À maintenir cohérent avec les tests détaillés si la matrice métier change.
EXECUTE IMMEDIATE $$
DECLARE
  role_initial VARCHAR DEFAULT CURRENT_ROLE();
  commande VARCHAR;
  identifiant_requete VARCHAR;
  genre VARCHAR;
  role_attendu VARCHAR;
  test_courant VARCHAR;
  attendu_refus NUMBER;
  ordre_courant NUMBER;
  nombre_controles NUMBER;
  erreurs NUMBER;
  statut_courant VARCHAR;
  preuve VARIANT;
  refus VARIANT;
  observations ARRAY DEFAULT ARRAY_CONSTRUCT();
  contenu RESULTSET;
  objets RESULTSET;
  sortie RESULTSET;
  contexte_incorrect EXCEPTION (-20006, 'Le rôle actif ne correspond pas au rôle testé.');
  c CURSOR FOR
    SELECT column1 AS ordre, column2 AS role_cible, column3 AS genre,
           column4 AS test, column5 AS attendu_refus, column6 AS instruction
    FROM VALUES
    (1, 'TRANSFORMER', 'CONTEXTE', 'contexte', 0, 'USE SECONDARY ROLES NONE'),
    (2, 'TRANSFORMER', 'CONTEXTE', 'contexte', 0, 'USE ROLE TRANSFORMER'),
    (3, 'TRANSFORMER', 'CONTEXTE', 'contexte', 0, 'USE WAREHOUSE NYC_TAXI_WH'),
    (4, 'TRANSFORMER', 'CONTEXTE', 'contexte', 0, 'SET (e5_dim_paie, e5_temoin_dim_paie, e5_mensuel_paie, e5_temoin_mensuel_paie, e5_dim_queens, e5_temoin_dim_queens, e5_mensuel_queens, e5_temoin_mensuel_queens, e5_dim_bronx, e5_temoin_dim_bronx, e5_mensuel_bronx, e5_temoin_mensuel_bronx, e5_dim_analyste, e5_temoin_dim_analyste, e5_mensuel_analyste, e5_temoin_mensuel_analyste) = (
  SELECT
    (SELECT HASH_AGG(HASH(driver_id, first_name, last_name, email, phone, birth_date, tlc_license_number, depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER),
    (SELECT HASH_AGG(HASH(driver_id, first_name, last_name, email, phone, birth_date, tlc_license_number, depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE driver_id = ''D0003''),
    (SELECT HASH_AGG(HASH(activity_month, driver_id, driver_name, depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY),
    (SELECT HASH_AGG(HASH(activity_month, driver_id, driver_name, depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY WHERE driver_id = ''D0003''),
    (SELECT HASH_AGG(HASH(driver_id, first_name, last_name, IFF(email IS NULL, NULL, ''*****''), phone, NULL::DATE, IFF(tlc_license_number IS NULL, NULL, ''*****''), depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE depot = ''Queens''),
    (SELECT HASH_AGG(HASH(driver_id, first_name, last_name, IFF(email IS NULL, NULL, ''*****''), phone, NULL::DATE, IFF(tlc_license_number IS NULL, NULL, ''*****''), depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE driver_id = ''D0003'' AND depot = ''Queens''),
    (SELECT HASH_AGG(HASH(activity_month, driver_id, driver_name, depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY WHERE depot = ''Queens''),
    (SELECT HASH_AGG(HASH(activity_month, driver_id, driver_name, depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY WHERE driver_id = ''D0003'' AND depot = ''Queens''),
    (SELECT HASH_AGG(HASH(driver_id, first_name, last_name, IFF(email IS NULL, NULL, ''*****''), phone, NULL::DATE, IFF(tlc_license_number IS NULL, NULL, ''*****''), depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE depot = ''Bronx''),
    (SELECT HASH_AGG(HASH(driver_id, first_name, last_name, IFF(email IS NULL, NULL, ''*****''), phone, NULL::DATE, IFF(tlc_license_number IS NULL, NULL, ''*****''), depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE driver_id = ''D0003'' AND depot = ''Bronx''),
    (SELECT HASH_AGG(HASH(activity_month, driver_id, driver_name, depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY WHERE depot = ''Bronx''),
    (SELECT HASH_AGG(HASH(activity_month, driver_id, driver_name, depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY WHERE driver_id = ''D0003'' AND depot = ''Bronx''),
    (SELECT HASH_AGG(HASH(driver_id, IFF(first_name IS NULL, NULL, ''*****''), IFF(last_name IS NULL, NULL, ''*****''), IFF(email IS NULL, NULL, ''*****''), IFF(phone IS NULL, NULL, ''*****''), DATE_TRUNC(''year'', birth_date)::DATE, IFF(tlc_license_number IS NULL, NULL, ''*****''), depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER),
    (SELECT HASH_AGG(HASH(driver_id, IFF(first_name IS NULL, NULL, ''*****''), IFF(last_name IS NULL, NULL, ''*****''), IFF(email IS NULL, NULL, ''*****''), IFF(phone IS NULL, NULL, ''*****''), DATE_TRUNC(''year'', birth_date)::DATE, IFF(tlc_license_number IS NULL, NULL, ''*****''), depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE driver_id = ''D0003''),
    (SELECT HASH_AGG(HASH(activity_month, driver_id, IFF(driver_name IS NULL, NULL, ''*****''), depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY),
    (SELECT HASH_AGG(HASH(activity_month, driver_id, IFF(driver_name IS NULL, NULL, ''*****''), depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY WHERE driver_id = ''D0003'')
)'),
    (5, 'TRANSFORMER', 'SELECT', 'volumes_reference', 0, 'SELECT ''B0'' AS bloc, IFF((SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER) = 400 AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) = 914, ''OK'', ''ECART'') AS volumes_reference'),
    (6, 'TRANSFORMER', 'CONTEXTE', 'contexte', 0, 'USE SECONDARY ROLES NONE'),
    (7, 'RH_PAIE', 'CONTEXTE', 'contexte', 0, 'USE ROLE RH_PAIE'),
    (8, 'RH_PAIE', 'CONTEXTE', 'contexte', 0, 'USE WAREHOUSE NYC_TAXI_WH'),
    (9, 'RH_PAIE', 'SELECT', 'valeurs_et_perimetre', 0, 'SELECT CURRENT_ROLE() AS role_actif,
  (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER) AS chauffeurs,
  (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) AS lignes_mensuelles,
  IFF((SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER) = 400
      AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) = 914
      AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DEPOT) = 3, ''OK'', ''ECART'') AS volumes,
  IFF((SELECT HASH_AGG(HASH(driver_id, first_name, last_name, email, phone, birth_date, tlc_license_number, depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER) = $e5_dim_paie
      AND (SELECT HASH_AGG(HASH(activity_month, driver_id, driver_name, depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) = $e5_mensuel_paie, ''OK'', ''ECART'') AS valeurs_et_perimetre'),
    (10, 'RH_PAIE', 'SELECT', 'temoin_valeurs_sans_affichage', 0, 'SELECT IFF(
  (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE driver_id = ''D0003'') = 1
  AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY WHERE driver_id = ''D0003'') = 3
  AND (SELECT HASH_AGG(HASH(driver_id, first_name, last_name, email, phone, birth_date, tlc_license_number, depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE driver_id = ''D0003'') = $e5_temoin_dim_paie
  AND (SELECT HASH_AGG(HASH(activity_month, driver_id, driver_name, depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY WHERE driver_id = ''D0003'') = $e5_temoin_mensuel_paie,
  ''OK'', ''ECART'') AS temoin_valeurs_sans_affichage'),
    (11, 'RH_PAIE', 'REFUS', 'restrictions_RAW_STAGING_correspondances', 5, 'DECLARE
  commande VARCHAR;
  resultats ARRAY DEFAULT ARRAY_CONSTRUCT();
  c CURSOR FOR SELECT column1 AS objet FROM VALUES
    (''NYC_TAXI.RAW.DRIVERS''),
    (''NYC_TAXI.RAW.DRIVER_SHIFTS''),
    (''NYC_TAXI.STAGING.STG_RH__DRIVERS''),
    (''NYC_TAXI.STAGING.STG_RH__DRIVER_SHIFTS''),
    (''NYC_TAXI.GOUVERNANCE.ACCES_DEPOT'');
BEGIN
  FOR r IN c DO
    commande := ''SELECT COUNT(*) FROM '' || r.objet;
    BEGIN
      EXECUTE IMMEDIATE :commande;
      resultats := ARRAY_APPEND(resultats, OBJECT_CONSTRUCT(''objet'', r.objet, ''statut'', ''ECART : lecture autorisée''));
    EXCEPTION
      WHEN STATEMENT_ERROR THEN



        IF (SQLSTATE IN (''42501'', ''42S02'')
            OR (SQLSTATE = ''02000''
                AND CONTAINS(LOWER(SQLERRM), ''does not exist or not authorized''))) THEN
          resultats := ARRAY_APPEND(resultats, OBJECT_CONSTRUCT(''objet'', r.objet, ''statut'', ''OK : lecture refusée'',
            ''sqlstate'', SQLSTATE, ''sqlcode'', SQLCODE));
        ELSE
          RAISE;
        END IF;
    END;
  END FOR;
  RETURN TO_JSON(resultats);
END;'),
    (12, 'RH_PAIE', 'CONTEXTE', 'contexte', 0, 'USE SECONDARY ROLES NONE'),
    (13, 'RESP_DEPOT_QUEENS', 'CONTEXTE', 'contexte', 0, 'USE ROLE RESP_DEPOT_QUEENS'),
    (14, 'RESP_DEPOT_QUEENS', 'CONTEXTE', 'contexte', 0, 'USE WAREHOUSE NYC_TAXI_WH'),
    (15, 'RESP_DEPOT_QUEENS', 'SELECT', 'valeurs_et_perimetre', 0, 'SELECT CURRENT_ROLE() AS role_actif,
  (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER) AS chauffeurs,
  (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) AS lignes_mensuelles,
  IFF((SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER) = 161
      AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) = 365
      AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DEPOT) = 3, ''OK'', ''ECART'') AS volumes,
  IFF((SELECT HASH_AGG(HASH(driver_id, first_name, last_name, email, phone, birth_date, tlc_license_number, depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER) = $e5_dim_queens
      AND (SELECT HASH_AGG(HASH(activity_month, driver_id, driver_name, depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) = $e5_mensuel_queens, ''OK'', ''ECART'') AS valeurs_et_perimetre'),
    (16, 'RESP_DEPOT_QUEENS', 'SELECT', 'depot_exclusif', 0, 'SELECT IFF((SELECT COALESCE(COUNT_IF(depot <> ''Queens'' OR depot IS NULL), 0) FROM NYC_TAXI.MARTS.DIM_DRIVER) = 0
 AND (SELECT COALESCE(COUNT_IF(depot <> ''Queens'' OR depot IS NULL), 0) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) = 0, ''OK'', ''ECART'') AS depot_exclusif'),
    (17, 'RESP_DEPOT_QUEENS', 'SELECT', 'temoin_valeurs_sans_affichage', 0, 'SELECT IFF(
  (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE driver_id = ''D0003'') = 1
  AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY WHERE driver_id = ''D0003'') = 3
  AND (SELECT HASH_AGG(HASH(driver_id, first_name, last_name, email, phone, birth_date, tlc_license_number, depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE driver_id = ''D0003'') = $e5_temoin_dim_queens
  AND (SELECT HASH_AGG(HASH(activity_month, driver_id, driver_name, depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY WHERE driver_id = ''D0003'') = $e5_temoin_mensuel_queens,
  ''OK'', ''ECART'') AS temoin_valeurs_sans_affichage'),
    (18, 'RESP_DEPOT_QUEENS', 'REFUS', 'restrictions_RAW_STAGING_correspondances', 5, 'DECLARE
  commande VARCHAR;
  resultats ARRAY DEFAULT ARRAY_CONSTRUCT();
  c CURSOR FOR SELECT column1 AS objet FROM VALUES
    (''NYC_TAXI.RAW.DRIVERS''),
    (''NYC_TAXI.RAW.DRIVER_SHIFTS''),
    (''NYC_TAXI.STAGING.STG_RH__DRIVERS''),
    (''NYC_TAXI.STAGING.STG_RH__DRIVER_SHIFTS''),
    (''NYC_TAXI.GOUVERNANCE.ACCES_DEPOT'');
BEGIN
  FOR r IN c DO
    commande := ''SELECT COUNT(*) FROM '' || r.objet;
    BEGIN
      EXECUTE IMMEDIATE :commande;
      resultats := ARRAY_APPEND(resultats, OBJECT_CONSTRUCT(''objet'', r.objet, ''statut'', ''ECART : lecture autorisée''));
    EXCEPTION
      WHEN STATEMENT_ERROR THEN



        IF (SQLSTATE IN (''42501'', ''42S02'')
            OR (SQLSTATE = ''02000''
                AND CONTAINS(LOWER(SQLERRM), ''does not exist or not authorized''))) THEN
          resultats := ARRAY_APPEND(resultats, OBJECT_CONSTRUCT(''objet'', r.objet, ''statut'', ''OK : lecture refusée'',
            ''sqlstate'', SQLSTATE, ''sqlcode'', SQLCODE));
        ELSE
          RAISE;
        END IF;
    END;
  END FOR;
  RETURN TO_JSON(resultats);
END;'),
    (19, 'RESP_DEPOT_QUEENS', 'CONTEXTE', 'contexte', 0, 'USE SECONDARY ROLES NONE'),
    (20, 'RESP_DEPOT_BRONX', 'CONTEXTE', 'contexte', 0, 'USE ROLE RESP_DEPOT_BRONX'),
    (21, 'RESP_DEPOT_BRONX', 'CONTEXTE', 'contexte', 0, 'USE WAREHOUSE NYC_TAXI_WH'),
    (22, 'RESP_DEPOT_BRONX', 'SELECT', 'valeurs_et_perimetre', 0, 'SELECT CURRENT_ROLE() AS role_actif,
  (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER) AS chauffeurs,
  (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) AS lignes_mensuelles,
  IFF((SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER) = 122
      AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) = 290
      AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DEPOT) = 3, ''OK'', ''ECART'') AS volumes,
  IFF((SELECT HASH_AGG(HASH(driver_id, first_name, last_name, email, phone, birth_date, tlc_license_number, depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER) = $e5_dim_bronx
      AND (SELECT HASH_AGG(HASH(activity_month, driver_id, driver_name, depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) = $e5_mensuel_bronx, ''OK'', ''ECART'') AS valeurs_et_perimetre'),
    (23, 'RESP_DEPOT_BRONX', 'SELECT', 'depot_exclusif', 0, 'SELECT IFF((SELECT COALESCE(COUNT_IF(depot <> ''Bronx'' OR depot IS NULL), 0) FROM NYC_TAXI.MARTS.DIM_DRIVER) = 0
 AND (SELECT COALESCE(COUNT_IF(depot <> ''Bronx'' OR depot IS NULL), 0) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) = 0, ''OK'', ''ECART'') AS depot_exclusif'),
    (24, 'RESP_DEPOT_BRONX', 'SELECT', 'temoin_valeurs_sans_affichage', 0, 'SELECT IFF(
  (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE driver_id = ''D0003'') = 0
  AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY WHERE driver_id = ''D0003'') = 0
  AND (SELECT HASH_AGG(HASH(driver_id, first_name, last_name, email, phone, birth_date, tlc_license_number, depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE driver_id = ''D0003'') = $e5_temoin_dim_bronx
  AND (SELECT HASH_AGG(HASH(activity_month, driver_id, driver_name, depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY WHERE driver_id = ''D0003'') = $e5_temoin_mensuel_bronx,
  ''OK'', ''ECART'') AS temoin_valeurs_sans_affichage'),
    (25, 'RESP_DEPOT_BRONX', 'REFUS', 'restrictions_RAW_STAGING_correspondances', 5, 'DECLARE
  commande VARCHAR;
  resultats ARRAY DEFAULT ARRAY_CONSTRUCT();
  c CURSOR FOR SELECT column1 AS objet FROM VALUES
    (''NYC_TAXI.RAW.DRIVERS''),
    (''NYC_TAXI.RAW.DRIVER_SHIFTS''),
    (''NYC_TAXI.STAGING.STG_RH__DRIVERS''),
    (''NYC_TAXI.STAGING.STG_RH__DRIVER_SHIFTS''),
    (''NYC_TAXI.GOUVERNANCE.ACCES_DEPOT'');
BEGIN
  FOR r IN c DO
    commande := ''SELECT COUNT(*) FROM '' || r.objet;
    BEGIN
      EXECUTE IMMEDIATE :commande;
      resultats := ARRAY_APPEND(resultats, OBJECT_CONSTRUCT(''objet'', r.objet, ''statut'', ''ECART : lecture autorisée''));
    EXCEPTION
      WHEN STATEMENT_ERROR THEN



        IF (SQLSTATE IN (''42501'', ''42S02'')
            OR (SQLSTATE = ''02000''
                AND CONTAINS(LOWER(SQLERRM), ''does not exist or not authorized''))) THEN
          resultats := ARRAY_APPEND(resultats, OBJECT_CONSTRUCT(''objet'', r.objet, ''statut'', ''OK : lecture refusée'',
            ''sqlstate'', SQLSTATE, ''sqlcode'', SQLCODE));
        ELSE
          RAISE;
        END IF;
    END;
  END FOR;
  RETURN TO_JSON(resultats);
END;'),
    (26, 'RESP_DEPOT_BRONX', 'CONTEXTE', 'contexte', 0, 'USE SECONDARY ROLES NONE'),
    (27, 'ANALYSTE', 'CONTEXTE', 'contexte', 0, 'USE ROLE ANALYSTE'),
    (28, 'ANALYSTE', 'CONTEXTE', 'contexte', 0, 'USE WAREHOUSE NYC_TAXI_WH'),
    (29, 'ANALYSTE', 'SELECT', 'valeurs_et_perimetre', 0, 'SELECT CURRENT_ROLE() AS role_actif,
  (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER) AS chauffeurs,
  (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) AS lignes_mensuelles,
  IFF((SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER) = 400
      AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) = 914
      AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DEPOT) = 3, ''OK'', ''ECART'') AS volumes,
  IFF((SELECT HASH_AGG(HASH(driver_id, first_name, last_name, email, phone, birth_date, tlc_license_number, depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER) = $e5_dim_analyste
      AND (SELECT HASH_AGG(HASH(activity_month, driver_id, driver_name, depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) = $e5_mensuel_analyste, ''OK'', ''ECART'') AS valeurs_et_perimetre'),
    (30, 'ANALYSTE', 'SELECT', 'temoin_valeurs_sans_affichage', 0, 'SELECT IFF(
  (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE driver_id = ''D0003'') = 1
  AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY WHERE driver_id = ''D0003'') = 3
  AND (SELECT HASH_AGG(HASH(driver_id, first_name, last_name, email, phone, birth_date, tlc_license_number, depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE driver_id = ''D0003'') = $e5_temoin_dim_analyste
  AND (SELECT HASH_AGG(HASH(activity_month, driver_id, driver_name, depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY WHERE driver_id = ''D0003'') = $e5_temoin_mensuel_analyste,
  ''OK'', ''ECART'') AS temoin_valeurs_sans_affichage'),
    (31, 'ANALYSTE', 'REFUS', 'restrictions_RAW_STAGING_correspondances', 5, 'DECLARE
  commande VARCHAR;
  resultats ARRAY DEFAULT ARRAY_CONSTRUCT();
  c CURSOR FOR SELECT column1 AS objet FROM VALUES
    (''NYC_TAXI.RAW.DRIVERS''),
    (''NYC_TAXI.RAW.DRIVER_SHIFTS''),
    (''NYC_TAXI.STAGING.STG_RH__DRIVERS''),
    (''NYC_TAXI.STAGING.STG_RH__DRIVER_SHIFTS''),
    (''NYC_TAXI.GOUVERNANCE.ACCES_DEPOT'');
BEGIN
  FOR r IN c DO
    commande := ''SELECT COUNT(*) FROM '' || r.objet;
    BEGIN
      EXECUTE IMMEDIATE :commande;
      resultats := ARRAY_APPEND(resultats, OBJECT_CONSTRUCT(''objet'', r.objet, ''statut'', ''ECART : lecture autorisée''));
    EXCEPTION
      WHEN STATEMENT_ERROR THEN



        IF (SQLSTATE IN (''42501'', ''42S02'')
            OR (SQLSTATE = ''02000''
                AND CONTAINS(LOWER(SQLERRM), ''does not exist or not authorized''))) THEN
          resultats := ARRAY_APPEND(resultats, OBJECT_CONSTRUCT(''objet'', r.objet, ''statut'', ''OK : lecture refusée'',
            ''sqlstate'', SQLSTATE, ''sqlcode'', SQLCODE));
        ELSE
          RAISE;
        END IF;
    END;
  END FOR;
  RETURN TO_JSON(resultats);
END;'),
    (32, 'ANALYSTE', 'CONTEXTE', 'contexte', 0, 'USE SECONDARY ROLES NONE'),
    (33, 'TRANSFORMER', 'CONTEXTE', 'contexte', 0, 'USE ROLE TRANSFORMER'),
    (34, 'TRANSFORMER', 'CONTEXTE', 'contexte', 0, 'USE WAREHOUSE NYC_TAXI_WH'),
    (35, 'TRANSFORMER', 'SELECT', 'valeurs_et_perimetre', 0, 'SELECT CURRENT_ROLE() AS role_actif,
  (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER) AS chauffeurs,
  (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) AS lignes_mensuelles,
  IFF((SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER) = 400
      AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) = 914
      AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DEPOT) = 3, ''OK'', ''ECART'') AS volumes,
  IFF((SELECT HASH_AGG(HASH(driver_id, first_name, last_name, email, phone, birth_date, tlc_license_number, depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER) = $e5_dim_paie
      AND (SELECT HASH_AGG(HASH(activity_month, driver_id, driver_name, depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) = $e5_mensuel_paie, ''OK'', ''ECART'') AS valeurs_et_perimetre'),
    (36, 'TRANSFORMER', 'SELECT', 'temoin_valeurs_sans_affichage', 0, 'SELECT IFF(
  (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE driver_id = ''D0003'') = 1
  AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY WHERE driver_id = ''D0003'') = 3
  AND (SELECT HASH_AGG(HASH(driver_id, first_name, last_name, email, phone, birth_date, tlc_license_number, depot, hire_date, end_date, is_active, tenure_years)) FROM NYC_TAXI.MARTS.DIM_DRIVER WHERE driver_id = ''D0003'') = $e5_temoin_dim_paie
  AND (SELECT HASH_AGG(HASH(activity_month, driver_id, driver_name, depot, nb_shifts, hours_worked, trips_count, revenue_usd)) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY WHERE driver_id = ''D0003'') = $e5_temoin_mensuel_paie,
  ''OK'', ''ECART'') AS temoin_valeurs_sans_affichage'),
    (37, 'TRANSFORMER', 'SELECT', 'sources_accessibles', 0, 'SELECT IFF(
  (SELECT COUNT(*) FROM NYC_TAXI.RAW.DRIVERS) = 400
  AND (SELECT COUNT(*) FROM NYC_TAXI.RAW.DRIVER_SHIFTS) = 25951
  AND (SELECT COUNT(*) FROM NYC_TAXI.STAGING.STG_RH__DRIVERS) = 400
  AND (SELECT COUNT(*) FROM NYC_TAXI.STAGING.STG_RH__DRIVER_SHIFTS) = 25933,
  ''OK'', ''ECART'') AS sources_accessibles'),
    (38, 'TRANSFORMER', 'SELECT', 'temoin_source_en_clair', 0, 'SELECT IFF(COUNT(*) = 1 AND COUNT_IF(first_name IS NOT NULL AND first_name <> ''*****''
  AND last_name IS NOT NULL AND last_name <> ''*****'' AND email LIKE ''%@%''
  AND phone IS NOT NULL AND phone <> ''*****'' AND birth_date IS NOT NULL
  AND tlc_license_number IS NOT NULL AND tlc_license_number <> ''*****'') = 1,
  ''OK'', ''ECART'') AS temoin_source_en_clair
FROM NYC_TAXI.RAW.DRIVERS WHERE driver_id = ''D0003'''),
    (39, 'TRANSFORMER', 'REFUS', 'restrictions_RAW_STAGING_correspondances', 1, 'DECLARE
  commande VARCHAR;
  resultats ARRAY DEFAULT ARRAY_CONSTRUCT();
  c CURSOR FOR SELECT column1 AS objet FROM VALUES
    (''NYC_TAXI.GOUVERNANCE.ACCES_DEPOT'');
BEGIN
  FOR r IN c DO
    commande := ''SELECT COUNT(*) FROM '' || r.objet;
    BEGIN
      EXECUTE IMMEDIATE :commande;
      resultats := ARRAY_APPEND(resultats, OBJECT_CONSTRUCT(''objet'', r.objet, ''statut'', ''ECART : lecture autorisée''));
    EXCEPTION
      WHEN STATEMENT_ERROR THEN



        IF (SQLSTATE IN (''42501'', ''42S02'')
            OR (SQLSTATE = ''02000''
                AND CONTAINS(LOWER(SQLERRM), ''does not exist or not authorized''))) THEN
          resultats := ARRAY_APPEND(resultats, OBJECT_CONSTRUCT(''objet'', r.objet, ''statut'', ''OK : lecture refusée'',
            ''sqlstate'', SQLSTATE, ''sqlcode'', SQLCODE));
        ELSE
          RAISE;
        END IF;
    END;
  END FOR;
  RETURN TO_JSON(resultats);
END;'),
    (40, 'TRANSFORMER', 'CONTEXTE', 'contexte', 0, 'USE SECONDARY ROLES NONE'),
    (41, 'GOUVERNANCE', 'CONTEXTE', 'contexte', 0, 'USE ROLE GOUVERNANCE'),
    (42, 'GOUVERNANCE', 'CONTEXTE', 'contexte', 0, 'USE WAREHOUSE NYC_TAXI_WH'),
    (43, 'GOUVERNANCE', 'REFUS', 'restrictions_RAW_STAGING_correspondances', 7, 'DECLARE
  commande VARCHAR;
  resultats ARRAY DEFAULT ARRAY_CONSTRUCT();
  c CURSOR FOR SELECT column1 AS objet FROM VALUES
    (''NYC_TAXI.RAW.DRIVERS''),
    (''NYC_TAXI.RAW.DRIVER_SHIFTS''),
    (''NYC_TAXI.STAGING.STG_RH__DRIVERS''),
    (''NYC_TAXI.STAGING.STG_RH__DRIVER_SHIFTS''),
    (''NYC_TAXI.MARTS.DIM_DRIVER''),
    (''NYC_TAXI.MARTS.MART_DRIVER_MONTHLY''),
    (''NYC_TAXI.MARTS.DIM_DEPOT'');
BEGIN
  FOR r IN c DO
    commande := ''SELECT COUNT(*) FROM '' || r.objet;
    BEGIN
      EXECUTE IMMEDIATE :commande;
      resultats := ARRAY_APPEND(resultats, OBJECT_CONSTRUCT(''objet'', r.objet, ''statut'', ''ECART : lecture autorisée''));
    EXCEPTION
      WHEN STATEMENT_ERROR THEN



        IF (SQLSTATE IN (''42501'', ''42S02'')
            OR (SQLSTATE = ''02000''
                AND CONTAINS(LOWER(SQLERRM), ''does not exist or not authorized''))) THEN
          resultats := ARRAY_APPEND(resultats, OBJECT_CONSTRUCT(''objet'', r.objet, ''statut'', ''OK : lecture refusée'',
            ''sqlstate'', SQLSTATE, ''sqlcode'', SQLCODE));
        ELSE
          RAISE;
        END IF;
    END;
  END FOR;
  RETURN TO_JSON(resultats);
END;'),
    (44, 'GOUVERNANCE', 'CONTEXTE', 'contexte', 0, 'USE SECONDARY ROLES NONE'),
    (45, 'ACCOUNTADMIN', 'CONTEXTE', 'contexte', 0, 'USE ROLE ACCOUNTADMIN'),
    (46, 'ACCOUNTADMIN', 'CONTEXTE', 'contexte', 0, 'USE WAREHOUSE NYC_TAXI_WH'),
    (47, 'ACCOUNTADMIN', 'SELECT', 'perimetre_administrateur', 0, 'SELECT IFF((SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER) = 0
 AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) = 0
 AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DEPOT) = 3, ''OK'', ''ECART'') AS perimetre_administrateur'),
    (48, 'ACCOUNTADMIN', 'SELECT', 'toutes_colonnes_personnelles_masquees', 0, 'SELECT ''RAW.DRIVERS'' AS objet, IFF(COUNT(*) = 400
 AND COALESCE(COUNT_IF((driver_id IS NOT NULL AND driver_id <> ''*****'')
 OR (first_name IS NOT NULL AND first_name <> ''*****'')
 OR (last_name IS NOT NULL AND last_name <> ''*****'')
 OR (email IS NOT NULL AND email <> ''*****'')
 OR (phone IS NOT NULL AND phone <> ''*****'')
 OR (birth_date IS NOT NULL)
 OR (tlc_license_number IS NOT NULL AND tlc_license_number <> ''*****'')
 OR (depot IS NOT NULL AND depot <> ''*****'')
 OR (hire_date IS NOT NULL)
 OR (end_date IS NOT NULL)), 0) = 0, ''OK'', ''ECART'') AS toutes_colonnes_personnelles_masquees
FROM NYC_TAXI.RAW.DRIVERS'),
    (49, 'ACCOUNTADMIN', 'SELECT', 'toutes_colonnes_personnelles_masquees', 0, 'SELECT ''RAW.DRIVER_SHIFTS'' AS objet, IFF(COUNT(*) = 25951
 AND COALESCE(COUNT_IF((shift_id IS NOT NULL AND shift_id <> ''*****'')
 OR (driver_id IS NOT NULL AND driver_id <> ''*****'')
 OR (shift_date IS NOT NULL)
 OR (depot IS NOT NULL AND depot <> ''*****'')
 OR (start_hour IS NOT NULL)
 OR (hours_worked IS NOT NULL)
 OR (trips_count IS NOT NULL)
 OR (revenue_usd IS NOT NULL)), 0) = 0, ''OK'', ''ECART'') AS toutes_colonnes_personnelles_masquees
FROM NYC_TAXI.RAW.DRIVER_SHIFTS'),
    (50, 'ACCOUNTADMIN', 'SELECT', 'toutes_colonnes_personnelles_masquees', 0, 'SELECT ''STAGING.STG_RH__DRIVERS'' AS objet, IFF(COUNT(*) > 0
 AND COALESCE(COUNT_IF((driver_id IS NOT NULL AND driver_id <> ''*****'')
 OR (first_name IS NOT NULL AND first_name <> ''*****'')
 OR (last_name IS NOT NULL AND last_name <> ''*****'')
 OR (email IS NOT NULL AND email <> ''*****'')
 OR (phone IS NOT NULL AND phone <> ''*****'')
 OR (birth_date IS NOT NULL)
 OR (tlc_license_number IS NOT NULL AND tlc_license_number <> ''*****'')
 OR (depot IS NOT NULL AND depot <> ''*****'')
 OR (hire_date IS NOT NULL)
 OR (end_date IS NOT NULL)), 0) = 0, ''OK'', ''ECART'') AS toutes_colonnes_personnelles_masquees
FROM NYC_TAXI.STAGING.STG_RH__DRIVERS'),
    (51, 'ACCOUNTADMIN', 'SELECT', 'toutes_colonnes_personnelles_masquees', 0, 'SELECT ''STAGING.STG_RH__DRIVER_SHIFTS'' AS objet, IFF(COUNT(*) > 0
 AND COALESCE(COUNT_IF((shift_id IS NOT NULL AND shift_id <> ''*****'')
 OR (driver_id IS NOT NULL AND driver_id <> ''*****'')
 OR (shift_date IS NOT NULL)
 OR (depot IS NOT NULL AND depot <> ''*****'')
 OR (start_hour IS NOT NULL)
 OR (hours_worked IS NOT NULL)
 OR (trips_count IS NOT NULL)
 OR (revenue_usd IS NOT NULL)), 0) = 0, ''OK'', ''ECART'') AS toutes_colonnes_personnelles_masquees
FROM NYC_TAXI.STAGING.STG_RH__DRIVER_SHIFTS'),
    (52, 'ACCOUNTADMIN', 'CONTEXTE', 'contexte', 0, 'USE SECONDARY ROLES NONE'),
    (53, 'SYSADMIN', 'CONTEXTE', 'contexte', 0, 'USE ROLE SYSADMIN'),
    (54, 'SYSADMIN', 'CONTEXTE', 'contexte', 0, 'USE WAREHOUSE NYC_TAXI_WH'),
    (55, 'SYSADMIN', 'SELECT', 'perimetre_administrateur', 0, 'SELECT IFF((SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER) = 0
 AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY) = 0
 AND (SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DEPOT) = 3, ''OK'', ''ECART'') AS perimetre_administrateur'),
    (56, 'SYSADMIN', 'SELECT', 'toutes_colonnes_personnelles_masquees', 0, 'SELECT ''RAW.DRIVERS'' AS objet, IFF(COUNT(*) = 400
 AND COALESCE(COUNT_IF((driver_id IS NOT NULL AND driver_id <> ''*****'')
 OR (first_name IS NOT NULL AND first_name <> ''*****'')
 OR (last_name IS NOT NULL AND last_name <> ''*****'')
 OR (email IS NOT NULL AND email <> ''*****'')
 OR (phone IS NOT NULL AND phone <> ''*****'')
 OR (birth_date IS NOT NULL)
 OR (tlc_license_number IS NOT NULL AND tlc_license_number <> ''*****'')
 OR (depot IS NOT NULL AND depot <> ''*****'')
 OR (hire_date IS NOT NULL)
 OR (end_date IS NOT NULL)), 0) = 0, ''OK'', ''ECART'') AS toutes_colonnes_personnelles_masquees
FROM NYC_TAXI.RAW.DRIVERS'),
    (57, 'SYSADMIN', 'SELECT', 'toutes_colonnes_personnelles_masquees', 0, 'SELECT ''RAW.DRIVER_SHIFTS'' AS objet, IFF(COUNT(*) = 25951
 AND COALESCE(COUNT_IF((shift_id IS NOT NULL AND shift_id <> ''*****'')
 OR (driver_id IS NOT NULL AND driver_id <> ''*****'')
 OR (shift_date IS NOT NULL)
 OR (depot IS NOT NULL AND depot <> ''*****'')
 OR (start_hour IS NOT NULL)
 OR (hours_worked IS NOT NULL)
 OR (trips_count IS NOT NULL)
 OR (revenue_usd IS NOT NULL)), 0) = 0, ''OK'', ''ECART'') AS toutes_colonnes_personnelles_masquees
FROM NYC_TAXI.RAW.DRIVER_SHIFTS'),
    (58, 'SYSADMIN', 'SELECT', 'toutes_colonnes_personnelles_masquees', 0, 'SELECT ''STAGING.STG_RH__DRIVERS'' AS objet, IFF(COUNT(*) > 0
 AND COALESCE(COUNT_IF((driver_id IS NOT NULL AND driver_id <> ''*****'')
 OR (first_name IS NOT NULL AND first_name <> ''*****'')
 OR (last_name IS NOT NULL AND last_name <> ''*****'')
 OR (email IS NOT NULL AND email <> ''*****'')
 OR (phone IS NOT NULL AND phone <> ''*****'')
 OR (birth_date IS NOT NULL)
 OR (tlc_license_number IS NOT NULL AND tlc_license_number <> ''*****'')
 OR (depot IS NOT NULL AND depot <> ''*****'')
 OR (hire_date IS NOT NULL)
 OR (end_date IS NOT NULL)), 0) = 0, ''OK'', ''ECART'') AS toutes_colonnes_personnelles_masquees
FROM NYC_TAXI.STAGING.STG_RH__DRIVERS'),
    (59, 'SYSADMIN', 'SELECT', 'toutes_colonnes_personnelles_masquees', 0, 'SELECT ''STAGING.STG_RH__DRIVER_SHIFTS'' AS objet, IFF(COUNT(*) > 0
 AND COALESCE(COUNT_IF((shift_id IS NOT NULL AND shift_id <> ''*****'')
 OR (driver_id IS NOT NULL AND driver_id <> ''*****'')
 OR (shift_date IS NOT NULL)
 OR (depot IS NOT NULL AND depot <> ''*****'')
 OR (start_hour IS NOT NULL)
 OR (hours_worked IS NOT NULL)
 OR (trips_count IS NOT NULL)
 OR (revenue_usd IS NOT NULL)), 0) = 0, ''OK'', ''ECART'') AS toutes_colonnes_personnelles_masquees
FROM NYC_TAXI.STAGING.STG_RH__DRIVER_SHIFTS')
    ORDER BY column1;
BEGIN
  FOR e IN c DO
    role_attendu := e.role_cible;
    genre := e.genre;
    test_courant := e.test;
    attendu_refus := e.attendu_refus;
    ordre_courant := e.ordre;
    commande := e.instruction;
    BEGIN
      IF (genre = 'CONTEXTE') THEN
        EXECUTE IMMEDIATE :commande;
      ELSE
        IF (CURRENT_ROLE() <> role_attendu) THEN RAISE contexte_incorrect; END IF;
        contenu := (EXECUTE IMMEDIATE :commande);
        identifiant_requete := SQLID;
        -- SQLID est capturé immédiatement après l’exécution ; RESULT_SCAN ne refait pas la lecture.
        objets := (SELECT OBJECT_CONSTRUCT(*) AS preuve
                   FROM TABLE(RESULT_SCAN(:identifiant_requete)));
        nombre_controles := 0;
        FOR ligne IN objets DO
          preuve := ligne.preuve;
          IF (genre = 'REFUS') THEN
            -- L’unique colonne de l’ancien bloc contient le tableau JSON des refus.
            refus := PARSE_JSON(GET(preuve, GET(OBJECT_KEYS(preuve), 0)::VARCHAR)::VARCHAR);
            SELECT COUNT(*), COALESCE(COUNT_IF(value:statut::VARCHAR <> 'OK : lecture refusée'
                                      OR value:statut IS NULL), 0)
              INTO :nombre_controles, :erreurs FROM TABLE(FLATTEN(INPUT => :refus));
            statut_courant := IFF(nombre_controles = attendu_refus AND erreurs = 0, 'OK', 'ECART');
            preuve := OBJECT_CONSTRUCT('REFUS_ATTENDUS', attendu_refus, 'REFUS_CONFORMES', nombre_controles - erreurs);
          ELSE
            SELECT COUNT(*), COALESCE(COUNT_IF(value::VARCHAR <> 'OK' OR value IS NULL), 0)
              INTO :nombre_controles, :erreurs FROM TABLE(FLATTEN(INPUT => :preuve))
            WHERE key IN ('VOLUMES_REFERENCE', 'VOLUMES', 'VALEURS_ET_PERIMETRE', 'DEPOT_EXCLUSIF',
                          'TEMOIN_VALEURS_SANS_AFFICHAGE', 'SOURCES_ACCESSIBLES',
                          'TEMOIN_SOURCE_EN_CLAIR', 'PERIMETRE_ADMINISTRATEUR',
                          'TOUTES_COLONNES_PERSONNELLES_MASQUEES');
            statut_courant := IFF(nombre_controles > 0 AND erreurs = 0, 'OK', 'ECART');
          END IF;
          observations := ARRAY_APPEND(observations, OBJECT_CONSTRUCT(
            'ordre', ordre_courant, 'role', role_attendu, 'test', test_courant,
            'statut', statut_courant, 'preuve', preuve, 'detail', ''));
        END FOR;
        IF (nombre_controles = 0) THEN
          observations := ARRAY_APPEND(observations, OBJECT_CONSTRUCT(
            'ordre', ordre_courant, 'role', role_attendu, 'test', test_courant,
            'statut', 'ERREUR', 'detail', 'Aucun contrôle exploitable dans le résultat.'));
        END IF;
      END IF;
    EXCEPTION
      WHEN OTHER THEN
        -- Un contrôle non exécuté ou une erreur SQL ne devient jamais une réussite.
        observations := ARRAY_APPEND(observations, OBJECT_CONSTRUCT(
          'ordre', ordre_courant, 'role', role_attendu, 'test', test_courant,
          'statut', 'ERREUR', 'detail', 'SQLSTATE=' || SQLSTATE || ', SQLCODE=' || SQLCODE));
    END;
  END FOR;
  commande := 'USE ROLE "' || REPLACE(role_initial, '"', '""') || '"';
  EXECUTE IMMEDIATE :commande;
  sortie := (
    WITH controles AS (
      SELECT value:ordre::NUMBER AS ordre, value:role::VARCHAR AS role_actif,
             value:test::VARCHAR AS test, value:statut::VARCHAR AS statut,
             value:preuve AS preuve, value:detail::VARCHAR AS detail
      FROM TABLE(FLATTEN(INPUT => :observations))
    )
    SELECT role_actif,
           CASE WHEN role_actif IN ('ACCOUNTADMIN', 'SYSADMIN')
                      AND COALESCE(COUNT_IF(test = 'perimetre_administrateur' AND statut = 'OK'), 0) = 1
                THEN 0 ELSE MAX(preuve:CHAUFFEURS::NUMBER) END AS chauffeurs,
           CASE WHEN role_actif IN ('ACCOUNTADMIN', 'SYSADMIN')
                      AND COALESCE(COUNT_IF(test = 'perimetre_administrateur' AND statut = 'OK'), 0) = 1
                THEN 0 ELSE MAX(preuve:LIGNES_MENSUELLES::NUMBER) END AS lignes_mensuelles,
           COUNT(*) AS groupes_de_tests,
           COALESCE(COUNT_IF(statut = 'OK'), 0) AS groupes_ok,
           IFF(COUNT(*) > 0 AND COALESCE(COUNT_IF(statut <> 'OK'), 0) = 0, 'OK', 'ECART') AS statut,
           LISTAGG(IFF(statut <> 'OK', test || ' : ' || statut || ' ' || COALESCE(detail, ''), NULL), ' ; ')
             WITHIN GROUP (ORDER BY ordre) AS details_ecarts
    FROM controles GROUP BY role_actif ORDER BY MIN(ordre)
  );
  RETURN TABLE(sortie);
EXCEPTION
  WHEN OTHER THEN
    commande := 'USE ROLE "' || REPLACE(role_initial, '"', '""') || '"';
    EXECUTE IMMEDIATE :commande;
    RAISE;
END;
$$;
