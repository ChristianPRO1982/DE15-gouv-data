-- Étape 5 : REJOUABILITÉ. Exécuter EN ENTIER, arrêter à la première erreur.
-- Reprend les opérations des scripts 01 à 04 puis les cinq fiches catalogue.
-- Les SELECT/SHOW/DESCRIBE de détail sont omis ; le tableau final regroupe les contrôles.
-- Le 04 rétablit volontairement les cinq correspondances contractuelles.
-- Aucun chargement CSV, aucune reconstruction de données RH, aucune suppression de politique.
-- Transmettre uniquement le dernier tableau : cinq lignes OK attendues.

-- Source : snowflake/gouvernance/01_gouvernance.sql
-- Étape 4 : exécuter en entier, puis contrôler chaque résultat final.
-- Rejouable sans recréer les objets ni effacer les résultats de qualité.
USE SECONDARY ROLES NONE;

USE ROLE ACCOUNTADMIN;

-- La sous-requête permet l’expression ; les guillemets préservent le nom exact.
SET utilisateur_gouvernance = (SELECT '"' || REPLACE(CURRENT_USER(), '"', '""') || '"');

CREATE ROLE IF NOT EXISTS GOUVERNANCE
  COMMENT = 'Administre les règles et les métadonnées sans lecture des données RH';

GRANT ROLE GOUVERNANCE TO USER IDENTIFIER($utilisateur_gouvernance);

-- Ne pas rattacher TRANSFORMER ou les rôles métier à GOUVERNANCE.
GRANT USAGE ON DATABASE NYC_TAXI TO ROLE GOUVERNANCE;

GRANT USAGE ON WAREHOUSE NYC_TAXI_WH TO ROLE GOUVERNANCE;

GRANT USAGE ON SCHEMA NYC_TAXI.RAW TO ROLE GOUVERNANCE;

GRANT USAGE ON SCHEMA NYC_TAXI.MARTS TO ROLE GOUVERNANCE;

CREATE SCHEMA IF NOT EXISTS NYC_TAXI.GOUVERNANCE
  COMMENT = 'Catalogue, règles d’accès et mesures de qualité RH';

GRANT OWNERSHIP ON SCHEMA NYC_TAXI.GOUVERNANCE
  TO ROLE GOUVERNANCE COPY CURRENT GRANTS;

GRANT APPLY MASKING POLICY ON ACCOUNT TO ROLE GOUVERNANCE;

GRANT APPLY ROW ACCESS POLICY ON ACCOUNT TO ROLE GOUVERNANCE;

USE ROLE GOUVERNANCE;

USE WAREHOUSE NYC_TAXI_WH;

CREATE TAG IF NOT EXISTS NYC_TAXI.GOUVERNANCE.SENSIBILITE
  ALLOWED_VALUES 'public', 'interne', 'confidentiel'
  COMMENT = 'Sensibilité de la table cataloguée';

CREATE TAG IF NOT EXISTS NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE
  ALLOWED_VALUES 'nom', 'email', 'telephone', 'date_naissance',
                 'identifiant_officiel', 'identifiant_interne', 'donnee_professionnelle'
  COMMENT = 'Catégorie personnelle ; extension donnee_professionnelle autorisée par le titulaire, voir REGISTRE';

-- Mettre à jour aussi le tag déjà installé, sans le recréer.
ALTER TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE SET
  ALLOWED_VALUES 'nom', 'email', 'telephone', 'date_naissance',
                 'identifiant_officiel', 'identifiant_interne', 'donnee_professionnelle';

ALTER TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE SET
  COMMENT = 'Catégorie personnelle ; extension donnee_professionnelle autorisée par le titulaire, voir REGISTRE';

CREATE TAG IF NOT EXISTS NYC_TAXI.GOUVERNANCE.DUREE_CONSERVATION
  COMMENT = 'Durée documentaire ; ne déclenche aucune purge';

CREATE TABLE IF NOT EXISTS NYC_TAXI.GOUVERNANCE.QUALITE_RESULTATS (
  regle VARCHAR,
  mesure_le TIMESTAMP_NTZ,
  nb_anomalies NUMBER(18,0),
  seuil NUMBER(18,2),
  statut VARCHAR
) COMMENT = 'Historique des mesures de qualité RAW ; une ligne par règle et exécution quotidienne à partir du jour 3';

GRANT USAGE ON SCHEMA NYC_TAXI.GOUVERNANCE TO ROLE TRANSFORMER;

GRANT APPLY ON TAG NYC_TAXI.GOUVERNANCE.SENSIBILITE TO ROLE TRANSFORMER;

GRANT APPLY ON TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE TO ROLE TRANSFORMER;

GRANT APPLY ON TAG NYC_TAXI.GOUVERNANCE.DUREE_CONSERVATION TO ROLE TRANSFORMER;

GRANT INSERT, SELECT ON TABLE NYC_TAXI.GOUVERNANCE.QUALITE_RESULTATS TO ROLE TRANSFORMER;

GRANT CREATE VIEW ON SCHEMA NYC_TAXI.GOUVERNANCE TO ROLE TRANSFORMER;

-- Source : snowflake/gouvernance/02_roles_metier.sql
-- Étape 5 : préparation locale ; validation effective à effectuer dans Snowsight.
-- Attendus : docs/ACCES.md. Aucun secret ni valeur personnelle dans les sorties.
-- À exécuter AVANT 03/04 ; n’attribue aucun nouveau rôle au testeur.
USE SECONDARY ROLES NONE;

