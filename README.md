# Hudson Cab — Gouvernance Snowflake

Projet d’école : cataloguer les données RH de chauffeurs, définir leurs accès et leur conservation, contrôler leur qualité et auditer leurs lectures dans Snowflake.

Le projet est installé à la racine de ce dépôt. `brief/` contient les consignes locales et `chris/` les documents de travail ; ces deux dossiers sont exclus du rendu par Git.

## Préparation de l’environnement

Le starter-kit est installé : `snowflake/`, `docs/`, `exemples/`, `data/`, le contrat et le guide. Les deux CSV RH restent disponibles localement dans `data/` et sont exclus du suivi Git, ainsi que les fichiers de secrets.

Le compte utilisé est le compte d’essai personnel existant. Aucun compte supplémentaire n’est nécessaire. Le titulaire exécute les scripts dans Snowsight ; leur état est suivi ci-dessous à partir des résultats transmis.

| Élément | État |
|---|---|
| Installation locale du starter-kit | Terminée |
| Exclusion Git des CSV RH et des secrets | Vérifiée localement |
| Compte d’essai personnel | Existant, déclaré par son titulaire |
| Édition Enterprise | Enterprise, confirmée le 3 novembre 2026 dans Admin → Accounts par le titulaire du compte |
| Région Snowflake | AWS — EU (Paris), `AWS_EU_WEST_3`, confirmée le 3 novembre 2026 par `SELECT CURRENT_REGION();` |
| Installation des ressources Snowflake | Script exécuté par le titulaire le 3 novembre 2026 ; résultat final reçu : schémas RAW, STAGING et MARTS présents dans NYC_TAXI |
| Vérification des ressources et des droits | Validée le 3 novembre 2026 à partir des résultats Snowsight transmis : warehouse, base, schémas et droits de TRANSFORMER conformes |

Vérifications reçues le 3 novembre 2026 :

- `NYC_TAXI_WH` : taille `X-Small`, suspension automatique à 60 secondes et reprise automatique activée ; état `SUSPENDED` lors du contrôle.
- `NYC_TAXI` : schémas `RAW`, `STAGING` et `MARTS` présents et visibles avec `TRANSFORMER`.
- `TRANSFORMER` : `USAGE` et `OPERATE` sur le warehouse, `USAGE` sur la base et les trois schémas ; `CREATE TABLE`, `CREATE STAGE`, `CREATE FILE FORMAT` sur RAW ; `CREATE TABLE`, `CREATE VIEW` sur STAGING ; `CREATE TABLE`, `CREATE VIEW`, `CREATE TASK` sur MARTS ; `EXECUTE TASK` sur le compte.
- Hiérarchie : rôle `TRANSFORMER` accordé à `SYSADMIN`. Les résultats transmis ne montrent pas d’attribution directe à un utilisateur ; le rôle est néanmoins activable dans la session testée.
- Contexte de session confirmé : rôle `TRANSFORMER`, warehouse `NYC_TAXI_WH`, base `NYC_TAXI`, schéma `RAW`.

La préparation de l’environnement est validée. Ces vérifications précèdent le chargement RH et la mise en place des politiques de gouvernance.

### Dans Snowsight

1. Se connecter au compte d’essai existant et vérifier son édition dans les informations du compte. Le brief nécessite Enterprise ; si le compte est Standard, résoudre ce prérequis avant de poursuivre.
2. Ouvrir une feuille SQL avec le rôle `ACCOUNTADMIN` et exécuter en entier [snowflake/00_installation.sql](snowflake/00_installation.sql). Ce script fourni crée le warehouse, la base, les trois schémas et le rôle des outils avec ses droits.
3. Exécuter [snowflake/01_verification_installation.sql](snowflake/01_verification_installation.sql), puis comparer les résultats aux commentaires du script.
4. Remplacer les états « À vérifier », « À relever » et « À exécuter » du tableau par les résultats constatés et la date de vérification. Ne pas recopier d’identifiant utilisateur, de mot de passe ou de jeton dans le dépôt.
5. Mettre à jour les cases correspondantes du plan local `chris/PLAN_EXECUTION.md` uniquement après vérification.

Le warehouse attendu est `NYC_TAXI_WH`, de taille `XSMALL`, avec suspension automatique après 60 secondes et reprise automatique activée. La base est `NYC_TAXI`, les schémas métier sont `RAW`, `STAGING`, `MARTS`, et le rôle des outils est `TRANSFORMER`.

