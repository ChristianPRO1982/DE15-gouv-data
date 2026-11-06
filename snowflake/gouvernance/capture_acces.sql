-- Exécuter EN ENTIER : la même requête sous RH_PAIE et ANALYSTE, un tableau de six lignes.
-- Capturer uniquement le tableau dans docs/acces_comparaison_roles.png.
-- Les compteurs sont agrégés par dépôt : aucun identifiant ou contact personnel affiché.
-- Une naissance réelle peut tomber le 1er janvier ; ce compteur n’est pas la preuve de l’année seule.
-- Les comparaisons exhaustives du cahier de tests vérifient cette règle séparément.
EXECUTE IMMEDIATE $$
DECLARE
  role_initial VARCHAR DEFAULT CURRENT_ROLE();
  commande VARCHAR;
  resultats ARRAY DEFAULT ARRAY_CONSTRUCT();
  lignes RESULTSET;
  sortie RESULTSET;
  c CURSOR FOR SELECT column1 AS ordre, column2 AS role_cible
    FROM VALUES (1, 'RH_PAIE'), (2, 'ANALYSTE') ORDER BY column1;
BEGIN
  USE SECONDARY ROLES NONE;
  FOR r IN c DO
    commande := 'USE ROLE ' || r.role_cible;
    EXECUTE IMMEDIATE :commande;
    USE WAREHOUSE NYC_TAXI_WH;
    -- Chaîne SQL identique pour les deux rôles.
    commande := 'SELECT CURRENT_ROLE() AS role_actif, depot, COUNT(*) AS nb_chauffeurs,
       COALESCE(COUNT_IF(first_name = ''*****''), 0) AS prenoms_masques,
       COALESCE(COUNT_IF(last_name = ''*****''), 0) AS noms_masques,
       COALESCE(COUNT_IF(email = ''*****''), 0) AS emails_masques,
       COALESCE(COUNT_IF(phone = ''*****''), 0) AS telephones_masques,
       COALESCE(COUNT_IF(birth_date IS NOT NULL AND birth_date = DATE_TRUNC(''year'', birth_date)::DATE), 0) AS dates_reduites_au_1er_janvier
FROM NYC_TAXI.MARTS.DIM_DRIVER GROUP BY depot ORDER BY depot';
    lignes := (EXECUTE IMMEDIATE :commande);
    FOR ligne IN lignes DO
      resultats := ARRAY_APPEND(resultats, OBJECT_CONSTRUCT(
        'ordre', r.ordre,
        'role_actif', ligne.role_actif,
        'depot', ligne.depot,
        'nb_chauffeurs', ligne.nb_chauffeurs,
        'prenoms_masques', ligne.prenoms_masques,
        'noms_masques', ligne.noms_masques,
        'emails_masques', ligne.emails_masques,
        'telephones_masques', ligne.telephones_masques,
        'dates_reduites_au_1er_janvier', ligne.dates_reduites_au_1er_janvier));
    END FOR;
  END FOR;
  commande := 'USE ROLE "' || REPLACE(role_initial, '"', '""') || '"';
  EXECUTE IMMEDIATE :commande;
  sortie := (
    SELECT value:role_actif::VARCHAR AS role_actif,
           value:depot::VARCHAR AS depot,
           value:nb_chauffeurs::NUMBER AS nb_chauffeurs,
           value:prenoms_masques::NUMBER AS prenoms_masques,
           value:noms_masques::NUMBER AS noms_masques,
           value:emails_masques::NUMBER AS emails_masques,
           value:telephones_masques::NUMBER AS telephones_masques,
           value:dates_reduites_au_1er_janvier::NUMBER AS dates_reduites_au_1er_janvier
    FROM TABLE(FLATTEN(INPUT => :resultats)) ORDER BY value:ordre::NUMBER, value:depot::VARCHAR
  );
  RETURN TABLE(sortie);
EXCEPTION
  WHEN OTHER THEN
    commande := 'USE ROLE "' || REPLACE(role_initial, '"', '""') || '"';
    EXECUTE IMMEDIATE :commande;
    RAISE;
END;
$$;