USE ROLE ACCOUNTADMIN;

USE WAREHOUSE NYC_TAXI_WH;

CREATE ROLE IF NOT EXISTS RH_PAIE;

GRANT USAGE ON DATABASE NYC_TAXI TO ROLE RH_PAIE;

GRANT USAGE ON WAREHOUSE NYC_TAXI_WH TO ROLE RH_PAIE;

GRANT USAGE ON SCHEMA NYC_TAXI.MARTS TO ROLE RH_PAIE;

GRANT USAGE ON SCHEMA NYC_TAXI.GOUVERNANCE TO ROLE RH_PAIE;

GRANT SELECT ON ALL VIEWS IN SCHEMA NYC_TAXI.GOUVERNANCE TO ROLE RH_PAIE;

GRANT SELECT ON FUTURE VIEWS IN SCHEMA NYC_TAXI.GOUVERNANCE TO ROLE RH_PAIE;

GRANT SELECT ON TABLE NYC_TAXI.MARTS.DIM_DEPOT TO ROLE RH_PAIE;

GRANT SELECT ON TABLE NYC_TAXI.MARTS.DIM_DRIVER TO ROLE RH_PAIE;

GRANT SELECT ON TABLE NYC_TAXI.MARTS.MART_DRIVER_MONTHLY TO ROLE RH_PAIE;

CREATE ROLE IF NOT EXISTS RESP_DEPOT_QUEENS;

GRANT USAGE ON DATABASE NYC_TAXI TO ROLE RESP_DEPOT_QUEENS;

GRANT USAGE ON WAREHOUSE NYC_TAXI_WH TO ROLE RESP_DEPOT_QUEENS;

GRANT USAGE ON SCHEMA NYC_TAXI.MARTS TO ROLE RESP_DEPOT_QUEENS;

GRANT USAGE ON SCHEMA NYC_TAXI.GOUVERNANCE TO ROLE RESP_DEPOT_QUEENS;

GRANT SELECT ON ALL VIEWS IN SCHEMA NYC_TAXI.GOUVERNANCE TO ROLE RESP_DEPOT_QUEENS;

GRANT SELECT ON FUTURE VIEWS IN SCHEMA NYC_TAXI.GOUVERNANCE TO ROLE RESP_DEPOT_QUEENS;

GRANT SELECT ON TABLE NYC_TAXI.MARTS.DIM_DEPOT TO ROLE RESP_DEPOT_QUEENS;

GRANT SELECT ON TABLE NYC_TAXI.MARTS.DIM_DRIVER TO ROLE RESP_DEPOT_QUEENS;

GRANT SELECT ON TABLE NYC_TAXI.MARTS.MART_DRIVER_MONTHLY TO ROLE RESP_DEPOT_QUEENS;

CREATE ROLE IF NOT EXISTS RESP_DEPOT_BRONX;

GRANT USAGE ON DATABASE NYC_TAXI TO ROLE RESP_DEPOT_BRONX;

GRANT USAGE ON WAREHOUSE NYC_TAXI_WH TO ROLE RESP_DEPOT_BRONX;

GRANT USAGE ON SCHEMA NYC_TAXI.MARTS TO ROLE RESP_DEPOT_BRONX;

GRANT USAGE ON SCHEMA NYC_TAXI.GOUVERNANCE TO ROLE RESP_DEPOT_BRONX;

GRANT SELECT ON ALL VIEWS IN SCHEMA NYC_TAXI.GOUVERNANCE TO ROLE RESP_DEPOT_BRONX;

GRANT SELECT ON FUTURE VIEWS IN SCHEMA NYC_TAXI.GOUVERNANCE TO ROLE RESP_DEPOT_BRONX;

GRANT SELECT ON TABLE NYC_TAXI.MARTS.DIM_DEPOT TO ROLE RESP_DEPOT_BRONX;

GRANT SELECT ON TABLE NYC_TAXI.MARTS.DIM_DRIVER TO ROLE RESP_DEPOT_BRONX;

GRANT SELECT ON TABLE NYC_TAXI.MARTS.MART_DRIVER_MONTHLY TO ROLE RESP_DEPOT_BRONX;

CREATE ROLE IF NOT EXISTS ANALYSTE;

GRANT USAGE ON DATABASE NYC_TAXI TO ROLE ANALYSTE;

GRANT USAGE ON WAREHOUSE NYC_TAXI_WH TO ROLE ANALYSTE;

GRANT USAGE ON SCHEMA NYC_TAXI.MARTS TO ROLE ANALYSTE;

GRANT USAGE ON SCHEMA NYC_TAXI.GOUVERNANCE TO ROLE ANALYSTE;

GRANT SELECT ON ALL VIEWS IN SCHEMA NYC_TAXI.GOUVERNANCE TO ROLE ANALYSTE;

GRANT SELECT ON FUTURE VIEWS IN SCHEMA NYC_TAXI.GOUVERNANCE TO ROLE ANALYSTE;

GRANT SELECT ON ALL TABLES IN SCHEMA NYC_TAXI.MARTS TO ROLE ANALYSTE;

GRANT SELECT ON FUTURE TABLES IN SCHEMA NYC_TAXI.MARTS TO ROLE ANALYSTE;

GRANT SELECT ON ALL VIEWS IN SCHEMA NYC_TAXI.MARTS TO ROLE ANALYSTE;

GRANT SELECT ON FUTURE VIEWS IN SCHEMA NYC_TAXI.MARTS TO ROLE ANALYSTE;

