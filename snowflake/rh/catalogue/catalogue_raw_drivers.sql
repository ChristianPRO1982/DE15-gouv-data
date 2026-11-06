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

SELECT column_name, comment FROM NYC_TAXI.INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = 'RAW' AND table_name = 'DRIVERS'
ORDER BY ordinal_position;
SELECT column_name, tag_name, tag_value
FROM TABLE(NYC_TAXI.INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS('NYC_TAXI.RAW.DRIVERS', 'TABLE'));
