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

SELECT column_name, comment FROM NYC_TAXI.INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = 'MARTS' AND table_name = 'MART_DRIVER_MONTHLY'
ORDER BY ordinal_position;
SELECT column_name, tag_name, tag_value
FROM TABLE(NYC_TAXI.INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS('NYC_TAXI.MARTS.MART_DRIVER_MONTHLY', 'TABLE'));