-- Source : snowflake/gouvernance/03_masquage.sql
-- Étape 5 : préparation locale ; validation effective à effectuer dans Snowsight.
-- Attendus : docs/ACCES.md. Aucun secret ni valeur personnelle dans les sorties.
-- Masques DIRECTS : les tags sont conservés mais ne déclenchent aucun masquage.
-- Aucun masque sur DEPOT dans MARTS : cette colonne porte le filtre de lignes.
USE SECONDARY ROLES NONE;

USE ROLE GOUVERNANCE;

USE WAREHOUSE NYC_TAXI_WH;

CREATE MASKING POLICY IF NOT EXISTS NYC_TAXI.GOUVERNANCE.MASK_RAW_VARCHAR
  AS (val VARCHAR) RETURNS VARCHAR -> IFF(val IS NULL, NULL, '*****');

ALTER MASKING POLICY NYC_TAXI.GOUVERNANCE.MASK_RAW_VARCHAR SET BODY ->
  CASE WHEN CURRENT_ROLE() = 'TRANSFORMER' THEN val ELSE IFF(val IS NULL, NULL, '*****') END;

CREATE MASKING POLICY IF NOT EXISTS NYC_TAXI.GOUVERNANCE.MASK_RAW_DATE
  AS (val DATE) RETURNS DATE -> NULL;

ALTER MASKING POLICY NYC_TAXI.GOUVERNANCE.MASK_RAW_DATE SET BODY ->
  CASE WHEN CURRENT_ROLE() = 'TRANSFORMER' THEN val ELSE NULL END;

CREATE MASKING POLICY IF NOT EXISTS NYC_TAXI.GOUVERNANCE.MASK_RAW_NUMBER
  AS (val NUMBER) RETURNS NUMBER -> NULL;

ALTER MASKING POLICY NYC_TAXI.GOUVERNANCE.MASK_RAW_NUMBER SET BODY ->
  CASE WHEN CURRENT_ROLE() = 'TRANSFORMER' THEN val ELSE NULL END;

CREATE MASKING POLICY IF NOT EXISTS NYC_TAXI.GOUVERNANCE.MASK_RAW_FLOAT
  AS (val FLOAT) RETURNS FLOAT -> NULL;

ALTER MASKING POLICY NYC_TAXI.GOUVERNANCE.MASK_RAW_FLOAT SET BODY ->
  CASE WHEN CURRENT_ROLE() = 'TRANSFORMER' THEN val ELSE NULL END;

CREATE MASKING POLICY IF NOT EXISTS NYC_TAXI.GOUVERNANCE.MASK_DRIVER_ID
  AS (val VARCHAR) RETURNS VARCHAR -> IFF(val IS NULL, NULL, '*****');

ALTER MASKING POLICY NYC_TAXI.GOUVERNANCE.MASK_DRIVER_ID SET BODY ->
  CASE WHEN CURRENT_ROLE() IN ('RH_PAIE', 'RESP_DEPOT_QUEENS', 'RESP_DEPOT_BRONX', 'ANALYSTE', 'TRANSFORMER') THEN val ELSE IFF(val IS NULL, NULL, '*****') END;

CREATE MASKING POLICY IF NOT EXISTS NYC_TAXI.GOUVERNANCE.MASK_CONTACT
  AS (val VARCHAR) RETURNS VARCHAR -> IFF(val IS NULL, NULL, '*****');

ALTER MASKING POLICY NYC_TAXI.GOUVERNANCE.MASK_CONTACT SET BODY ->
  CASE WHEN CURRENT_ROLE() IN ('TRANSFORMER', 'RH_PAIE', 'RESP_DEPOT_QUEENS', 'RESP_DEPOT_BRONX') THEN val ELSE IFF(val IS NULL, NULL, '*****') END;

CREATE MASKING POLICY IF NOT EXISTS NYC_TAXI.GOUVERNANCE.MASK_PAIE
  AS (val VARCHAR) RETURNS VARCHAR -> IFF(val IS NULL, NULL, '*****');

ALTER MASKING POLICY NYC_TAXI.GOUVERNANCE.MASK_PAIE SET BODY ->
  CASE WHEN CURRENT_ROLE() IN ('TRANSFORMER', 'RH_PAIE') THEN val ELSE IFF(val IS NULL, NULL, '*****') END;

CREATE MASKING POLICY IF NOT EXISTS NYC_TAXI.GOUVERNANCE.MASK_NAISSANCE
  AS (val DATE) RETURNS DATE -> NULL;

ALTER MASKING POLICY NYC_TAXI.GOUVERNANCE.MASK_NAISSANCE SET BODY ->
  CASE WHEN CURRENT_ROLE() IN ('TRANSFORMER', 'RH_PAIE') THEN val WHEN CURRENT_ROLE() = 'ANALYSTE' THEN DATE_TRUNC('year', val)::DATE ELSE NULL END;