### Ordre des scripts fournis pour la suite

L’installation est déjà validée. Pour l’étape 3, commencer au point 3 ci-dessous ; les points 1 et 2 servent à rejouer la préparation sur un compte vide.

1. `snowflake/00_installation.sql` — `ACCOUNTADMIN`.
2. `snowflake/01_verification_installation.sql` — vérifications de l’installation.
3. `snowflake/rh/chargement_rh_1_preparer.sql` — `TRANSFORMER`.
4. Dépôt des deux CSV sur le stage depuis Snowsight avec `TRANSFORMER`.
5. `snowflake/rh/chargement_rh_2_copier.sql` — `TRANSFORMER`.
6. `snowflake/rh/00_tables_rh.sql`.
7. `snowflake/rh/staging/stg_rh__drivers.sql`, puis `stg_rh__driver_shifts.sql`.
8. `snowflake/rh/marts/dim_depot.sql`, puis `dim_driver.sql`, puis `mart_driver_monthly.sql`.
9. [snowflake/rh/verification_chargement_rh.sql](snowflake/rh/verification_chargement_rh.sql) — contrôle final avant toute purge.

### Chargement RH — étape 3

**État au 4 novembre 2026 :** étape 3 terminée ; chargement, relance corrigée, construction et contrôle final validés à partir des résultats Snowsight transmis par le titulaire. Les deux CSV sont présents dans `data/`, ignorés et non suivis par Git ; aucun ajout n’apparaît dans l’historique local accessible. Leur lecture locale donne 400 chauffeurs, 25 951 services, 25 933 identifiants de service distincts et 914 groupes mensuels. Ces contrôles locaux ne prouvent pas le chargement dans Snowflake.

Dans Snowsight, commencer par `USE SECONDARY ROLES NONE;`, puis `USE ROLE TRANSFORMER;` et `USE WAREHOUSE NYC_TAXI_WH;`. Exécuter chaque script en entier dans l’ordre ci-dessus et vérifier le résultat avant de passer au suivant.

**Préparation Snowflake confirmée le 4 novembre 2026 :** après une première vérification signalant l’absence ou l’inaccessibilité de `RAW.DRIVERS`, le titulaire a exécuté les instructions de préparation par blocs. Les résultats transmis confirment le format `CSV_RH`, les deux tables RAW à 0 ligne et le stage `RH_STAGE` avec répertoire activé, tous propriétaires `TRANSFORMER`. Le dépôt et le chargement des CSV sont confirmés ci-dessous.

**Dépôt des CSV confirmé le 4 novembre 2026 :** le résultat `LIST` transmis montre `rh_stage/drivers.csv` (43 541 octets) et `rh_stage/driver_shifts.csv` (1 277 306 octets). Les deux fichiers étaient à la racine du stage avant leur copie dans les tables RAW et leur retrait confirmé ci-dessous.

Après `chargement_rh_1_preparer.sql`, vérifier que `RH_STAGE` existe. Dans le menu du profil Snowsight, sélectionner `TRANSFORMER` pour le dépôt via l’interface. Ouvrir **Ingestion → Add Data → Load files into a Stage**, sélectionner `data/drivers.csv` et `data/driver_shifts.csv`, puis la base `NYC_TAXI`, le schéma `RAW` et le stage `RH_STAGE`. Laisser le chemin de destination vide et cliquer sur **Upload**. Vérifier les deux fichiers avec `LIST @NYC_TAXI.RAW.RH_STAGE;`, puis exécuter `chargement_rh_2_copier.sql` : le résultat doit donner 400 chauffeurs et 25 951 services, et le stage doit être vide. Relancer ce second script sans redéposer les fichiers et vérifier que les volumes ne changent pas. Poursuivre ensuite avec les tables, les vues et les trois scripts MARTS, dans l’ordre indiqué.

- Le format `CSV_RH` décrit la lecture des CSV : en-tête ignoré et champs éventuellement entourés de guillemets. RAW conserve les espaces présents dans la source.
- Le stage `RH_STAGE` reçoit temporairement les fichiers avant leur import dans les tables.
- `COPY INTO` copie les colonnes et ajoute les métadonnées du fichier et du chargement. Chaque `PATTERN` sélectionne le nom exact du CSV destiné à sa table. Après purge, un stage vide ne fournit aucun fichier correspondant : la relance doit traiter zéro fichier. L’historique de chargement protège aussi contre le rechargement des mêmes fichiers dans sa fenêtre de suivi ; ne pas utiliser `FORCE = TRUE`.
- `PURGE = TRUE` demande le retrait des fichiers du stage après copie réussie. Le résultat de `LIST` doit confirmer le retrait effectif des deux fichiers.

