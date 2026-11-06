# Les accès — carte des droits et cahier de tests

Préparé à partir du modèle le 3 novembre 2026. Carte complétée le 4 novembre 2026 à partir des scripts ; déploiement et droits effectifs à vérifier dans Snowsight ; attendus de l’étape 5 écrits le 6 novembre 2026 avant les politiques. Aucun résultat « obtenu » de cette étape n’est encore disponible.

- **Partie 1, jours 1 et 2** : la carte des droits, complétée au fur et à mesure que vous créez rôles et objets ;
- **Partie 2, jour 2** : le cahier de tests, « attendu » écrit avant les politiques, « obtenu » après.

---

## Partie 1 — Carte des droits

À compléter du jour 1 au jour 2. Dans Snowflake, faire une action demande d'être propriétaire de l'objet ou d'avoir reçu un privilège précis. Cette carte vous évite de chercher, à chaque erreur `Insufficient privileges`, quel droit manque et à qui.

Vérifiez chaque ligne dans la documentation des privilèges (ressources du jour 2), puis avec `SHOW GRANTS TO ROLE …`.

### Qui possède quoi

Le propriétaire d'un objet est le rôle qui l'a créé.

| Objet | Propriétaire |
|---|---|
| Tables de `RAW` et de `MARTS` | `TRANSFORMER` (étape 3 confirmée) |
| Schéma `GOUVERNANCE` | `GOUVERNANCE`, transfert confirmé le 4 novembre 2026 |
| Tags | `GOUVERNANCE`, propriété confirmée le 4 novembre 2026 |
| Politiques de masquage | `GOUVERNANCE`, prévues jour 2 |
| Politique d'accès par ligne | `GOUVERNANCE`, prévue jour 2 |
| Table `ACCES_DEPOT` | `GOUVERNANCE`, prévue jour 2 |
| Table `QUALITE_RESULTATS` | `GOUVERNANCE`, propriété confirmée le 4 novembre 2026 |
| Vue `V_CATALOGUE` | `TRANSFORMER`, création prévue jour 3 |

### Qui fait quoi, avec quel droit

| Action | Rôle qui la fait | Privilège nécessaire | Accordé par |
|---|---|---|---|
| Créer un tag | `GOUVERNANCE` | `CREATE TAG` sur le schéma, ou en être propriétaire | `ACCOUNTADMIN` |
| Poser un tag sur une colonne de `DIM_DRIVER` | `TRANSFORMER` | Propriété de la table + `APPLY` sur le tag + accès base/schémas | `GOUVERNANCE` accorde APPLY et USAGE sur son schéma |
| Créer une politique de masquage | `GOUVERNANCE` | Propriété du schéma (ou CREATE MASKING POLICY) | `ACCOUNTADMIN` transfère le schéma ; création jour 2 |
| Attacher un masque directement à une colonne | `GOUVERNANCE` | APPLY MASKING POLICY global + accès base/schéma ; aucun SELECT requis | `ACCOUNTADMIN` ; script 03 préparé, exécution à confirmer |
| Ajouter une politique d'accès par ligne à une table | `GOUVERNANCE` | APPLY ROW ACCESS POLICY sur le compte, accès base/schéma | `ACCOUNTADMIN` ; attachement jour 2 |
| Écrire une ligne dans `QUALITE_RESULTATS` | `TRANSFORMER` | INSERT sur la table, USAGE sur base/schéma | `GOUVERNANCE` ; SELECT également accordé pour contrôler |
| Lire `DIM_DRIVER` | `TRANSFORMER` ; rôles métier prévus jour 2 | Propriété ou SELECT, USAGE base/schéma et warehouse | Propriété TRANSFORMER ; droits métier à créer jour 2 |
| Exécuter une requête | chaque rôle | USAGE warehouse et droits sur objets visés | `ACCOUNTADMIN` pour NYC_TAXI_WH |
| Créer la future vue de catalogue | `TRANSFORMER` | CREATE VIEW et USAGE sur GOUVERNANCE ; accès aux sources | `GOUVERNANCE` |

### Ce que cette carte permet à un rôle de défaire

