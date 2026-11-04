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

**État au 4 novembre 2026 :** préparation locale terminée ; exécution Snowflake à confirmer par les résultats Snowsight. Les deux CSV sont présents dans `data/`, ignorés et non suivis par Git ; aucun ajout n’apparaît dans l’historique local accessible. Leur lecture locale donne 400 chauffeurs, 25 951 services, 25 933 identifiants de service distincts et 914 groupes mensuels. Ces contrôles locaux ne prouvent pas le chargement dans Snowflake.

Dans Snowsight, commencer par `USE SECONDARY ROLES NONE;`, puis `USE ROLE TRANSFORMER;` et `USE WAREHOUSE NYC_TAXI_WH;`. Exécuter chaque script en entier dans l’ordre ci-dessus et vérifier le résultat avant de passer au suivant.

Après `chargement_rh_1_preparer.sql`, vérifier que `RH_STAGE` existe. Avec `TRANSFORMER`, ouvrir le stage `NYC_TAXI.RAW.RH_STAGE` dans l’explorateur de bases de Snowsight et y déposer `data/drivers.csv` et `data/driver_shifts.csv`. Vérifier les deux fichiers avec `LIST @NYC_TAXI.RAW.RH_STAGE;`, puis exécuter `chargement_rh_2_copier.sql` : le résultat doit donner 400 chauffeurs et 25 951 services, et le stage doit être vide. Relancer ce second script sans redéposer les fichiers et vérifier que les volumes ne changent pas. Poursuivre ensuite avec les tables, les vues et les trois scripts MARTS, dans l’ordre indiqué.

- Le format `CSV_RH` décrit la lecture des CSV : en-tête ignoré et champs éventuellement entourés de guillemets. RAW conserve les espaces présents dans la source.
- Le stage `RH_STAGE` reçoit temporairement les fichiers avant leur import dans les tables.
- `COPY INTO` copie les colonnes et ajoute les métadonnées du fichier et du chargement. Son historique évite de recharger les mêmes fichiers lors de la relance prévue ici ; ne pas utiliser `FORCE = TRUE`.
- `PURGE = TRUE` demande le retrait des fichiers du stage après copie réussie. Le résultat de `LIST` doit confirmer le retrait effectif des deux fichiers.

Le script de vérification affiche uniquement le contexte de session, les volumes et leur statut, puis le contenu du stage. Il doit produire six lignes `OK` et aucun fichier sur le stage :

| Objet | Lignes attendues avant purge | Résultat Snowflake |
|---|---:|---|
| `RAW.DRIVERS` | 400 | À confirmer |
| `RAW.DRIVER_SHIFTS` | 25 951 | À confirmer |
| `STAGING.STG_RH__DRIVER_SHIFTS` | 25 933 | À confirmer |
| `MARTS.DIM_DEPOT` | 3 | À confirmer |
| `MARTS.DIM_DRIVER` | 400 | À confirmer |
| `MARTS.MART_DRIVER_MONTHLY` | 914 | À confirmer |

**Validation en attente :** transmettre les résultats agrégés du chargement initial et de sa relance, les six lignes du contrôle final et la confirmation du stage vide. Reporter ensuite la date et les résultats constatés ici et cocher les cases correspondantes du plan local. En cas d’erreur, de statut `ECART` ou de fichier restant sur le stage, résoudre le problème avant de poursuivre. Aucune purge ni politique de gouvernance n’est exécutée à cette étape.

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
