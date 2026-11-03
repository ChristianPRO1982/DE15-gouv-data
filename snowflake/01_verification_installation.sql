-- Vérifications en lecture seule, après 00_installation.sql.
-- Exécuter bloc par bloc dans Snowsight et comparer aux résultats attendus.
USE SECONDARY ROLES NONE;
USE ROLE ACCOUNTADMIN;

-- Reporter la région dans le README. Vérifier séparément l'édition dans Snowsight.
SELECT CURRENT_REGION() AS region_snowflake;

-- Attendu : NYC_TAXI_WH, taille XSMALL, AUTO_SUSPEND = 60, AUTO_RESUME = true.
-- Le warehouse peut être suspendu tant qu'aucune requête ne nécessite de calcul.
SHOW WAREHOUSES LIKE 'NYC_TAXI_WH';

-- Attendu : NYC_TAXI ; RAW, STAGING et MARTS, avec les schémas système éventuels.
SHOW DATABASES LIKE 'NYC_TAXI';
SHOW SCHEMAS IN DATABASE NYC_TAXI;

-- Attendu : rôle TRANSFORMER et droits accordés par 00_installation.sql :
-- warehouse USAGE/OPERATE, base USAGE, droits de création par schéma, EXECUTE TASK.
SHOW ROLES LIKE 'TRANSFORMER';
SHOW GRANTS TO ROLE TRANSFORMER;
SHOW GRANTS OF ROLE TRANSFORMER;

-- Attendu : changement de rôle et sélection du warehouse sans erreur.
-- Les commandes USE changent le contexte de session, sans modifier les ressources.
USE ROLE TRANSFORMER;
USE WAREHOUSE NYC_TAXI_WH;
USE DATABASE NYC_TAXI;
USE SCHEMA RAW;
SELECT CURRENT_ROLE() AS role_actif,
       CURRENT_WAREHOUSE() AS warehouse_actif,
       CURRENT_DATABASE() AS base_active,
       CURRENT_SCHEMA() AS schema_actif;

-- Attendu : RAW, STAGING et MARTS sont accessibles au rôle des outils.
SHOW SCHEMAS IN DATABASE NYC_TAXI;
