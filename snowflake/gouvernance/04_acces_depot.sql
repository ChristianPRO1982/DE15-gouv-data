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
SELECT role_name, depot FROM NYC_TAXI.GOUVERNANCE.ACCES_DEPOT ORDER BY role_name, depot;
SHOW ROW ACCESS POLICIES IN SCHEMA NYC_TAXI.GOUVERNANCE;