-- Rejouabilité : vérifier les associations avant chaque attachement.
-- Une politique différente, par tag, ou inactive provoque une erreur explicite.
EXECUTE IMMEDIATE $$
DECLARE
  conflit EXCEPTION (-20001, 'Politique inattendue ou inactive : lire POLICY_REFERENCES ; aucune politique existante ne sera détachée.');
  nb NUMBER;
  nb_conflits NUMBER;
  objet_courant VARCHAR;
  colonne_courante VARCHAR;
  politique_courante VARCHAR;
  commande VARCHAR;
  c CURSOR FOR SELECT column1 AS objet, column2 AS colonne, column3 AS politique FROM VALUES
    ('RAW.DRIVERS', 'DRIVER_ID', 'MASK_RAW_VARCHAR'),
    ('RAW.DRIVERS', 'FIRST_NAME', 'MASK_RAW_VARCHAR'),
    ('RAW.DRIVERS', 'LAST_NAME', 'MASK_RAW_VARCHAR'),
    ('RAW.DRIVERS', 'EMAIL', 'MASK_RAW_VARCHAR'),
    ('RAW.DRIVERS', 'PHONE', 'MASK_RAW_VARCHAR'),
    ('RAW.DRIVERS', 'BIRTH_DATE', 'MASK_RAW_DATE'),
    ('RAW.DRIVERS', 'TLC_LICENSE_NUMBER', 'MASK_RAW_VARCHAR'),
    ('RAW.DRIVERS', 'DEPOT', 'MASK_RAW_VARCHAR'),
    ('RAW.DRIVERS', 'HIRE_DATE', 'MASK_RAW_DATE'),
    ('RAW.DRIVERS', 'END_DATE', 'MASK_RAW_DATE'),
    ('RAW.DRIVER_SHIFTS', 'SHIFT_ID', 'MASK_RAW_VARCHAR'),
    ('RAW.DRIVER_SHIFTS', 'DRIVER_ID', 'MASK_RAW_VARCHAR'),
    ('RAW.DRIVER_SHIFTS', 'SHIFT_DATE', 'MASK_RAW_DATE'),
    ('RAW.DRIVER_SHIFTS', 'DEPOT', 'MASK_RAW_VARCHAR'),
    ('RAW.DRIVER_SHIFTS', 'START_HOUR', 'MASK_RAW_NUMBER'),
    ('RAW.DRIVER_SHIFTS', 'HOURS_WORKED', 'MASK_RAW_FLOAT'),
    ('RAW.DRIVER_SHIFTS', 'TRIPS_COUNT', 'MASK_RAW_NUMBER'),
    ('RAW.DRIVER_SHIFTS', 'REVENUE_USD', 'MASK_RAW_FLOAT'),
    ('MARTS.DIM_DRIVER', 'DRIVER_ID', 'MASK_DRIVER_ID'),
    ('MARTS.DIM_DRIVER', 'FIRST_NAME', 'MASK_CONTACT'),
    ('MARTS.DIM_DRIVER', 'LAST_NAME', 'MASK_CONTACT'),
    ('MARTS.DIM_DRIVER', 'EMAIL', 'MASK_PAIE'),
    ('MARTS.DIM_DRIVER', 'PHONE', 'MASK_CONTACT'),
    ('MARTS.DIM_DRIVER', 'BIRTH_DATE', 'MASK_NAISSANCE'),
    ('MARTS.DIM_DRIVER', 'TLC_LICENSE_NUMBER', 'MASK_PAIE'),
    ('MARTS.MART_DRIVER_MONTHLY', 'DRIVER_ID', 'MASK_DRIVER_ID'),
    ('MARTS.MART_DRIVER_MONTHLY', 'DRIVER_NAME', 'MASK_CONTACT');
BEGIN
  FOR r IN c DO
    objet_courant := 'NYC_TAXI.' || r.objet;
    colonne_courante := r.colonne;
    politique_courante := r.politique;
    SELECT COUNT(*), COALESCE(COUNT_IF(
      policy_db <> 'NYC_TAXI' OR policy_schema <> 'GOUVERNANCE'
      OR policy_name <> :politique_courante OR tag_name IS NOT NULL
      OR COALESCE(policy_status, '') <> 'ACTIVE'), 0)
      INTO :nb, :nb_conflits
    FROM TABLE(NYC_TAXI.INFORMATION_SCHEMA.POLICY_REFERENCES(
      REF_ENTITY_NAME => :objet_courant, REF_ENTITY_DOMAIN => 'TABLE'))
    WHERE policy_kind = 'MASKING_POLICY' AND ref_column_name = :colonne_courante;
    IF (nb_conflits > 0 OR nb > 1) THEN
      RAISE conflit;
    ELSEIF (nb = 0) THEN
      commande := 'ALTER TABLE ' || objet_courant || ' MODIFY COLUMN ' || colonne_courante
               || ' SET MASKING POLICY NYC_TAXI.GOUVERNANCE.' || politique_courante;
      EXECUTE IMMEDIATE :commande;
    END IF;
  END FOR;
  RETURN '03 terminé : 27 masques directs attendus ; vérifier les associations après 04.';
END;
$$;

-- Source : snowflake/gouvernance/04_acces_depot.sql
-- Étape 5 : préparation locale ; validation effective à effectuer dans Snowsight.
-- Attendus : docs/ACCES.md. Aucun secret ni valeur personnelle dans les sorties.
USE SECONDARY ROLES NONE;

USE ROLE GOUVERNANCE;

USE WAREHOUSE NYC_TAXI_WH;

CREATE TABLE IF NOT EXISTS NYC_TAXI.GOUVERNANCE.ACCES_DEPOT (
  role_name VARCHAR NOT NULL,
  depot VARCHAR NOT NULL
) COMMENT = 'Périmètres de lecture MARTS : rôle principal et dépôt, ou * pour tous ; propriétaire GOUVERNANCE';

