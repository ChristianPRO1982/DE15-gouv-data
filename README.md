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

**État au 6 novembre 2026 : bac à sable terminé et droits du script 02 confirmés ; huit masques et RAP_DEPOT créés, cinq correspondances conformes ; 29 attachements confirmés OK ; attribution des quatre rôles au testeur confirmée ; 31 groupes fonctionnels initiaux sur 31 confirmés OK ; extension/restauration de dépôt confirmée ; seconde reconstruction stable et conforme à RAW (4 contrôles OK) ; métadonnées préservées (5 contrôles OK) ; relance des scripts et catalogue conforme (5 contrôles OK) ; relecture après relance conforme (31/31) ; capture comparative reçue et tableau conforme ; recadrage sur le résultat requis pour le dépôt public avant clôture.** Le cahier de tests est écrit avant les politiques dans [ACCES.md](docs/ACCES.md#partie-2--cahier-de-tests--étape-5). Ne pas interpréter les attendus comme des résultats obtenus.

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
5. Exécuter **en entier** [05_tests_acces_synthese.sql](snowflake/gouvernance/05_tests_acces_synthese.sql). Il prépare les références, enchaîne les huit rôles et renvoie **un seul tableau final de huit lignes** : volumes, nombre de groupes de tests, groupes OK, statut et détails des écarts. Attendu : huit statuts OK, avec GROUPES_OK = GROUPES_DE_TESTS sur chaque ligne (31 groupes au total). Aucun B0 préalable nécessaire. Le fichier détaillé [05_tests_acces.sql](snowflake/gouvernance/05_tests_acces.sql) permet d’isoler un contrôle si le tableau indique un écart. Les références et empreintes restent dans la session et ne sont pas affichées.
6. Exécuter [test_extension_depot.sql](snowflake/gouvernance/test_extension_depot.sql) : ajout temporaire de Brooklyn au responsable Queens, puis restauration automatique de la correspondance initiale.
7. Exécuter [verification_pipeline_acces.sql](snowflake/gouvernance/verification_pipeline_acces.sql) en entier : un seul tableau de quatre contrôles pour les références avant/après, la reconstruction et la comparaison aux sources ; puis [verification_post_pipeline.sql](snowflake/gouvernance/verification_post_pipeline.sql), qui regroupe les contrôles de descriptions, tags et politiques dans cinq lignes (5, 28, 5, 38 et 29 attendus). Refaire ensuite la synthèse des accès.
8. Exécuter [rejouabilite_gouvernance.sql](snowflake/gouvernance/rejouabilite_gouvernance.sql) **en entier** : il reprend 01 à 04 et les cinq fiches catalogue, puis renvoie le tableau final des cinq contrôles de métadonnées. Arrêter à la première erreur. Refaire ensuite [la synthèse des accès](snowflake/gouvernance/05_tests_acces_synthese.sql) ; les droits actuels/futurs et héritages ont déjà été contrôlés, les sorties SHOW détaillées restent disponibles dans 02 et verification_politiques.sql si un écart apparaît. Le 04 remet volontairement les cinq correspondances initiales ; il ne sert pas à conserver des extensions métier permanentes.
9. Exécuter [capture_acces.sql](snowflake/gouvernance/capture_acces.sql) **en entier** : la requête identique est lue sous RH_PAIE et ANALYSTE et produit un seul tableau de six lignes. Capturer ce tableau dans `docs/acces_comparaison_roles.png`. Renseigner seulement alors les résultats observés dans ACCES.md et le plan local.

En cas d’erreur, arrêter au bloc concerné et transmettre le message avant de poursuivre. Les scripts ne remplacent ni ne détachent silencieusement une politique inattendue. Les scripts 03/04 mettent les corps à jour sans recréer les politiques ; les réexécutions n’effacent ni données RH ni historique de qualité. Une attribution ou un droit préexistant inattendu doit être signalé et examiné : créer un rôle avec IF NOT EXISTS ne retire pas ses anciens droits.

**Bac à sable — résultats partiels transmis le 6 novembre 2026 :** exemple 02, R1 conforme (cinq associations au tag PII : quatre MASK_TEXTE, une MASK_NOMBRE sur SCORE) ; R2 conforme sur C1 avec EX_PIPELINE (valeurs réelles) ; R3 conforme sur C1 avec EX_VENDEUR (nom et téléphone réels, e-mail partiellement masqué avec domaine conservé, score affiché vide pour NULL attendu). Aucun nom ni coordonnée du témoin recopié dans cette synthèse. Le volume total n’est pas établi par ces requêtes filtrées sur C1. R4 ensuite reçu et conforme avec EX_ANALYSTE : identifiant et région conservés, identité masquée, e-mail partiellement masqué et score 700. Prédicat sur e-mail ensuite confirmé sous EX_ANALYSTE : COUNT(*) = 0, conforme. Exemple 03 ensuite reçu : test 1 en écart (Nord 2 et Sud 2 au lieu de Nord seul) ; test 2 conforme (trois régions, deux lignes chacune) ; résultat du test 3 conforme (Nord 2, Sud 2), mais l’élargissement n’est pas prouvé puisque Sud était déjà visible au test 1 ; test 4 conforme pour les masques analyste de C1. Une relance du test 1 après l’ajout de Sud pourrait expliquer l’écart, sans confirmation de l’ordre réel. Rétablissement ciblé ensuite confirmé le 6 novembre 2026 : EX_VENDEUR voit Nord seul, deux lignes, après retrait de Sud. Contrôle EX_PIPELINE ensuite reçu le 6 novembre 2026 : NB_CLIENTS = 6 et CONTROLE_PIPELINE = OK, confirmant six clients et le témoin en clair avec score 720 après reconstruction. Vérifications du bac à sable terminées sur ces résultats ; écart initial conservé dans le suivi, avec retour confirmé à Nord seul après retrait de Sud. Aucune politique modifiée pour corriger cet écart. La case d’exécution des exemples est cochée ; les validations NYC_TAXI restent ouvertes.

**Rôles métier — script 02 confirmé le 6 novembre 2026 :** résultats des douze SHOW transmis et conformes. Chaque rôle RH_PAIE, RESP_DEPOT_QUEENS, RESP_DEPOT_BRONX et ANALYSTE possède sept droits actuels : USAGE sur NYC_TAXI, NYC_TAXI_WH, MARTS et GOUVERNANCE, puis SELECT sur DIM_DEPOT, DIM_DRIVER et MART_DRIVER_MONTHLY. Chaque rôle possède SELECT sur les vues futures de GOUVERNANCE ; ANALYSTE possède aussi SELECT sur les tables et vues futures de MARTS. Aucun SELECT RAW/STAGING ni rôle hérité n’apparaît dans les attributions fournies ; aucun GRANT OPTION vrai. Les quatre SHOW GRANTS OF ROLE ne renvoient aucune ligne : aucun de ces rôles n’est encore attribué à un utilisateur ou à un autre rôle dans ces sorties. Aucun droit actuel sur une vue n’est affiché, ce qui est compatible avec l’absence de vue à ce stade. Les rôles sont préparés mais non activés ; politiques 03/04, contrôle des associations et tests fonctionnels restent à exécuter.

**Masquage — création des politiques confirmée le 6 novembre 2026 :** SHOW MASKING POLICIES transmis contient exactement les huit politiques attendues dans NYC_TAXI.GOUVERNANCE, toutes propriétaires GOUVERNANCE : MASK_CONTACT, MASK_DRIVER_ID, MASK_NAISSANCE, MASK_PAIE, MASK_RAW_DATE, MASK_RAW_FLOAT, MASK_RAW_NUMBER et MASK_RAW_VARCHAR. Cette sortie confirme leur existence et leur propriétaire ; elle ne montre ni leurs corps ni leurs associations aux colonnes. Le résultat du bloc d’attachement n’a pas été transmis : les 27 attachements restent à confirmer avec verification_politiques.sql après le script 04. Aucun test fonctionnel NYC_TAXI ni activation métier n’est validé à ce stade.

**Accès par dépôt — résultats du script 04 reçus le 6 novembre 2026 :** contenu ACCES_DEPOT conforme aux cinq correspondances attendues : ANALYSTE, RH_PAIE et TRANSFORMER sur *, RESP_DEPOT_QUEENS sur Queens et RESP_DEPOT_BRONX sur Bronx. SHOW ROW ACCESS POLICIES confirme RAP_DEPOT dans NYC_TAXI.GOUVERNANCE, propriétaire GOUVERNANCE. La lecture du contenu ne prouve pas la propriété d’ACCES_DEPOT, attendue GOUVERNANCE selon le script. Le résultat du bloc d’attachement n’a pas été transmis ; les deux associations RAP_DEPOT et les 27 masquages restent à vérifier dans verification_politiques.sql avant activation des rôles métier. Aucun test fonctionnel NYC_TAXI n’est encore confirmé.

**Contrôle des protections confirmé le 6 novembre 2026 :** verification_politiques.sql retourne exactement 29 lignes OK : dix masques sur RAW.DRIVERS, huit sur RAW.DRIVER_SHIFTS, sept sur MARTS.DIM_DRIVER, deux sur MARTS.MART_DRIVER_MONTHLY et un filtre RAP_DEPOT sur chacune des deux tables MARTS RH. Aucune association manquante, différente ou supplémentaire dans ce contrôle, notamment sur DIM_DEPOT. SHOW GRANTS TO ROLE GOUVERNANCE confirme les propriétés des huit masques, de RAP_DEPOT, d’ACCES_DEPOT, de QUALITE_RESULTATS, des trois tags et du schéma, avec les privilèges APPLY globaux attendus ; aucun SELECT RH ni rôle de lecture hérité n’apparaît. Les droits de TRANSFORMER restent conformes : propriété des cinq tables et deux vues STAGING, accès aux sources et warehouse, création de vues/tâches, EXECUTE TASK, APPLY sur les trois tags et INSERT/SELECT sur QUALITE_RESULTATS ; aucun SELECT ACCES_DEPOT transmis. Identifiant de compte non recopié. Précondition d’activation validée ; attribution des quatre rôles métier, tests fonctionnels, relance du pipeline et rejouabilité encore à confirmer.

**Attribution des rôles métier confirmée le 6 novembre 2026 :** résultat transmis du bloc activation_roles_metier.sql : « Quatre rôles attribués à l’utilisateur courant ; tester un rôle principal à la fois. » Le bloc a donc franchi son contrôle des 29 associations et exécuté les quatre attributions prévues. Aucun identifiant utilisateur recopié. Les rôles RH_PAIE, RESP_DEPOT_QUEENS, RESP_DEPOT_BRONX et ANALYSTE sont désormais attribués au testeur ; leur activation par USE ROLE et leurs lectures effectives restent à vérifier dans les blocs B0 à B8 de 05_tests_acces.sql, dans une même session Snowsight. Aucune ligne de résultats fonctionnels n’est validée sur ce seul message.

**Correction du test de refus RH_PAIE — 6 novembre 2026 :** le titulaire transmet une erreur du bloc de restrictions de B1 indiquant que RAW est inaccessible à RH_PAIE faute de privilège sur le schéma. Ce refus est attendu ; aucun droit supplémentaire n’est accordé. Le gestionnaire initial ne reconnaissait que SQLSTATE 42501 et 42S02 ; les six blocs de refus de 05_tests_acces.sql acceptent désormais aussi 02000 uniquement si le message contient « does not exist or not authorized », cas documenté par Snowflake. Les autres erreurs continuent à être relancées ; les refus reconnus affichent désormais SQLSTATE et SQLCODE pour diagnostic, sans copier le message ni une identité utilisateur. Le SQLSTATE exact de l’erreur reçue n’a pas été communiqué. Premier refus RAW observé, mais bloc B1 complet et cinq résultats attendus encore à confirmer après correction ; B0 et autres tests non validés sans résultats transmis. Référence : [exemple officiel Snowflake d’objet inaccessible avec 002003 (02000)](https://docs.snowflake.com/en/user-guide/budgets/troubleshoot).

**Synthèse fonctionnelle reçue le 6 novembre 2026 :** huit rôles, 31 groupes sur 31 OK, aucun détail d’écart. TRANSFORMER : 400 chauffeurs et 914 lignes mensuelles, 6/6 ; RH_PAIE : 400/914, 3/3 ; responsable Queens : 161/365, 4/4 ; responsable Bronx : 122/290, 4/4 ; ANALYSTE : 400/914, 3/3 ; GOUVERNANCE : lectures RH refusées, 1/1 ; ACCOUNTADMIN et SYSADMIN : 0/0, 5/5 chacun. Les groupes valident les masques et périmètres par comparaison aux références TRANSFORMER, le témoin, les refus RAW/STAGING et ACCES_DEPOT et les protections des sources pour les administrateurs. Le groupe GOUVERNANCE rassemble sept refus ; les cellules de volume vides ne sont pas des comptes à zéro. Les valeurs complètes de référence sont celles des MARTS actuels : leur comparaison indépendante à RAW sera validée avec P3, pas déduite de cette seule synthèse. Contrôles initiaux par rôle et restrictions validés ; extension temporaire, reconstruction et métadonnées après reconstruction, rejouabilité et capture restent ouverts.

**Extension de dépôt validée le 6 novembre 2026 :** le résultat du bloc test_extension_depot.sql confirme l’extension Queens + Brooklyn à 278 chauffeurs et 624 lignes mensuelles, le retour à Queens seul à 161/365 et cinq correspondances après retrait de l’accès temporaire. Aucune politique modifiée. P1/P2 sont validés ; la reconstruction est la prochaine vérification. verification_pipeline_acces.sql a été regroupé pour une exécution en entier avec un seul tableau de quatre contrôles, sans modifier les transformations métier. Cette adaptation n’est pas une preuve de reconstruction : P3 reste ouvert jusqu’au résultat transmis, et P4/P5/P7 restent à confirmer.

**Correction du contrôle pipeline — 6 novembre 2026 :** le titulaire transmet « INTO clause is not allowed in this context » sur la version regroupée. Deux SELECT…INTO sans FROM avaient été introduits : capture initiale des empreintes et contrôle du contenu conservé. La capture utilise désormais trois agrégats SELECT HASH_AGG(*) INTO … FROM table ; le contrôle avant/après lit trois sous-requêtes agrégées avec FROM/CROSS JOIN. Les comparaisons indépendantes à RAW, les transformations et le tableau final de quatre contrôles sont conservés. Vérification locale : chaque affectation SELECT…INTO possède une clause FROM au niveau principal, et les transformations restent identiques aux fichiers métier. P3 demeure non validé jusqu’à réception du résultat corrigé. Référence : [syntaxe INTO de Snowflake](https://docs.snowflake.com/en/sql-reference/constructs/into).

**Premier résultat pipeline reçu le 6 novembre 2026 :** CONTENU_CONSERVE = ECART ; DIMENSION_CONFORME_A_RAW = OK avec 0 différence ; MENSUEL_CONFORME_A_RAW = OK avec 0 différence ; CONTACT_TEMOIN_RESTE_REEL = OK. Les tables reconstruites correspondent au recalcul indépendant depuis RAW, mais au moins une empreinte diffère de l’état précédent. P3 reste partiel : l’écart avant/après n’est pas effacé. Hypothèse documentée : TENURE_YEARS utilise CURRENT_DATE pour les chauffeurs actifs ; la construction initiale est datée du 4 novembre et la reconstruction du 6 novembre. Un calcul local décimal sur les CSV montre 23 anciennetés arrondies différentes entre ces deux dates ; cela ne prouve pas que l’état Snowflake précédent était exactement celui du 4 novembre ni que cette colonne explique tout l’écart. Prochaine vérification : relancer le même fichier sans modification des données pour tester la stabilité de la reconstruction désormais à jour. Si l’écart persiste, examiner les tables/colonnes concernées ; aucune règle de contrôle n’est assouplie. Métadonnées, relance des accès, rejouabilité de gouvernance et capture restent à confirmer.

**Reconstruction stable confirmée le 6 novembre 2026 :** seconde exécution de verification_pipeline_acces.sql : CONTENU_CONSERVE = OK, DIMENSION_CONFORME_A_RAW = OK / 0 différence, MENSUEL_CONFORME_A_RAW = OK / 0 différence et CONTACT_TEMOIN_RESTE_REEL = OK. P3 est validé pour cette seconde exécution : contenu stable et conforme aux sources, coordonnées de paie réelles. Le premier ECART reste consigné ; l’hypothèse des anciennetés recalculées selon CURRENT_DATE n’est pas une identification certaine de sa cause. Les comparaisons indépendantes à RAW prévues pour D1/D5 sont désormais acquises ; les accès devront encore être rejoués après reconstruction. verification_post_pipeline.sql regroupe en un tableau les cinq contrôles de descriptions, tags de table, tags personnels et politiques ; P4 reste ouvert jusqu’à réception de ce tableau. Rejouabilité de gouvernance et capture restent à confirmer.

**Métadonnées après reconstruction validées le 6 novembre 2026 :** tableau verification_post_pipeline.sql reçu avec cinq statuts OK et aucun écart : 5 tables décrites, 28 colonnes décrites, 5 tables portant les tags de table attendus, 38 affectations personnelles conformes et 29 associations de politiques conformes. P4 et la case de reconstruction avec conservation des métadonnées sont validés. Les tests initiaux des accès sont déjà conformes ; la synthèse devra encore être relancée après la rejouabilité pour confirmer l’ensemble des lectures après ces opérations. Pour réduire les manipulations, rejouabilite_gouvernance.sql reprend en un fichier les opérations des scripts 01 à 04 et des cinq fiches catalogue, puis affiche le même tableau final de cinq contrôles. Aucun résultat de cette relance n’est encore reçu : P5 reste ouvert, ainsi que P7 pour la capture.

**Relance gouvernance et catalogue reçue le 6 novembre 2026 :** après exécution de rejouabilite_gouvernance.sql, le titulaire transmet le tableau final : 5 tables décrites, 28 colonnes décrites, 5 tables taguées, 38 affectations personnelles et 29 politiques, tous conformes, zéro écart. La relance des opérations 01 à 04 et des cinq fiches atteint donc son contrôle final sans échec signalé, avec métadonnées et associations préservées. Pour clore P5, la synthèse fonctionnelle des huit rôles doit encore être rejouée sur cet état ; aucune réussite de cette relecture n’est déduite du seul tableau des métadonnées. La capture comparative P7 reste également à fournir.

**Relecture finale des accès validée le 6 novembre 2026 :** après reconstruction, contrôle des métadonnées et relance des scripts de gouvernance/catalogue, le titulaire transmet à nouveau les huit rôles avec 31 groupes sur 31 OK, aucun détail d’écart et les mêmes volumes attendus (400/914 pour TRANSFORMER, paie et analyste ; 161/365 Queens ; 122/290 Bronx ; refus GOUVERNANCE ; 0/0 administrateurs). P5 et la case de rejouabilité sont validés. Tous les contrôles fonctionnels de l’étape 5 sont acquis ; seule la preuve de capture P7 reste ouverte. capture_acces.sql est désormais exécutable en entier : la même requête agrégée passe sous RH_PAIE et ANALYSTE, puis affiche un tableau unique de six lignes, sans valeur personnelle. Capture attendue dans docs/acces_comparaison_roles.png ; aucun fichier image n’est présumé créé.

**Capture examinée le 6 novembre 2026 :** docs/acces_comparaison_roles.png existe et a été ouverte pour inspection. Le tableau montre les six lignes attendues : RH_PAIE et ANALYSTE voient chacun Bronx 122, Brooklyn 117 et Queens 161. Les compteurs de masquage paie sont nuls ; pour ANALYSTE, noms/prénoms/e-mails masqués sur tous les effectifs, téléphones masqués 117/115/156 (NULL préservés), naissances réduites au 1er janvier 122/117/161. Deux naissances paie du Bronx tombent déjà un 1er janvier, ce qui est compatible avec les données réelles et ne remplace pas les tests exhaustifs déjà validés. Le contenu du résultat est conforme. En revanche, l’image montre tout le bureau, des onglets personnels et un identifiant de compte dans l’URL : cadrage à corriger avant inclusion dans le dépôt public, conformément au brief. Aucune de ces identités n’est recopiée ici. Remplacer le même PNG par une capture limitée au tableau de résultats ; aucun recadrage ni remplacement de l’original effectué par l’assistant. P7 reste partiel et la dernière case de l’étape 5 reste ouverte jusqu’à vérification du cadrage corrigé.