`TRANSFORMER`, propriétaire des tables, peut modifier les objets et dispose de leur contenu réel. Le masquage retenu à l’étape 5 est direct : retirer un tag ne le retire pas. Ses possibilités de détachement et les droits APPLY doivent être surveillés. `GOUVERNANCE` peut changer les règles ou les détacher avec ses privilèges globaux ; il ne reçoit aucun SELECT sur RAW, STAGING ou MARTS, ni aucun rôle de lecture en héritage. Les administrateurs peuvent changer les droits : les futures politiques doivent aussi tester leur lecture.

Ces pouvoirs sont nécessaires au montage pédagogique ; l’audit des lectures et changements reste à mettre en place au jour 3. Les droits métier et les politiques ne sont pas créés à cette étape. Contrôler `SHOW GRANTS TO ROLE GOUVERNANCE` avec ACCOUNTADMIN, y compris les éventuels rôles hérités préexistants ; `CREATE IF NOT EXISTS` ne supprime pas d’anciens droits.

Sources vérifiées le 4 novembre 2026 : [privilèges Snowflake](https://docs.snowflake.com/en/user-guide/security-access-control-privileges), [gestion des tags](https://docs.snowflake.com/en/user-guide/object-tagging/work). Résultats de `01_gouvernance.sql` reçus et conformes le 4 novembre 2026 : propriétés du schéma, des trois tags et de QUALITE_RESULTATS, droits globaux de GOUVERNANCE, droits de TRANSFORMER sur les tags, les résultats et la création de vues. Aucun SELECT RH ni rôle de lecture hérité dans les attributions fournies de GOUVERNANCE ; NB_MESURES = 0. Contrôle global du catalogue reçu le 6 novembre 2026 : conforme (5 tables décrites, 28 colonnes décrites, 18 tags personnels OK) ; propriétés TRANSFORMER sur les cinq tables et les deux vues STAGING confirmées. Attribution de GOUVERNANCE à l’utilisateur testeur confirmée, aucun identifiant personnel recopié. Rejouabilité et capture encore attendues.

---



**Rejouabilité de l’installation de gouvernance confirmée le 6 novembre 2026 :** après relance de `snowflake/gouvernance/01_gouvernance.sql`, le titulaire transmet les trois tags avec leurs dates de création initiales et les valeurs autorisées inchangées, la structure conforme de QUALITE_RESULTATS, les propriétaires et droits attendus pour GOUVERNANCE et TRANSFORMER, puis NB_MESURES = 0. Cette relance est validée sur ces résultats ; la conservation de mesures préexistantes n’est pas testée puisque la table est vide. La relance des cinq fiches, le nouveau contrôle global et la capture restent à confirmer.

**Clôture des vérifications de l’étape 4 le 6 novembre 2026 :** après relance des scripts, le titulaire confirme aucune description manquante, 5 tables décrites sur 5, 28 colonnes décrites sur 28 et 18 tags personnels OK sur 18. Capture `docs/tags_dim_driver.png` examinée et export complet `docs/tags_dim_driver.csv` vérifié. Rejouabilité confirmée sur ces résultats. L’écart de taxonomie professionnelle reste à clarifier ; aucune politique métier n’est validée par ces contrôles.

**Extension autorisée le 6 novembre 2026 — état actuel :** le titulaire accepte `donnee_professionnelle`. Cette décision remplace le maintien de l’écart dans les états précédents. Tag existant, quatre fiches, inventaire et contrôle global adaptés localement : 20 affectations supplémentaires, 38 attendues au total. Déploiement et contrôle Snowflake restent à confirmer ; la case de taggage intégral reste ouverte jusqu’à réception des 38 statuts OK. Après validation, actualiser les preuves DIM_DRIVER (12 tags personnels, 36 références au total).

**Extension appliquée — confirmation du titulaire le 6 novembre 2026 :** tous les scripts passent et le contrôle affiche les quantités attendues : 5 tables, 28 colonnes et 38 lignes pour les tags personnels. Les deux propriétés du tag ont été modifiées par des ALTER TAG séparés. La case de taggage intégral est cochée sur cette confirmation. Le classement professionnel est désormais appliqué ; le contrat pédagogique reste inchangé, l’adaptation étant documentée. Le titulaire confirme ici la réussite et les quantités ; aucun nouveau tableau détaillé des statuts n’a été transmis. Les preuves PNG/CSV conservées décrivent l’ancien état de DIM_DRIVER (7 tags personnels, 31 références) et restent à actualiser pour l’extension (12 tags personnels, 36 références).

**Preuves renouvelées vérifiées le 6 novembre 2026 :** `docs/tags_dim_driver.csv` contient 36 références : 12 DONNEE_PERSONNELLE, 12 DUREE_CONSERVATION et 12 SENSIBILITE. Les cinq affectations donnee_professionnelle attendues sont présentes sur DEPOT, HIRE_DATE, END_DATE, IS_ACTIVE et TENURE_YEARS. La capture `docs/tags_dim_driver.png` renouvelée est lisible, affiche 36 lignes au total et montre la nouvelle catégorie sur les premières lignes. Elle complète le CSV intégral. Ces preuves remplacent les anciens fichiers à 31 références. Étape 4 terminée avec l’extension de taxonomie autorisée par le titulaire et documentée, sans modification du contrat fourni.

## Partie 2 — Cahier de tests — étape 5

**Attendus écrits le 6 novembre 2026, avant les politiques.** Préparation locale uniquement : tous les résultats obtenus restent « À exécuter ». Les volumes ci-dessous viennent des CSV locaux avant purge, pas d’une exécution Snowflake. Les erreurs de lecture attendues doivent être constatées, jamais présumées.

### Convention des masques et matrice des valeurs

- Texte interdit : `*****` ; un NULL source reste NULL.
- DATE interdite : NULL de type DATE. Pour ANALYSTE, `birth_date` est ramenée au 1er janvier de son année : cette date conventionnelle représente une année, jamais le jour réel de naissance.
- NUMBER et FLOAT interdits dans RAW : NULL du même type. Les BOOLEAN et les autres données professionnelles de MARTS restent visibles dans les lignes autorisées.
- Les quatre rôles métier et TRANSFORMER lisent `driver_id` dans MARTS. Cette exception ne concerne ni RAW ni `shift_id`.
- Les politiques sont attachées directement aux colonnes, pas au tag : retirer un tag ne retire pas le masque. Les 38 affectations du catalogue sont conservées. `depot` dans MARTS est seulement paramètre de la politique d’accès par ligne.

| Colonnes MARTS | RH_PAIE | RESP_DEPOT_QUEENS / BRONX | ANALYSTE | TRANSFORMER |
|---|---|---|---|---|
| `driver_id` (deux tables) | Clair | Clair | Clair | Clair |
| `first_name`, `last_name`, `driver_name`, `phone` | Clair | Clair | `*****` ou NULL source | Clair |
| `email`, `tlc_license_number` | Clair | `*****` ou NULL source | `*****` ou NULL source | Clair |
| `birth_date` | Date réelle | NULL | 1er janvier de l’année source | Date réelle |
| `depot`, `hire_date`, `end_date`, `is_active`, `tenure_years` | Clair | Clair | Clair | Clair |
| `activity_month`, `nb_shifts`, `hours_worked`, `trips_count`, `revenue_usd` | Clair | Clair | Clair | Clair |

Cette visibilité des données professionnelles a été choisie par le titulaire. Les données pseudonymisées restent personnelles. Aucun résultat nominatif ne doit être enregistré dans le dépôt public.

### Volumes et périmètres

Chaque bloc de `snowflake/gouvernance/05_tests_acces.sql` commence par `USE SECONDARY ROLES NONE`, puis le rôle et le warehouse. Lancer les blocs séparément. Un refus attendu figure dans le résultat du bloc, pas dans une exception ignorée.

| N° | Rôle | DIM_DRIVER | MART_DRIVER_MONTHLY | DIM_DEPOT | Obtenu | Conforme ? |
|---|---|---:|---:|---:|---|---|
| V1 | RH_PAIE | 400 | 914 | 3 | À exécuter | Non vérifié |
| V2 | RESP_DEPOT_QUEENS | 161, Queens seul | 365, Queens seul | 3 | À exécuter | Non vérifié |
| V3 | RESP_DEPOT_BRONX | 122, Bronx seul | 290, Bronx seul | 3 | À exécuter | Non vérifié |
| V4 | ANALYSTE | 400 | 914 | 3 | À exécuter | Non vérifié |
| V5 | TRANSFORMER | 400 | 914 | 3 | À exécuter | Non vérifié |
| V6 | GOUVERNANCE | Lecture refusée | Lecture refusée | Lecture refusée | À exécuter | Non vérifié |
| V7 | ACCOUNTADMIN | 0 | 0 | 3 (héritage propriétaire) | À exécuter | Non vérifié |
| V8 | SYSADMIN, absent de la matrice métier | 0 | 0 | 3 (héritage propriétaire) | À exécuter | Non vérifié |

Les responsables doivent voir leur dépôt exclusivement dans les deux tables RH ; les trois dépôts restent lisibles dans le référentiel DIM_DEPOT.

### Valeurs du chauffeur témoin et vérification exhaustive

D0003 appartient à Queens et possède trois lignes mensuelles à Queens. Sa naissance pour l’analyste doit devenir le 1er janvier de l’année source. Les valeurs réelles de la source restent locales. TRANSFORMER mémorise des empreintes temporaires de référence en variables de session ; les tests comparent les valeurs sans les afficher.

| N° | Vérification sur D0003 | Attendu | Obtenu | Conforme ? |
|---|---|---|---|---|
| D1 | RH_PAIE : toutes les colonnes et nom mensuel | Identiques à la transformation source | À exécuter | Non vérifié |
| D2 | Responsable Queens | Identifiant, noms, téléphone et professionnel réels ; e-mail/licence masqués ; naissance NULL | À exécuter | Non vérifié |
| D3 | Responsable Bronx | Aucune ligne, dans les deux tables | À exécuter | Non vérifié |
| D4 | ANALYSTE | Identifiant réel ; noms/téléphone/e-mail/licence masqués ; année seule ; professionnel réel | À exécuter | Non vérifié |
| D5 | TRANSFORMER | Valeurs complètes conformes à la source | À exécuter | Non vérifié |
| D6 | Tous les rôles métier | Même comportement sur toutes les lignes de leur périmètre ; NULL préservés | À exécuter | Non vérifié |

### Restrictions RAW et STAGING

| N° | Rôle | Attendu | Obtenu | Conforme ? |
|---|---|---|---|---|
| R1 | Chaque rôle métier | SELECT refusé sur les deux RAW et les deux vues STAGING | À exécuter | Non vérifié |
| R2 | GOUVERNANCE | SELECT refusé sur les deux RAW et les deux STAGING | À exécuter | Non vérifié |
| R3 | TRANSFORMER | 400 chauffeurs RAW/STAGING, 25 951 services RAW, 25 933 services STAGING ; valeurs réelles | À exécuter | Non vérifié |
| R4 | ACCOUNTADMIN et SYSADMIN | Les 18 colonnes personnelles RAW masquées ; protections aussi appliquées dans STAGING | À exécuter | Non vérifié |
| R5 | Rôles métier et TRANSFORMER | SELECT sur ACCES_DEPOT refusé ; la politique lit avec les droits de GOUVERNANCE | À exécuter | Non vérifié |

Pour R4, le masquage de `shift_id` fusionne les partitions de la vue STAGING de dédoublonnage : le nombre de services vu par l’administrateur peut différer des 25 933 vus par TRANSFORMER. Ce test vérifie les masques, pas le volume de cette vue sous l’administrateur.

### Correspondances, pipeline et rejouabilité

| N° | Vérification | Attendu | Obtenu | Conforme ? |
|---|---|---|---|---|
| P1 | Brooklyn ajouté temporairement à Queens | 278 chauffeurs, 624 lignes mensuelles ; aucun changement de politique | À exécuter | Non vérifié |
| P2 | Correspondance temporaire retirée | Retour à 161 / 365 ; cinq correspondances initiales | À exécuter | Non vérifié |
| P3 | Reconstruction STAGING puis trois MARTS avec TRANSFORMER | Volumes constants, contenu identique avant/après ; noms, contacts et calculs conformes aux sources | À exécuter | Non vérifié |
| P4 | Catalogue et attachements après reconstruction | 5 tables décrites, 28 colonnes décrites, 38 tags personnels OK ; 27 masquages et 2 filtres attendus | À exécuter | Non vérifié |
| P5 | Deuxième passage des scripts 01 à 04 et des fiches catalogue | Aucun échec, aucune politique détachée, aucune correspondance dupliquée ; tests toujours conformes | À exécuter | Non vérifié |
| P6 | Droits actuels/futurs, propriété et héritages | Rôles métier sans RAW/STAGING ni rôle privilégié hérité ; aucun SELECT RH pour GOUVERNANCE ; droits catalogue prévus | À exécuter | Non vérifié |
| P7 | Requête de capture identique sous RH_PAIE puis ANALYSTE | Trois groupes par dépôt ; mêmes volumes, masquages différents ; aucune valeur personnelle affichée | À exécuter | Non vérifié |

P1/P2 sont dans `test_extension_depot.sql` : le test rétablit les accès même si sa vérification échoue. P3 est dans `verification_pipeline_acces.sql` ; P4 utilise aussi le contrôle catalogue existant. `verification_politiques.sql` contrôle chaque attachement et son statut, pas seulement leur nombre.

### Bac à sable — prédictions à lire avant les exemples

Prérequis : exemples 00 puis 01 exécutés dans EXEMPLE_GOUV ; vérifier 6 clients et 5 colonnes taguées. Les résultats de ces exemples ne prouvent pas les accès NYC_TAXI.

| Bloc | Attendu | Obtenu |
|---|---|---|
| 02, pipeline | Six lignes, valeurs réelles | À exécuter |
| 02, vendeur | Nom/téléphone réels ; e-mail avec domaine conservé ; score NULL | À exécuter |
| 02, analyste | Identité masquée, identifiant visible ; score C1 arrondi à 700 | À exécuter |
| 02, prédicat sur e-mail masqué | Aucun résultat pour le préfixe personnel réel | À exécuter |
| 03, vendeur | Nord seul, 2 lignes | À exécuter |
| 03, analyste | Trois régions, 6 lignes | À exécuter |
| 03, ajout Sud | Vendeur : Nord et Sud, 4 lignes | À exécuter |
| 03, reconstruction | Toujours six lignes pipeline et mêmes masques analyste | À exécuter |
| Nettoyage ciblé de Sud | Vendeur revenu à Nord, 2 lignes | À exécuter |

Après l’exemple 03, avec EX_GOUVERNANCE : `DELETE FROM EXEMPLE_GOUV.GOUVERNANCE.ACCES_REGION WHERE role_name = 'EX_VENDEUR' AND region = 'Sud';`. Repasser ensuite à EX_VENDEUR avec rôles secondaires désactivés et warehouse EXEMPLE_WH pour vérifier les 2 lignes. Pour rejouer l’ensemble, reprendre 00, 01, 02, 03 : le vendeur peut déjà être filtré par le 03 précédent pendant le 02.

### Recueil des preuves

Après chaque bloc, transmettre son identifiant, ses statuts et les quantités agrégées. Conserver les messages de refus sans nom d’utilisateur. Ne remplir « obtenu » et ne cocher les tests qu’après observation. Capture prévue : `docs/acces_comparaison_roles.png`, obtenue avec `capture_acces.sql`, sans noms, coordonnées ni identifiants de chauffeur. Aucun résultat Snowflake de l’étape 5 n’a été reçu à ce jour.

### Vérification locale de la préparation — 6 novembre 2026

Contrôle hors Snowflake réussi : 264 évaluations des corps SQL de masque sur 11 rôles et trois valeurs par type (dont NULL), via SQLite et équivalents de fonctions ; prédicat de lignes évalué contre les volumes issus des CSV, avec extension/restauration de Brooklyn ; dix scénarios sur la requête de comparaison des métadonnées, dont politiques manquantes, doublons, mauvais statut ou argument de filtre. Cohérence des 38 tags, des 27 masques et des 2 filtres, variables de session, requêtes de capture identiques et copies des transformations contrôlées. Ces vérifications n’exécutent ni le moteur Snowflake, ni ses DDL, ni ses droits : tous les résultats « obtenu » restent à confirmer dans Snowsight.
