-- Fiche rejouable ; prérequis : gouvernance/01_gouvernance.sql.
-- Les catégories professionnelles absentes du contrat restent à clarifier (docs/REGISTRE.md).
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

SELECT column_name, comment FROM NYC_TAXI.INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = 'RAW' AND table_name = 'DRIVER_SHIFTS'
ORDER BY ordinal_position;
SELECT column_name, tag_name, tag_value
FROM TABLE(NYC_TAXI.INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS('NYC_TAXI.RAW.DRIVER_SHIFTS', 'TABLE'));
