-- Étape 5 : tests à exécuter dans Snowsight ; ne pas inscrire de résultat supposé.
-- Sorties : statuts et volumes uniquement ; aucune valeur personnelle ni empreinte affichée.
-- Exécuter en entier, APRÈS activation et les tests initiaux.
-- Un seul résultat final : le message OK du bloc après contrôle de l’extension et de la restauration.
-- Précondition : pas de Brooklyn déjà accordé à Queens. Un accès préexistant est conservé.
-- En cas de fermeture/interruption de session, relancer 04 pour rétablir les cinq accès initiaux.
USE SECONDARY ROLES NONE;
USE ROLE GOUVERNANCE;
USE WAREHOUSE NYC_TAXI_WH;
EXECUTE IMMEDIATE $$
DECLARE
  preexistant EXCEPTION (-20004, 'Brooklyn est déjà attribué à Queens : aucune modification ; rétablir la matrice avec 04 avant ce test.');
  echec EXCEPTION (-20005, 'Test extension/restauration non conforme ; correspondance temporaire retirée.');
  nb NUMBER;
  chauffeurs NUMBER;
  mensuels NUMBER;
  retour_chauffeurs NUMBER;
  retour_mensuels NUMBER;
  correspondances NUMBER;
  ajoute BOOLEAN DEFAULT FALSE;
BEGIN
  SELECT COUNT(*) INTO :nb FROM NYC_TAXI.GOUVERNANCE.ACCES_DEPOT
  WHERE role_name = 'RESP_DEPOT_QUEENS' AND depot = 'Brooklyn';
  IF (nb <> 0) THEN RAISE preexistant; END IF;
  INSERT INTO NYC_TAXI.GOUVERNANCE.ACCES_DEPOT VALUES ('RESP_DEPOT_QUEENS', 'Brooklyn');
  ajoute := TRUE;
  USE ROLE RESP_DEPOT_QUEENS;
  USE WAREHOUSE NYC_TAXI_WH;
  SELECT COUNT(*) INTO :chauffeurs FROM NYC_TAXI.MARTS.DIM_DRIVER;
  SELECT COUNT(*) INTO :mensuels FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY;
  USE ROLE GOUVERNANCE;
  USE WAREHOUSE NYC_TAXI_WH;
  DELETE FROM NYC_TAXI.GOUVERNANCE.ACCES_DEPOT
  WHERE role_name = 'RESP_DEPOT_QUEENS' AND depot = 'Brooklyn';
  ajoute := FALSE;
  SELECT COUNT(*) INTO :correspondances FROM NYC_TAXI.GOUVERNANCE.ACCES_DEPOT;
  USE ROLE RESP_DEPOT_QUEENS;
  USE WAREHOUSE NYC_TAXI_WH;
  SELECT COUNT(*) INTO :retour_chauffeurs FROM NYC_TAXI.MARTS.DIM_DRIVER;
  SELECT COUNT(*) INTO :retour_mensuels FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY;
  USE ROLE GOUVERNANCE;
  USE WAREHOUSE NYC_TAXI_WH;
  IF (chauffeurs <> 278 OR mensuels <> 624 OR retour_chauffeurs <> 161
      OR retour_mensuels <> 365 OR correspondances <> 5) THEN RAISE echec; END IF;
  RETURN 'OK : extension 278/624, restauration 161/365, cinq correspondances ; aucune politique modifiée.';
EXCEPTION
  WHEN OTHER THEN
    USE ROLE GOUVERNANCE;
    USE WAREHOUSE NYC_TAXI_WH;
    IF (ajoute) THEN
      DELETE FROM NYC_TAXI.GOUVERNANCE.ACCES_DEPOT
      WHERE role_name = 'RESP_DEPOT_QUEENS' AND depot = 'Brooklyn';
    END IF;
    RAISE;
END;
$$;