-- Une réexécution rétablit la matrice contractuelle (ne garde pas une extension temporaire).
-- DELETE/INSERT atomiques ; aucune suppression/recréation de la table.
EXECUTE IMMEDIATE $$
BEGIN
  BEGIN TRANSACTION;
  DELETE FROM NYC_TAXI.GOUVERNANCE.ACCES_DEPOT;
  INSERT INTO NYC_TAXI.GOUVERNANCE.ACCES_DEPOT (role_name, depot) VALUES
    ('TRANSFORMER', '*'),
    ('RH_PAIE', '*'),
    ('ANALYSTE', '*'),
    ('RESP_DEPOT_QUEENS', 'Queens'),
    ('RESP_DEPOT_BRONX', 'Bronx');
  COMMIT;
  RETURN 'Cinq correspondances initiales restaurées.';
EXCEPTION
  WHEN OTHER THEN
    ROLLBACK;
    RAISE;
END;
$$;

CREATE ROW ACCESS POLICY IF NOT EXISTS NYC_TAXI.GOUVERNANCE.RAP_DEPOT
  AS (depot_ligne VARCHAR) RETURNS BOOLEAN -> FALSE;

ALTER ROW ACCESS POLICY NYC_TAXI.GOUVERNANCE.RAP_DEPOT SET BODY ->
  EXISTS (
    SELECT 1 FROM NYC_TAXI.GOUVERNANCE.ACCES_DEPOT a
    WHERE a.role_name = CURRENT_ROLE()
      AND (a.depot = '*' OR a.depot = depot_ligne)
  );

-- La correspondance est lue avec les droits du propriétaire de la politique.
-- Aucun SELECT ACCES_DEPOT n’est accordé aux métiers ou à TRANSFORMER.
EXECUTE IMMEDIATE $$
DECLARE
  conflit EXCEPTION (-20002, 'Filtre de lignes inattendu/inactif, mauvais argument ou masque sur DEPOT : examiner POLICY_REFERENCES.');
  nb NUMBER;
  nb_conflits NUMBER;
  nb_masques NUMBER;
  objet_courant VARCHAR;
  commande VARCHAR;
  c CURSOR FOR SELECT column1 AS objet FROM VALUES
    ('NYC_TAXI.MARTS.DIM_DRIVER'), ('NYC_TAXI.MARTS.MART_DRIVER_MONTHLY');
BEGIN
  FOR r IN c DO
    objet_courant := r.objet;
    SELECT COUNT(*), COALESCE(COUNT_IF(
      policy_db <> 'NYC_TAXI' OR policy_schema <> 'GOUVERNANCE' OR policy_name <> 'RAP_DEPOT'
      OR REGEXP_REPLACE(UPPER(COALESCE(ref_arg_column_names, ref_column_name, '')), '[^A-Z0-9_]', '') <> 'DEPOT'
      OR COALESCE(policy_status, 'ACTIVE') <> 'ACTIVE'), 0)
      INTO :nb, :nb_conflits
    FROM TABLE(NYC_TAXI.INFORMATION_SCHEMA.POLICY_REFERENCES(
      REF_ENTITY_NAME => :objet_courant, REF_ENTITY_DOMAIN => 'TABLE'))
    WHERE policy_kind = 'ROW_ACCESS_POLICY';
    SELECT COUNT(*) INTO :nb_masques
    FROM TABLE(NYC_TAXI.INFORMATION_SCHEMA.POLICY_REFERENCES(
      REF_ENTITY_NAME => :objet_courant, REF_ENTITY_DOMAIN => 'TABLE'))
    WHERE policy_kind = 'MASKING_POLICY' AND ref_column_name = 'DEPOT';
    IF (nb_conflits > 0 OR nb > 1 OR nb_masques > 0) THEN
      RAISE conflit;
    ELSEIF (nb = 0) THEN
      commande := 'ALTER TABLE ' || objet_courant
               || ' ADD ROW ACCESS POLICY NYC_TAXI.GOUVERNANCE.RAP_DEPOT ON (DEPOT)';
      EXECUTE IMMEDIATE :commande;
    END IF;
  END FOR;
  RETURN '04 terminé : deux filtres attendus, sans détachement ; vérifier avant activation.';
END;
$$;

-- Source : snowflake/gouvernance/modele_catalogue_dim_depot.sql
-- MODÈLE : la fiche de catalogue complète d'une table, écrite en SQL.
-- À exécuter avec le rôle des outils, propriétaire de la table, une fois le schéma GOUVERNANCE et les
-- trois tags créés et le droit de les poser accordé (guide, jour 1, étape 10).
-- Écrivez sur ce modèle un fichier par table à cataloguer.
--
-- Ce fichier est rejouable : COMMENT et SET TAG remplacent la valeur précédente.
-- À savoir : une table recréée (CREATE OR REPLACE TABLE) perd ses descriptions et ses tags.
-- C'est pourquoi le catalogue s'écrit dans des fichiers SQL rejouables, et non à la main dans l'interface.

USE SECONDARY ROLES NONE;

USE ROLE TRANSFORMER;

USE WAREHOUSE NYC_TAXI_WH;

-- 1. La table : ce qu'elle contient, d'où elle vient, à quel rythme elle change
COMMENT ON TABLE NYC_TAXI.MARTS.DIM_DEPOT IS
  'Référentiel des dépôts de Hudson Cab Partners : 1 ligne = 1 dépôt (3 lignes). Source : fichier dim_depot.sql, tenu par l''équipe data. Change seulement à l''ouverture ou à la fermeture d''un dépôt. Responsable : équipe data.';