Le script de vérification affiche uniquement le contexte de session, les volumes et leur statut, puis le contenu du stage. Il doit produire six lignes `OK` et aucun fichier sur le stage :

| Objet | Lignes attendues avant purge | Résultat Snowflake |
|---|---:|---|
| `RAW.DRIVERS` | 400 | 400 — OK, contrôle final du 4 novembre 2026 |
| `RAW.DRIVER_SHIFTS` | 25 951 | 25 951 — OK, contrôle final du 4 novembre 2026 |
| `STAGING.STG_RH__DRIVER_SHIFTS` | 25 933 | 25 933 — OK, contrôle final du 4 novembre 2026 |
| `MARTS.DIM_DEPOT` | 3 | 3 — OK, contrôle final du 4 novembre 2026 |
| `MARTS.DIM_DRIVER` | 400 | 400 — OK, contrôle final du 4 novembre 2026 |
| `MARTS.MART_DRIVER_MONTHLY` | 914 | 914 — OK, contrôle final du 4 novembre 2026 |

**Chargement initial confirmé le 4 novembre 2026 :** résultats transmis par le titulaire : 400 chauffeurs, 25 951 services et `LIST @NYC_TAXI.RAW.RH_STAGE;` sans résultat. Le stage est vide après la copie.

**Relance diagnostiquée le 4 novembre 2026 :** erreur reçue : `Remote file '@rh_stage/drivers.csv' was not found.` Les fichiers avaient été retirés par `PURGE = TRUE`, mais `FILES` exigeait toujours leur présence. Le contrôle séparé confirme des volumes inchangés (400 et 25 951) et un stage vide. Le script remplace désormais `FILES` par un `PATTERN` distinct pour chaque CSV, en conservant la purge et l’arrêt sur erreur de données. Comportement attendu sur stage vide : `Copy executed with 0 files processed.` pour chaque copie. [Référence Snowflake : COPY INTO](https://docs.snowflake.com/en/sql-reference/sql/copy-into-table). La version corrigée a ensuite été exécutée dans Snowsight sans redéposer les fichiers : le titulaire confirme le 4 novembre 2026 que les copies passent, avec 400 chauffeurs, 25 951 services et un stage vide. La relance est validée sur ces résultats.

**Validation complète le 4 novembre 2026 :** contrôle final transmis par le titulaire avec le rôle `TRANSFORMER` et le warehouse `NYC_TAXI_WH` : les six volumes du tableau sont conformes (`OK`) et le `LIST` du stage ne renvoie aucun résultat. Chargement, relance corrigée sans ajout de lignes, vues STAGING et tables MARTS validés ; toutes les cases de l’étape 3 du plan local sont cochées. Aucune purge ni politique de gouvernance n’a été exécutée à cette étape.

Consulter [GUIDE_BRIEF_GOUVERNANCE.md](GUIDE_BRIEF_GOUVERNANCE.md) pour les étapes suivantes et [CONTRAT_GOUVERNANCE.md](CONTRAT_GOUVERNANCE.md) pour les règles imposées.

## Gouvernance

Les politiques d’accès, le catalogue, la conservation, les contrôles de qualité et l’audit restent à implémenter au cours des étapes suivantes. Les scripts du starter-kit ne constituent pas encore une installation protégée pour les métiers.

### Veille et inventaire — 3 novembre 2026

La [note de veille](docs/VEILLE.md) contient les sources officielles, sept fiches et la confrontation des règles du contrat aux textes. La partie 1 du [registre](docs/REGISTRE.md) inventorie les 18 colonnes des CSV, les métadonnées et les copies prévues par les SQL, y compris les données calculées. Le [cahier des accès](docs/ACCES.md) est préparé pour les étapes suivantes ; aucun test d’accès n’est déclaré exécuté.

Selon le contexte du brief, **Hudson Cab Europe est responsable du traitement** et l’**article 3 §1 du RGPD** s’applique par son établissement parisien. Snowflake agit comme sous-traitant pour les opérations sur instruction, sous réserve de vérifier le contrat ; la CNIL est l’autorité de contrôle française. Fondements et hypothèses : [note, section 1](docs/VEILLE.md#1-droit-applicable-et-qualification-des-acteurs).

### Écarts et limites du contrat à signaler

| Point | Constat documentaire | Proposition à faire valider |
|---|---|---|
| Conservation uniforme cinq ans après départ | Le RGPD demande une durée justifiée par finalité. Le registre unique français ne justifie pas automatiquement tous les champs de chauffeurs new-yorkais. Le nouveau référentiel CNIL du 2 avril 2026 précise son périmètre français. Les relevés de paie peuvent relever d’un minimum de six ans à New York (§195(4)) ; comparer les points de départ et dates d’expiration avant de conclure à un conflit avec les cinq ans après départ. | Juriste/DPO : durées par catégorie et obligations locales ; distinguer base active et archivage restreint. Le contrat pédagogique reste inchangé. |
| Accès aux anciens chauffeurs | La matrice ne sépare pas les besoins courants de l’archivage. | Direction et DPO : limiter les accès opérationnels après départ selon les finalités. |
| Effacement et Time Travel | Un jour de Time Travel n’équivaut pas à une disparition physique immédiate ; les tables permanentes ont ensuite sept jours de Fail-safe. | Documenter le cycle nominal de huit jours et ses limites ; vérifier les copies, clones, exports et paramètres effectifs. |
| Périmètre des données personnelles | Les métriques, horaires et dates liés à un chauffeur restent personnels, comme `driver_name` et l’ancienneté. Les six valeurs de tag ne décrivent pas clairement toutes ces catégories. | Référent gouvernance/formateur : clarifier la taxonomie ; éviter d’accorder une visibilité automatique à tout identifiant interne. |
| Masquage et administration | Le maintien de `driver_id` permet des rapprochements ; les données ne sont pas anonymes. Des rôles privilégiés peuvent modifier les protections. | Tester lecture et changements, auditer et appliquer le moindre privilège ; vérifier les protections après reconstruction. |
| Qualité | Les huit contrôles sont utiles mais leurs seuils ne certifient pas l’exactitude. Un simple `@` ne valide pas un e-mail ; jusqu’à 50 services orphelins ne bloquent pas. | Tracer et corriger aussi sous les seuils ; distinguer conformité, qualité métier et déclenchement technique. |
| Retrait du stage et rechargement | Vider le stage ne traite ni les fichiers locaux ni les exports ; un nouveau fichier complet peut réintroduire des chauffeurs purgés. | Définir le cycle de vie des copies et rejouer la purge après les futurs imports avant exposition métier. |
| Sous-traitance et localisation | Paris est confirmé ; cette région seule ne prouve pas l’absence d’accès ou de transfert hors EEE. | DPO/juriste : vérifier clauses art. 28, destinataires, accès distants et garanties de transfert. |

Les références précises, l’examen des huit règles de qualité et les questions à soumettre au juriste/DPO figurent dans la [note de veille, sections 4 et 7](docs/VEILLE.md#4-confrontation-exhaustive-du-contrat-aux-sources). Ces propositions ne sont pas encore des mesures déployées.

### Dispositif de veille et preuve attendue

Outil choisi par le titulaire : **ChatGPT web avec recherche web**, avec revue manuelle hebdomadaire proposée le lundi à 9 h Paris et quotidienne pendant le brief. Les [prompts initial et hebdomadaire](docs/PROMPT_VEILLE.md) précisent les sources officielles, les documents à joindre et les preuves à conserver. Responsable proposé : porteur du travail local, avec relecture du binôme et arbitrage juridique par le DPO/juriste.

**Automatisation mensuelle n8n :** l’[export du workflow](docs/%5BN8N%5D%20Veille%20RGPD.json) est corrigé pour le mois civil précédent, bornes ISO inclus/exclu et fuseau `Europe/Paris`. Planification : le 1er à 07:00 Paris. Les [instructions](docs/N8N_VEILLE.md) précisent la réimportation et les vérifications ; l’export reste désactivé. Le premier e-mail reçu a interprété les dates en février–mars et ne prouve pas la couverture d’octobre. Une nouvelle exécution avec les bornes corrigées est nécessaire.

**Première recherche réalisée :** le titulaire a fourni le [compte rendu ChatGPT](docs/resultat_chatgpt.md) et la note correspondante le 3 novembre 2026.

**À terminer :** capture réelle dans `docs/`, confirmation de la répartition et mécanisme d’alerte. Une revue manuelle n’est pas un abonnement : l’exigence du brief de recevoir les nouveautés reste à satisfaire par un abonnement complémentaire ou une adaptation validée par le formateur. Aucun abonnement, rappel ni capture n’a été créé ici ; la validation complète du jour 1 matin reste ouverte sur ces points.

Aucun commit ni push n’est réalisé pendant ce travail.


### Installation de la gouvernance et catalogue — étape 4

Préparation locale réalisée le 4 novembre 2026 ; exécution Snowflake et capture encore attendues. Aucun masquage ni filtre de lignes créé à cette étape. La carte des propriétaires et privilèges est dans [ACCES.md](docs/ACCES.md).

Dans Snowsight, exécuter chaque fichier en entier et vérifier ses résultats avant le suivant :

1. Étudier et exécuter `exemples/00_bac_a_sable.sql`, puis `exemples/01_role_gouvernance.sql`. Ils utilisent leur base `EXEMPLE_GOUV`, leur warehouse `EXEMPLE_WH` et les rôles `EX_*` ; ne pas substituer les noms du projet. Attendu : six clients puis cinq colonnes taguées, aucun SELECT pour EX_GOUVERNANCE.
2. [01_gouvernance.sql](snowflake/gouvernance/01_gouvernance.sql) : commence avec ACCOUNTADMIN puis passe à GOUVERNANCE. Attendu : trois tags appartenant à GOUVERNANCE et table QUALITE_RESULTATS vide au premier passage. TRANSFORMER reçoit USAGE/CREATE VIEW sur le schéma, APPLY sur chacun des trois tags, INSERT/SELECT sur les résultats. GOUVERNANCE ne reçoit aucun SELECT RH.
3. [Modèle DIM_DEPOT](snowflake/gouvernance/modele_catalogue_dim_depot.sql) : TRANSFORMER documente le référentiel non personnel, sensibilité interne, conservation sans limite du référentiel.
4. [RAW.DRIVERS](snowflake/rh/catalogue/catalogue_raw_drivers.sql), puis [DIM_DRIVER](snowflake/rh/catalogue/catalogue_dim_driver.sql) : fiches complètes, douze colonnes décrites chacune.
5. [RAW.DRIVER_SHIFTS](snowflake/rh/catalogue/catalogue_raw_driver_shifts.sql), puis [MART_DRIVER_MONTHLY](snowflake/rh/catalogue/catalogue_mart_driver_monthly.sql) : fiches courtes ; `driver_name` porte le tag `nom`.
6. [Vérification du catalogue](snowflake/rh/catalogue/verification_catalogue.sql) : cinq tables décrites ; 28 colonnes décrites sur les trois fiches complètes ; aucun manque de description ; 38 affectations personnelles attendues avec statut OK (dont 20 professionnelles ajoutées le 6 novembre 2026) ; sensibilité confidentielle et durée de cinq ans après départ sur les quatre tables RH, interne et durée du référentiel sur DIM_DEPOT. Examiner également les droits avec ACCOUNTADMIN.
7. Rejouer l’installation et les cinq fiches, puis le contrôle : résultats inchangés, aucun objet de données recréé et aucun historique de qualité effacé. Capturer dans Snowsight les tags d’une table (Details), sans lignes de chauffeurs ; enregistrer par exemple `docs/tags_dim_driver.png`. Reporter les résultats réels dans le plan et ACCES.md ; ne cocher l’exécution qu’après confirmation.

Le tag DUREE_CONSERVATION décrit une règle ; il n’applique ni purge ni rétention Time Travel. Ces mécanismes seront installés au jour 3. Les catégories professionnelles absentes de la taxonomie du contrat restent explicitement à clarifier, selon le choix du titulaire : la couverture des tags personnels est partielle, même si les 18 contrôles prévus passent. Voir [REGISTRE.md](docs/REGISTRE.md). `identifiant_interne` n’accordera pas automatiquement de visibilité : l’exception prévue au jour 2 concerne précisément `driver_id`, pas `shift_id`.

Le modèle DIM_DEPOT utilise désormais les colonnes documentées de [TAG_REFERENCES_ALL_COLUMNS](https://docs.snowflake.com/en/sql-reference/functions/tag_references_all_columns) : `column_name`, `tag_name`, `tag_value`. La colonne `level` du kit n’appartient pas à cette sortie. Les tags de table sont hérités par les colonnes ; ce contrôle doit être lancé avec TRANSFORMER, propriétaire des tables.


**Installation confirmée le 4 novembre 2026 — résultats Snowsight transmis par le titulaire :** les trois tags `SENSIBILITE`, `DONNEE_PERSONNELLE` et `DUREE_CONSERVATION` appartiennent à `GOUVERNANCE`, avec les valeurs autorisées du contrat. Le schéma et la table `QUALITE_RESULTATS` appartiennent également à ce rôle. La table contient `REGLE` (VARCHAR), `MESURE_LE` (TIMESTAMP_NTZ), `NB_ANOMALIES` (NUMBER(18,0)), `SEUIL` (NUMBER(18,2)) et `STATUT` (VARCHAR) ; `NB_MESURES = 0`. Les attributions transmises de `GOUVERNANCE` montrent USAGE sur la base, le warehouse, RAW et MARTS, les propriétés attendues et les deux privilèges globaux APPLY MASKING POLICY / APPLY ROW ACCESS POLICY ; aucun SELECT RH ni rôle de lecture hérité n’apparaît dans cette sortie. `TRANSFORMER` dispose de USAGE et CREATE VIEW sur le schéma GOUVERNANCE, APPLY sur chacun des trois tags et INSERT/SELECT sur QUALITE_RESULTATS. Catalogue, rejouabilité et capture restent à vérifier ; aucune politique créée à cette étape.


**Contrôle global du catalogue confirmé le 6 novembre 2026 — résultats Snowsight transmis par le titulaire :** contexte TRANSFORMER / NYC_TAXI_WH ; aucune ligne aux deux contrôles de descriptions manquantes ; 5 tables sur 5 décrites ; 28 colonnes sur 28 décrites pour RAW.DRIVERS, MARTS.DIM_DRIVER et MARTS.DIM_DEPOT ; 18 affectations DONNEE_PERSONNELLE sur 18 avec statut OK, dont le nom calculé DRIVER_NAME. Les quatre tables RH portent SENSIBILITE/confidentiel et la durée documentaire de cinq ans après fin du contrat ; DIM_DEPOT porte SENSIBILITE/interne et sa durée de référentiel. Les trois tags et le schéma de gouvernance appartiennent à GOUVERNANCE ; les cinq tables et les deux vues STAGING appartiennent à TRANSFORMER. Les droits attendus de TRANSFORMER sur les tags, les résultats de qualité et la création de vues sont présents. Aucun SELECT RH ni rôle de lecture hérité dans les attributions fournies de GOUVERNANCE ; son attribution à l’utilisateur testeur est confirmée, sans recopier l’identifiant dans le dépôt.

**Reste à terminer pour l’étape 4 :** rejouer le script d’installation de gouvernance et les cinq fiches, puis le contrôle global, pour confirmer la rejouabilité ; enregistrer une capture réelle des tags d’une table. La couverture des catégories professionnelles reste partielle et à clarifier avec le formateur, conformément au choix du titulaire. Ce contrôle ne valide ni la purge ni les politiques d’accès des jours suivants.


**Preuve des tags examinée le 6 novembre 2026 :** [capture partielle DIM_DRIVER](docs/tags_dim_driver.png), 22 premières lignes lisibles montrant les trois types de tags, et [export complet](docs/tags_dim_driver.csv), 31 références de métadonnées sans valeurs de chauffeurs. Après relance, le titulaire confirme le 6 novembre 2026 : aucune description manquante, 5 tables décrites sur 5, 28 colonnes décrites sur 28 et 18 tags OK sur 18. Rejouabilité validée sur ces résultats. L’écart de taxonomie reste ouvert.


### Extension de la taxonomie — décision du 6 novembre 2026

Le titulaire autorise `donnee_professionnelle` pour les dates professionnelles, dépôts, horaires, métriques, statut et ancienneté liés à un chauffeur. Cette décision remplace le maintien de l’écart de taxonomie évoqué dans les états antérieurs ; le contrat fourni reste inchangé. Les scripts sont adaptés, leur déploiement n’est pas encore confirmé.

Exécuter à nouveau `snowflake/gouvernance/01_gouvernance.sql`, puis les quatre fiches `catalogue_raw_drivers.sql`, `catalogue_dim_driver.sql`, `catalogue_raw_driver_shifts.sql` et `catalogue_mart_driver_monthly.sql`, puis `verification_catalogue.sql`. Attendu : 38 tags personnels OK (10 + 12 + 8 + 8), toujours 5 tables décrites et 28 colonnes décrites. Les 20 nouvelles affectations sont détaillées dans le registre. La capture et le CSV actuels attestent l’état précédent à sept tags personnels sur DIM_DRIVER ; les actualiser après validation (12 tags personnels, soit 36 références au total sur DIM_DRIVER).

L’extension du tag existant utilise [ALTER TAG SET ALLOWED_VALUES](https://docs.snowflake.com/en/sql-reference/sql/alter-tag), ce qui permet de conserver le tag et ses affectations. Au jour 2, tenir compte des types DATE, NUMBER/FLOAT et BOOLEAN et de la colonne depot utilisée par la future politique d’accès par ligne. Les règles de masquage devront suivre les besoins d’accès métier du contrat.


**Extension appliquée le 6 novembre 2026 :** le titulaire confirme la réussite de tous les scripts et les compteurs attendus au contrôle : 5 tables, 28 colonnes et 38 tags personnels. La case de taggage complet est cochée dans le plan. Le fichier PNG et le CSV existants montrent l’état antérieur ; les actualiser pour inclure les données professionnelles (DIM_DRIVER : 12 tags personnels, 36 références au total).


**Preuves renouvelées vérifiées le 6 novembre 2026 :** `docs/tags_dim_driver.csv` contient 36 références : 12 DONNEE_PERSONNELLE, 12 DUREE_CONSERVATION et 12 SENSIBILITE. Les cinq affectations donnee_professionnelle attendues sont présentes sur DEPOT, HIRE_DATE, END_DATE, IS_ACTIVE et TENURE_YEARS. La capture `docs/tags_dim_driver.png` renouvelée est lisible, affiche 36 lignes au total et montre la nouvelle catégorie sur les premières lignes. Elle complète le CSV intégral. Ces preuves remplacent les anciens fichiers à 31 références. Étape 4 terminée avec l’extension de taxonomie autorisée par le titulaire et documentée, sans modification du contrat fourni.


### Accès métier — étape 5, préparation du 6 novembre 2026

**État : scripts et attendus préparés localement ; exécutions Snowsight, tests et capture à confirmer.** Le cahier de tests est écrit avant les politiques dans [ACCES.md](docs/ACCES.md#partie-2--cahier-de-tests--étape-5). Ne pas interpréter les attendus comme des résultats obtenus.

Toutes les colonnes existantes sont conservées : la paie utilise les données complètes et le pipeline doit reconstruire les valeurs réelles. Des masques adaptés au rôle évitent de multiplier les tables. Les données professionnelles restent visibles aux métiers dans leur périmètre, conformément au choix du titulaire.

| Colonnes | Décision et justification |
|---|---|
| `driver_id` dans les deux MARTS | Clair pour les métiers et TRANSFORMER : compter et joindre ; reste un pseudonyme personnel. Masqué dans RAW pour les administrateurs. |
| `first_name`, `last_name`, `driver_name` | Clair paie/responsables/TRANSFORMER ; `*****` analyste. Le nom calculé reçoit aussi une politique. |
| `phone` | Clair paie/responsables/TRANSFORMER pour le contact opérationnel ; `*****` analyste. |
| `email`, `tlc_license_number` | Clair paie/TRANSFORMER ; `*****` responsables et analyste. Le caractère public d’une licence ne justifie pas son exposition ici. |
| `birth_date` | Date complète paie/TRANSFORMER ; NULL responsables ; 1er janvier de l’année source pour ANALYSTE (convention d’année, pas une naissance exacte). |
| `depot` | Clair dans les lignes MARTS autorisées ; paramètre du filtre. Tag personnel conservé, aucun masque sur cette colonne MARTS. |
| `hire_date`, `end_date` | Conservées et visibles dans MARTS : suivi contractuel et futur point de départ de purge. |
| `is_active`, `tenure_years` | Conservés et visibles dans MARTS pour les analyses d’effectifs et d’ancienneté. |
| `activity_month`, `nb_shifts`, `hours_worked`, `trips_count`, `revenue_usd` | Visibles dans les lignes mensuelles autorisées pour l’activité ; restent personnels car rattachés à un chauffeur. |
| Les 18 colonnes personnelles RAW, dont `shift_id` | Valeurs réelles pour TRANSFORMER seul ; texte `*****`, DATE/NUMBER/FLOAT NULL pour les autres lecteurs. Aucun rôle métier ne reçoit SELECT RAW/STAGING. |
| `_source_file`, `_loaded_at` | Métadonnées techniques conservées ; aucun droit métier RAW/STAGING. |
| Les quatre colonnes DIM_DEPOT | Référentiel non personnel, sans filtre ni masque ; trois dépôts lisibles par chaque métier. |

Un NULL source reste NULL. Aucune suppression de colonne, modification de schéma ou transformation métier n’est nécessaire. Les BOOLEAN professionnels de MARTS restent visibles ; aucune politique BOOLEAN n’est donc nécessaire à cette étape.

Le masquage est attaché **directement aux colonnes**. Les trois tags et leurs 38 affectations restent documentaires pour cette implémentation : le tag DONNEE_PERSONNELLE ne déclenche pas automatiquement de politique. Cette décision évite de masquer `depot`, utilisé par le filtre, car [Snowflake interdit de placer la même colonne dans les signatures d’un masque et d’une politique de lignes](https://docs.snowflake.com/en/user-guide/security-row-intro#masking-policies). Une nouvelle colonne nécessite donc une décision d’accès et un attachement explicite. Le contrôle des attachements doit être étendu avec elle.

Les règles consultent le rôle principal (`CURRENT_ROLE()`), jamais la puissance administrative ni les rôles hérités. ACCOUNTADMIN et SYSADMIN ne voient aucune ligne des deux MARTS RH ; ils héritent de la lecture RAW/STAGING, où les valeurs personnelles sont masquées. GOUVERNANCE peut écrire les politiques et lire ses correspondances, sans SELECT RH. Ce contrôle protège la lecture courante : les administrateurs et le propriétaire des objets peuvent modifier les protections ; l’audit de ces pouvoirs reste à mettre en place au jour 3. Retirer un tag n’enlève pas les masques directs.

#### Ordre d’exécution de l’étape 5

1. Lire les attendus et exécuter les exemples 00/01 si nécessaire, puis 02/03 par blocs ; retirer ensuite l’accès temporaire Sud.
2. Exécuter [02_roles_metier.sql](snowflake/gouvernance/02_roles_metier.sql) : créer les rôles et préparer leurs droits, sans nouvelle attribution au testeur.
3. Exécuter [03_masquage.sql](snowflake/gouvernance/03_masquage.sql), puis [04_acces_depot.sql](snowflake/gouvernance/04_acces_depot.sql), avec GOUVERNANCE. Aucun métier nouvellement créé ne doit être attribué avant cette protection.
4. Exécuter [verification_politiques.sql](snowflake/gouvernance/verification_politiques.sql) avec ACCOUNTADMIN : 27 masques et 2 filtres conformes. Seulement après ces résultats, lancer [activation_roles_metier.sql](snowflake/gouvernance/activation_roles_metier.sql) pour attribuer les quatre rôles à l’utilisateur courant.
5. Dans une même session Snowsight, lancer [05_tests_acces.sql](snowflake/gouvernance/05_tests_acces.sql) **bloc par bloc**, de haut en bas. Le premier bloc calcule des références temporaires sans créer de table de données. Garder la session ; ne jamais exporter les variables d’empreinte.
6. Exécuter [test_extension_depot.sql](snowflake/gouvernance/test_extension_depot.sql) : ajout temporaire de Brooklyn au responsable Queens, puis restauration automatique de la correspondance initiale.
7. Exécuter [verification_pipeline_acces.sql](snowflake/gouvernance/verification_pipeline_acces.sql) pour les références avant/après, la reconstruction et la comparaison aux sources ; puis [verification_catalogue.sql](snowflake/rh/catalogue/verification_catalogue.sql) et le contrôle des politiques.
8. Rejouer 01, 02, 03, 04, les cinq fiches catalogue et les contrôles ; vérifier la carte des droits (`SHOW GRANTS`, y compris futurs et héritages), puis refaire les tests. Le 04 remet volontairement les cinq correspondances initiales ; il ne sert pas à conserver des extensions métier permanentes.
9. Exécuter [capture_acces.sql](snowflake/gouvernance/capture_acces.sql) par rôle et enregistrer une capture des deux résultats agrégés. Renseigner seulement alors les résultats observés dans ACCES.md et le plan local.

En cas d’erreur, arrêter au bloc concerné et transmettre le message avant de poursuivre. Les scripts ne remplacent ni ne détachent silencieusement une politique inattendue. Les scripts 03/04 mettent les corps à jour sans recréer les politiques ; les réexécutions n’effacent ni données RH ni historique de qualité. Une attribution ou un droit préexistant inattendu doit être signalé et examiné : créer un rôle avec IF NOT EXISTS ne retire pas ses anciens droits.
