-- Fiche rejouable ; prérequis : gouvernance/01_gouvernance.sql.
-- Les catégories professionnelles absentes du contrat restent à clarifier (docs/REGISTRE.md).
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

SELECT column_name, comment FROM NYC_TAXI.INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = 'MARTS' AND table_name = 'DIM_DRIVER'
ORDER BY ordinal_position;
SELECT column_name, tag_name, tag_value
FROM TABLE(NYC_TAXI.INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS('NYC_TAXI.MARTS.DIM_DRIVER', 'TABLE'));