-- 2. Chaque colonne : sa signification, pas son nom répété
COMMENT ON COLUMN NYC_TAXI.MARTS.DIM_DEPOT.depot     IS 'Nom du dépôt, tel qu''il doit être écrit partout : Bronx, Brooklyn ou Queens. Clé de la table.';

COMMENT ON COLUMN NYC_TAXI.MARTS.DIM_DEPOT.quartier  IS 'Quartier où se trouve le garage.';

COMMENT ON COLUMN NYC_TAXI.MARTS.DIM_DEPOT.ouvert_en IS 'Année d''ouverture du dépôt.';

COMMENT ON COLUMN NYC_TAXI.MARTS.DIM_DEPOT.nb_places IS 'Nombre de taxis que le garage peut accueillir.';

-- 3. Les tags : la sensibilité et la durée de conservation se posent sur la table (les colonnes en héritent)
ALTER TABLE NYC_TAXI.MARTS.DIM_DEPOT SET TAG
  NYC_TAXI.GOUVERNANCE.SENSIBILITE        = 'interne',
  NYC_TAXI.GOUVERNANCE.DUREE_CONSERVATION = 'sans limite : référentiel de l''entreprise';

-- Source : snowflake/rh/catalogue/catalogue_raw_drivers.sql
-- Fiche rejouable ; prérequis : gouvernance/01_gouvernance.sql.
-- Extension donnee_professionnelle autorisée le 6 novembre 2026 ; voir docs/REGISTRE.md.
USE SECONDARY ROLES NONE;

USE ROLE TRANSFORMER;

USE WAREHOUSE NYC_TAXI_WH;

COMMENT ON TABLE NYC_TAXI.RAW.DRIVERS IS 'Une ligne par chauffeur, copie fidèle de drivers.csv avec métadonnées de chargement. Source : service RH fictif. Mise à jour à chaque réception de fichier RH ; responsable : RH, exploitation : équipe data.';

COMMENT ON COLUMN NYC_TAXI.RAW.DRIVERS.driver_id IS 'Identifiant interne du chauffeur, clé de liaison avec les services ; pseudonyme non anonyme.';

COMMENT ON COLUMN NYC_TAXI.RAW.DRIVERS.first_name IS 'Prénom transmis par le service RH ; sert à identifier le chauffeur pour la paie et son responsable.';

COMMENT ON COLUMN NYC_TAXI.RAW.DRIVERS.last_name IS 'Nom de famille transmis par le service RH ; entre dans le nom complet du mart mensuel.';

COMMENT ON COLUMN NYC_TAXI.RAW.DRIVERS.email IS 'Adresse de contact RH ; peut contenir des anomalies mesurées par les contrôles de qualité.';

COMMENT ON COLUMN NYC_TAXI.RAW.DRIVERS.phone IS 'Téléphone de contact opérationnel ; peut être absent dans la source.';

COMMENT ON COLUMN NYC_TAXI.RAW.DRIVERS.birth_date IS 'Date de naissance ; le contrat prévoit seulement l’année pour l’analyste au jour 2.';

COMMENT ON COLUMN NYC_TAXI.RAW.DRIVERS.tlc_license_number IS 'Numéro de licence professionnelle TLC ; identifiant officiel, même si disponible publiquement.';

COMMENT ON COLUMN NYC_TAXI.RAW.DRIVERS.depot IS 'Garage de rattachement du chauffeur ; donnée personnelle indirecte et futur périmètre de filtrage.';

COMMENT ON COLUMN NYC_TAXI.RAW.DRIVERS.hire_date IS 'Date de début du contrat ; sert au contrôle de cohérence et au calcul de l’ancienneté.';

COMMENT ON COLUMN NYC_TAXI.RAW.DRIVERS.end_date IS 'Date de fin du contrat ; NULL indique un chauffeur en poste ; point de départ de la conservation de cinq ans.';

COMMENT ON COLUMN NYC_TAXI.RAW.DRIVERS._source_file IS 'Nom générique du fichier RH chargé, utilisé pour tracer la provenance ; supprimé avec la ligne.';

COMMENT ON COLUMN NYC_TAXI.RAW.DRIVERS._loaded_at IS 'Horodatage technique de lecture du fichier par COPY INTO ; supprimé avec la ligne.';

ALTER TABLE NYC_TAXI.RAW.DRIVERS SET TAG
  NYC_TAXI.GOUVERNANCE.SENSIBILITE = 'confidentiel',
  NYC_TAXI.GOUVERNANCE.DUREE_CONSERVATION = '5 ans après la fin du contrat du chauffeur ; application technique au jour 3';

ALTER TABLE NYC_TAXI.RAW.DRIVERS MODIFY COLUMN driver_id
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'identifiant_interne';

ALTER TABLE NYC_TAXI.RAW.DRIVERS MODIFY COLUMN first_name
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'nom';

ALTER TABLE NYC_TAXI.RAW.DRIVERS MODIFY COLUMN last_name
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'nom';

ALTER TABLE NYC_TAXI.RAW.DRIVERS MODIFY COLUMN email
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'email';

ALTER TABLE NYC_TAXI.RAW.DRIVERS MODIFY COLUMN phone
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'telephone';

ALTER TABLE NYC_TAXI.RAW.DRIVERS MODIFY COLUMN birth_date
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'date_naissance';

ALTER TABLE NYC_TAXI.RAW.DRIVERS MODIFY COLUMN tlc_license_number
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'identifiant_officiel';

