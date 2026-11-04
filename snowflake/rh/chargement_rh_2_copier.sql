-- =====================================================================
-- chargement_rh_2_copier.sql — FOURNI : charger les deux fichiers RH dans RAW, étape 2 sur 2 : copier.
-- Le chargement se fait en trois temps (guide, jour 1, étape 8) :
--   1. chargement_rh_1_preparer.sql : format de fichier, stage, tables ;
--   2. déposer les deux CSV sur le stage depuis Snowsight (pas de SQL, voir la fin du fichier 1) ;
--   3. chargement_rh_2_copier.sql : copie dans les tables, stage vidé, vérifications.
-- Exécuter chaque fichier en entier (Cmd+Maj+Entrée). Rejouable.
-- =====================================================================
USE SECONDARY ROLES NONE;
USE ROLE TRANSFORMER;
USE WAREHOUSE NYC_TAXI_WH;

-- Premier chargement : les deux fichiers doivent être sur le stage (LIST → 2 lignes).
-- Relance après purge : stage vide, donc 0 fichier traité et volumes inchangés.
-- ===================================================================== C. Copier, puis vider le stage
-- $1, $2… : les colonnes du fichier, dans l'ordre. METADATA$… : le nom du fichier et l'heure du chargement.
-- PURGE = TRUE retire le fichier du stage une fois copié : c'est la règle R3 du contrat.
-- PATTERN sélectionne chaque nom de fichier sans exiger sa présence après purge.
-- FILES provoquerait une erreur si le fichier nommé a déjà été retiré du stage.
COPY INTO NYC_TAXI.RAW.DRIVERS
FROM (SELECT $1, $2, $3, $4, $5, $6::date, $7, $8, $9::date, $10::date,
             METADATA$FILENAME, METADATA$START_SCAN_TIME::timestamp_ntz
      FROM @NYC_TAXI.RAW.RH_STAGE)
PATTERN = '(^|.*/)drivers[.]csv$'
FILE_FORMAT = (FORMAT_NAME = NYC_TAXI.RAW.CSV_RH)
ON_ERROR = ABORT_STATEMENT
PURGE = TRUE;

COPY INTO NYC_TAXI.RAW.DRIVER_SHIFTS
FROM (SELECT $1, $2, $3::date, $4, $5::integer, $6::float, $7::integer, $8::float,
             METADATA$FILENAME, METADATA$START_SCAN_TIME::timestamp_ntz
      FROM @NYC_TAXI.RAW.RH_STAGE)
PATTERN = '(^|.*/)driver_shifts[.]csv$'
FILE_FORMAT = (FORMAT_NAME = NYC_TAXI.RAW.CSV_RH)
ON_ERROR = ABORT_STATEMENT
PURGE = TRUE;

-- Vérifier : 400 chauffeurs, 25 951 services, 0 fichier resté sur le stage
SELECT
    (SELECT COUNT(*) FROM NYC_TAXI.RAW.DRIVERS)       AS chauffeurs,
    (SELECT COUNT(*) FROM NYC_TAXI.RAW.DRIVER_SHIFTS) AS services;
LIST @NYC_TAXI.RAW.RH_STAGE;            -- aucun fichier
-- Relancé sur le stage vide : chaque COPY indique « Copy executed with 0 files processed. ».
-- L'historique de COPY protège aussi contre le rechargement des mêmes fichiers dans sa fenêtre
-- de suivi ; ne pas forcer leur rechargement avec FORCE = TRUE.
