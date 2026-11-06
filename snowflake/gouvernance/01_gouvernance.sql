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

-- Attendu : trois tags, propriétaire GOUVERNANCE ; table vide au premier passage.
SHOW TAGS IN SCHEMA NYC_TAXI.GOUVERNANCE;
DESCRIBE TABLE NYC_TAXI.GOUVERNANCE.QUALITE_RESULTATS;
SHOW GRANTS TO ROLE GOUVERNANCE;
SHOW GRANTS TO ROLE TRANSFORMER;
SELECT COUNT(*) AS nb_mesures FROM NYC_TAXI.GOUVERNANCE.QUALITE_RESULTATS;