-- Données professionnelles rattachées à un chauffeur identifiable.
ALTER TABLE NYC_TAXI.RAW.DRIVERS MODIFY COLUMN depot
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'donnee_professionnelle';

ALTER TABLE NYC_TAXI.RAW.DRIVERS MODIFY COLUMN hire_date
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'donnee_professionnelle';

ALTER TABLE NYC_TAXI.RAW.DRIVERS MODIFY COLUMN end_date
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'donnee_professionnelle';

-- Source : snowflake/rh/catalogue/catalogue_dim_driver.sql
-- Fiche rejouable ; prérequis : gouvernance/01_gouvernance.sql.
-- Extension donnee_professionnelle autorisée le 6 novembre 2026 ; voir docs/REGISTRE.md.
USE SECONDARY ROLES NONE;

USE ROLE TRANSFORMER;

USE WAREHOUSE NYC_TAXI_WH;

COMMENT ON TABLE NYC_TAXI.MARTS.DIM_DRIVER IS 'Dimension RH : une ligne par chauffeur avec statut et ancienneté. Source : RAW.DRIVERS via STAGING.STG_RH__DRIVERS. Reconstruction par INSERT OVERWRITE à chaque pipeline, quotidienne prévue au jour 3 ; responsable : RH, exploitation : équipe data.';

COMMENT ON COLUMN NYC_TAXI.MARTS.DIM_DRIVER.driver_id IS 'Identifiant interne du chauffeur, clé de liaison avec les services ; pseudonyme non anonyme.';

COMMENT ON COLUMN NYC_TAXI.MARTS.DIM_DRIVER.first_name IS 'Prénom transmis par le service RH ; sert à identifier le chauffeur pour la paie et son responsable.';

COMMENT ON COLUMN NYC_TAXI.MARTS.DIM_DRIVER.last_name IS 'Nom de famille transmis par le service RH ; entre dans le nom complet du mart mensuel.';

COMMENT ON COLUMN NYC_TAXI.MARTS.DIM_DRIVER.email IS 'Adresse de contact RH ; peut contenir des anomalies mesurées par les contrôles de qualité.';

COMMENT ON COLUMN NYC_TAXI.MARTS.DIM_DRIVER.phone IS 'Téléphone de contact opérationnel ; peut être absent dans la source.';

COMMENT ON COLUMN NYC_TAXI.MARTS.DIM_DRIVER.birth_date IS 'Date de naissance ; le contrat prévoit seulement l’année pour l’analyste au jour 2.';

COMMENT ON COLUMN NYC_TAXI.MARTS.DIM_DRIVER.tlc_license_number IS 'Numéro de licence professionnelle TLC ; identifiant officiel, même si disponible publiquement.';

COMMENT ON COLUMN NYC_TAXI.MARTS.DIM_DRIVER.depot IS 'Garage de rattachement du chauffeur ; donnée personnelle indirecte et futur périmètre de filtrage.';

COMMENT ON COLUMN NYC_TAXI.MARTS.DIM_DRIVER.hire_date IS 'Date de début du contrat ; sert au contrôle de cohérence et au calcul de l’ancienneté.';

COMMENT ON COLUMN NYC_TAXI.MARTS.DIM_DRIVER.end_date IS 'Date de fin du contrat ; NULL indique un chauffeur en poste ; point de départ de la conservation de cinq ans.';

COMMENT ON COLUMN NYC_TAXI.MARTS.DIM_DRIVER.is_active IS 'Statut calculé : vrai si la date de fin de contrat est NULL ; donnée personnelle professionnelle.';

COMMENT ON COLUMN NYC_TAXI.MARTS.DIM_DRIVER.tenure_years IS 'Ancienneté en années arrondie à une décimale ; jours entre embauche et fin de contrat ou date courante divisés par 365,25.';

ALTER TABLE NYC_TAXI.MARTS.DIM_DRIVER SET TAG
  NYC_TAXI.GOUVERNANCE.SENSIBILITE = 'confidentiel',
  NYC_TAXI.GOUVERNANCE.DUREE_CONSERVATION = '5 ans après la fin du contrat du chauffeur ; application technique au jour 3';

ALTER TABLE NYC_TAXI.MARTS.DIM_DRIVER MODIFY COLUMN driver_id
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'identifiant_interne';

ALTER TABLE NYC_TAXI.MARTS.DIM_DRIVER MODIFY COLUMN first_name
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'nom';

ALTER TABLE NYC_TAXI.MARTS.DIM_DRIVER MODIFY COLUMN last_name
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'nom';

ALTER TABLE NYC_TAXI.MARTS.DIM_DRIVER MODIFY COLUMN email
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'email';

ALTER TABLE NYC_TAXI.MARTS.DIM_DRIVER MODIFY COLUMN phone
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'telephone';

ALTER TABLE NYC_TAXI.MARTS.DIM_DRIVER MODIFY COLUMN birth_date
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'date_naissance';

ALTER TABLE NYC_TAXI.MARTS.DIM_DRIVER MODIFY COLUMN tlc_license_number
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'identifiant_officiel';

-- Données professionnelles rattachées à un chauffeur identifiable.
ALTER TABLE NYC_TAXI.MARTS.DIM_DRIVER MODIFY COLUMN depot
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'donnee_professionnelle';

ALTER TABLE NYC_TAXI.MARTS.DIM_DRIVER MODIFY COLUMN hire_date
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'donnee_professionnelle';

