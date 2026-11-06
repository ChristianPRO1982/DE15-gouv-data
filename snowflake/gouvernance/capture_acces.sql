-- Étape 5 : tests à exécuter dans Snowsight ; ne pas inscrire de résultat supposé.
-- Sorties : statuts et volumes uniquement ; aucune valeur personnelle ni empreinte affichée.
-- Deux blocs séparés ; capturer les deux résultats sans identifiant de compte/utilisateur.
-- Les dates réelles du service paie peuvent aussi tomber le 1er janvier : le dernier
-- compteur ne suffit pas seul à prouver l’année. Le cahier teste l’égalité à la source.
USE SECONDARY ROLES NONE;
USE ROLE RH_PAIE;
USE WAREHOUSE NYC_TAXI_WH;
SELECT CURRENT_ROLE() AS role_actif, depot, COUNT(*) AS nb_chauffeurs,
       COALESCE(COUNT_IF(first_name = '*****'), 0) AS prenoms_masques,
       COALESCE(COUNT_IF(last_name = '*****'), 0) AS noms_masques,
       COALESCE(COUNT_IF(email = '*****'), 0) AS emails_masques,
       COALESCE(COUNT_IF(phone = '*****'), 0) AS telephones_masques,
       COALESCE(COUNT_IF(birth_date IS NOT NULL AND birth_date = DATE_TRUNC('year', birth_date)::DATE), 0) AS dates_reduites_au_1er_janvier
FROM NYC_TAXI.MARTS.DIM_DRIVER GROUP BY depot ORDER BY depot;

USE SECONDARY ROLES NONE;
USE ROLE ANALYSTE;
USE WAREHOUSE NYC_TAXI_WH;
SELECT CURRENT_ROLE() AS role_actif, depot, COUNT(*) AS nb_chauffeurs,
       COALESCE(COUNT_IF(first_name = '*****'), 0) AS prenoms_masques,
       COALESCE(COUNT_IF(last_name = '*****'), 0) AS noms_masques,
       COALESCE(COUNT_IF(email = '*****'), 0) AS emails_masques,
       COALESCE(COUNT_IF(phone = '*****'), 0) AS telephones_masques,
       COALESCE(COUNT_IF(birth_date IS NOT NULL AND birth_date = DATE_TRUNC('year', birth_date)::DATE), 0) AS dates_reduites_au_1er_janvier
FROM NYC_TAXI.MARTS.DIM_DRIVER GROUP BY depot ORDER BY depot;