ALTER TABLE NYC_TAXI.MARTS.DIM_DRIVER MODIFY COLUMN end_date
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'donnee_professionnelle';

ALTER TABLE NYC_TAXI.MARTS.DIM_DRIVER MODIFY COLUMN is_active
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'donnee_professionnelle';

ALTER TABLE NYC_TAXI.MARTS.DIM_DRIVER MODIFY COLUMN tenure_years
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'donnee_professionnelle';

-- Source : snowflake/rh/catalogue/catalogue_raw_driver_shifts.sql
-- Fiche rejouable ; prérequis : gouvernance/01_gouvernance.sql.
-- Extension donnee_professionnelle autorisée le 6 novembre 2026 ; voir docs/REGISTRE.md.
USE SECONDARY ROLES NONE;

USE ROLE TRANSFORMER;

USE WAREHOUSE NYC_TAXI_WH;

COMMENT ON TABLE NYC_TAXI.RAW.DRIVER_SHIFTS IS 'Une ligne par service reçu, avec anomalies et doublons conservés. Source : driver_shifts.csv du service RH fictif. Mise à jour à chaque réception de fichier ; responsable : RH, exploitation : équipe data.';

ALTER TABLE NYC_TAXI.RAW.DRIVER_SHIFTS SET TAG
  NYC_TAXI.GOUVERNANCE.SENSIBILITE = 'confidentiel',
  NYC_TAXI.GOUVERNANCE.DUREE_CONSERVATION = '5 ans après la fin du contrat du chauffeur ; application technique au jour 3';

ALTER TABLE NYC_TAXI.RAW.DRIVER_SHIFTS MODIFY COLUMN shift_id
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'identifiant_interne';

ALTER TABLE NYC_TAXI.RAW.DRIVER_SHIFTS MODIFY COLUMN driver_id
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'identifiant_interne';

-- Données professionnelles rattachées à un chauffeur identifiable.
ALTER TABLE NYC_TAXI.RAW.DRIVER_SHIFTS MODIFY COLUMN shift_date
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'donnee_professionnelle';

ALTER TABLE NYC_TAXI.RAW.DRIVER_SHIFTS MODIFY COLUMN depot
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'donnee_professionnelle';

ALTER TABLE NYC_TAXI.RAW.DRIVER_SHIFTS MODIFY COLUMN start_hour
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'donnee_professionnelle';

ALTER TABLE NYC_TAXI.RAW.DRIVER_SHIFTS MODIFY COLUMN hours_worked
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'donnee_professionnelle';

ALTER TABLE NYC_TAXI.RAW.DRIVER_SHIFTS MODIFY COLUMN trips_count
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'donnee_professionnelle';

ALTER TABLE NYC_TAXI.RAW.DRIVER_SHIFTS MODIFY COLUMN revenue_usd
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'donnee_professionnelle';

-- Source : snowflake/rh/catalogue/catalogue_mart_driver_monthly.sql
-- Fiche rejouable ; prérequis : gouvernance/01_gouvernance.sql.
-- Extension donnee_professionnelle autorisée le 6 novembre 2026 ; voir docs/REGISTRE.md.
USE SECONDARY ROLES NONE;

USE ROLE TRANSFORMER;

USE WAREHOUSE NYC_TAXI_WH;

COMMENT ON TABLE NYC_TAXI.MARTS.MART_DRIVER_MONTHLY IS 'Activité mensuelle par chauffeur et dépôt de service : services, heures, courses et recette. Sources : STAGING.STG_RH__DRIVER_SHIFTS et MARTS.DIM_DRIVER pour le nom complet. Reconstruction à chaque pipeline, quotidienne prévue au jour 3 ; responsable : équipe data. Agrégats individuels toujours personnels.';

ALTER TABLE NYC_TAXI.MARTS.MART_DRIVER_MONTHLY SET TAG
  NYC_TAXI.GOUVERNANCE.SENSIBILITE = 'confidentiel',
  NYC_TAXI.GOUVERNANCE.DUREE_CONSERVATION = '5 ans après la fin du contrat du chauffeur ; application technique au jour 3';

ALTER TABLE NYC_TAXI.MARTS.MART_DRIVER_MONTHLY MODIFY COLUMN driver_id
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'identifiant_interne';

ALTER TABLE NYC_TAXI.MARTS.MART_DRIVER_MONTHLY MODIFY COLUMN driver_name
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'nom';

-- Données professionnelles rattachées à un chauffeur identifiable.
ALTER TABLE NYC_TAXI.MARTS.MART_DRIVER_MONTHLY MODIFY COLUMN activity_month
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'donnee_professionnelle';

ALTER TABLE NYC_TAXI.MARTS.MART_DRIVER_MONTHLY MODIFY COLUMN depot
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'donnee_professionnelle';

ALTER TABLE NYC_TAXI.MARTS.MART_DRIVER_MONTHLY MODIFY COLUMN nb_shifts
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'donnee_professionnelle';

ALTER TABLE NYC_TAXI.MARTS.MART_DRIVER_MONTHLY MODIFY COLUMN hours_worked
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'donnee_professionnelle';

ALTER TABLE NYC_TAXI.MARTS.MART_DRIVER_MONTHLY MODIFY COLUMN trips_count
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'donnee_professionnelle';

ALTER TABLE NYC_TAXI.MARTS.MART_DRIVER_MONTHLY MODIFY COLUMN revenue_usd
  SET TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'donnee_professionnelle';

-- Contrôle final identique à verification_post_pipeline.sql.
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
