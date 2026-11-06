# Plan d’exécution — Gouvernance de l’entrepôt NYC Taxi

Objectif : répondre à la question **« Qui peut voir quelle donnée, pendant combien de temps, et peut-on s’y fier ? »**.

Organisation : 3 jours en binôme, précédés de la préparation de l’environnement. Cocher une étape lorsqu’elle est réalisée et vérifiée.

## Références et règles de travail

- [Brief et critères d’évaluation](../brief/Snowflake+Gouvernance/BRIEF.md)
- [Contrat de gouvernance](../brief/Snowflake+Gouvernance/starter-kit/CONTRAT_GOUVERNANCE.md) : référence des règles et des noms imposés ; ne pas le modifier.
- [Guide étape par étape](../brief/Snowflake+Gouvernance/starter-kit/GUIDE_BRIEF_GOUVERNANCE.md)
- [Ressources](../brief/Snowflake+Gouvernance/RESSOURCES.md)

Les chemins de livrables ci-dessous sont relatifs à la racine de ce dépôt, où le starter-kit est installé. `chris/` et `brief/` restent des dossiers de travail locaux exclus du rendu par Git.

- Écrire les résultats attendus des tests avant les politiques.
- Utiliser `TRANSFORMER` pour le chargement, les transformations et les tâches.
- Utiliser `GOUVERNANCE` pour écrire les règles sans lire les données RH.
- Avant chaque test de rôle : `USE SECONDARY ROLES NONE;`, puis `USE ROLE …;` et `USE WAREHOUSE NYC_TAXI_WH;`.
- Produire des scripts SQL versionnés et rejouables ; le dépôt des CSV sur le stage est la seule manipulation manuelle de données prévue.
- Conserver les descriptions, tags et politiques lors des reconstructions des tables.
- Ne publier aucun CSV RH, secret ou résultat contenant des données personnelles dans le dépôt public ; vérifier également les captures.
- En binôme : l’un écrit le test, l’autre la politique, puis échanger les rôles.

## 1. Préparer l’environnement — avant le jour 1

- [x] Préparer le dépôt cible et y installer le starter-kit selon l’étape 0 du guide.
- [x] Vérifier le `.gitignore` avant tout commit : exclure les deux CSV RH et les secrets.
- [x] Disposer d’un compte Snowflake : compte d’essai personnel existant, confirmé par son titulaire.
- [x] Vérifier que le compte existant est en édition Enterprise et noter sa région dans le README : Enterprise, AWS — EU (Paris), `AWS_EU_WEST_3`, confirmés par le titulaire le 3 novembre 2026.
- [x] Avec `ACCOUNTADMIN`, exécuter `snowflake/00_installation.sql` : résultat final transmis par le titulaire le 3 novembre 2026, avec RAW, STAGING et MARTS présents dans NYC_TAXI.
- [x] Vérifier le warehouse `NYC_TAXI_WH`, la base `NYC_TAXI`, les schémas `RAW`, `STAGING`, `MARTS` et le rôle `TRANSFORMER` : résultats Snowsight et droits attendus confirmés le 3 novembre 2026.

**État au 3 novembre 2026 :** préparation locale terminée à la racine, sans commit ni push. Les CSV restent locaux et ignorés par Git. Le titulaire a confirmé l’édition Enterprise et la région AWS — EU (Paris), `AWS_EU_WEST_3`, puis transmis les résultats de l’installation et des vérifications : base et trois schémas présents, warehouse X-Small avec suspension à 60 secondes et reprise automatique, droits attendus de TRANSFORMER et contexte de session conformes. Le rôle est accordé à SYSADMIN et activable dans la session testée ; aucune attribution directe à un utilisateur n’apparaît dans les résultats reçus. Les preuves synthétiques sont consignées dans le README. Aucune exécution Snowflake n’a été effectuée directement depuis cette session.

**Validation :** première partie terminée ; l’environnement local et Snowflake est prêt pour la suite. Aucun fichier RH ni secret n’a été publié au cours de cette préparation.

## 2. Faire la veille et l’inventaire — jour 1, matin

- [x] Lire intégralement le contrat et examiner les colonnes des deux CSV.
- [x] Lire `exemples/FICHE_JURIDIQUE.md`.
- [x] Copier les modèles pour préparer `docs/VEILLE.md`, `docs/REGISTRE.md` et `docs/ACCES.md`.
- [x] Dans la partie 1 du registre, inventorier les données personnelles des deux fichiers, leurs usages et leurs copies dans l’entrepôt ; compléter le lignage au fil du travail.
- [x] Rechercher le champ territorial du RGPD et citer l’article précis applicable au contexte.
- [x] Identifier le responsable du traitement, le sous-traitant et l’autorité de contrôle compétente à partir des sources.
- [x] Mettre en place une veille réelle : sources officielles configurées, workflow n8n actif (`active: true`), déclenchement mensuel à 7 h et envoi Outlook testé ; responsable : Christian, porteur du travail `chris/`. Période : 31 jours précédents ; fuseau hérité de l’instance n8n.
- [x] Enregistrer une capture du dispositif de veille dans `docs/` : `docs/Veille RGPD.png`, examinée le 4 novembre 2026, montre l’e-mail reçu à 10:07, la période ISO et les sources. Pour la solution n8n retenue, cette preuve de réception complète l’export actif du workflow ; elle ne représente pas un abonnement RSS.
- [x] Rédiger au moins quatre fiches : source, date, synthèse, conséquence pour l’entrepôt et action.
- [x] Confronter les règles du contrat aux textes : accès, conservation et qualité.
- [x] Reporter les écarts dans la section « Gouvernance » du README et consigner les questions à soumettre au juriste ou au DPO.

**État au 4 novembre 2026 :** note de veille avec sept fiches sourcées, inventaire initial, lignage prévisionnel et écarts documentés. Première recherche ChatGPT conservée dans `docs/resultat_chatgpt.md`. La veille récurrente utilise désormais n8n : l’export `docs/[N8N] Veille RGPD.json` confirme `active: true`, les sources officielles et une fréquence mensuelle ; `docs/Veille RGPD.msg` atteste un envoi sur la période ISO du 2026-10-04 inclus au 2026-11-04 exclu. Aucune exécution Snowflake dans cette étape.

**Validation :** étape 2 réalisée et onze cases cochées. Note de veille et inventaire initial disponibles ; dispositif n8n actif et envoi testé ; preuves conservées dans `docs/[N8N] Veille RGPD.json`, `docs/Veille RGPD.msg` et `docs/Veille RGPD.png`. La capture atteste la réception de la veille automatisée, avec dates et sources visibles ; l’export atteste la configuration active et mensuelle. Cette solution constitue l’adaptation n8n de la preuve d’abonnement prévue par le brief. Le fuseau reste hérité de l’instance ; le lignage sera complété lors du déploiement Snowflake.

## 3. Charger les données et construire les tables — jour 1, après-midi

- [x] Vérifier que les deux CSV RH sont exclus du suivi Git avant toute publication : contrôle local du 4 novembre 2026, fichiers ignorés et non suivis, aucun ajout dans l’historique local accessible.
- [x] Avec `TRANSFORMER`, exécuter les instructions de `snowflake/rh/chargement_rh_1_preparer.sql` : exécutées par blocs dans Snowsight ; format, stage et tables confirmés le 4 novembre 2026.
- [x] Déposer les deux CSV sur `NYC_TAXI.RAW.RH_STAGE` depuis Snowsight : `LIST` transmis le 4 novembre 2026 confirme `drivers.csv` et `driver_shifts.csv` à la racine du stage.
- [x] Exécuter `snowflake/rh/chargement_rh_2_copier.sql` : résultats finaux transmis le 4 novembre 2026.
- [x] Vérifier les volumes RAW et que le stage est vide : 400 chauffeurs, 25 951 services et `LIST` sans résultat, confirmés le 4 novembre 2026.
- [x] Exécuter `snowflake/rh/00_tables_rh.sql`.
- [x] Exécuter les vues `staging/stg_rh__drivers.sql`, puis `staging/stg_rh__driver_shifts.sql`.
- [x] Exécuter `marts/dim_depot.sql`, `marts/dim_driver.sql`, puis `marts/mart_driver_monthly.sql`.
- [x] Comparer les volumes aux valeurs du guide, avant toute purge.

| Objet | Lignes attendues avant purge |
|---|---:|
| `RAW.DRIVERS` | 400 |
| `RAW.DRIVER_SHIFTS` | 25 951 |
| `STAGING.STG_RH__DRIVER_SHIFTS` | 25 933 |
| `MARTS.DIM_DEPOT` | 3 |
| `MARTS.DIM_DRIVER` | 400 |
| `MARTS.MART_DRIVER_MONTHLY` | 914 |

**État au 4 novembre 2026 :** exclusion Git revérifiée et volumes sources contrôlés localement : 400 chauffeurs, 25 951 services, 25 933 services distincts et 914 groupes mensuels. Script `snowflake/rh/verification_chargement_rh.sql` ajouté et procédure détaillée dans le README. Préparation Snowflake exécutée par le titulaire par blocs : résultats reçus pour le format `CSV_RH`, les tables `RAW.DRIVERS` et `RAW.DRIVER_SHIFTS` (0 ligne chacune) et le stage `RAW.RH_STAGE` (répertoire activé), tous propriétaires `TRANSFORMER`. Le dépôt des deux CSV est confirmé ci-dessous. La construction et le contrôle final sont également confirmés ci-dessous par les résultats Snowsight transmis.

**Chargement initial confirmé le 4 novembre 2026 :** après le dépôt des deux CSV, les résultats finaux transmis pour le script de copie donnent 400 chauffeurs et 25 951 services dans RAW. Le résultat `LIST` est vide : les fichiers ont été retirés du stage.

**Relance diagnostiquée le 4 novembre 2026 :** erreur reçue : `Remote file '@rh_stage/drivers.csv' was not found.` Les fichiers ont été retirés par `PURGE = TRUE`, alors que `FILES` exigeait toujours leur présence. Le contrôle séparé confirme toujours 400 chauffeurs, 25 951 services et un stage vide. Script corrigé localement : un `PATTERN` distinct par nom de CSV remplace `FILES`, avec maintien de la purge et de l’arrêt sur erreur de données. La version corrigée a ensuite été exécutée sans nouveau dépôt : le titulaire confirme que tout passe, avec 400 chauffeurs, 25 951 services et un stage vide. Relance validée sur ces résultats le 4 novembre 2026.

**Validation complète le 4 novembre 2026 :** résultats finaux transmis pour `snowflake/rh/verification_chargement_rh.sql` : rôle `TRANSFORMER`, warehouse `NYC_TAXI_WH`, six statuts `OK` (400 chauffeurs RAW, 25 951 services RAW, 25 933 services STAGING, 3 dépôts, 400 chauffeurs MARTS et 914 lignes mensuelles), puis `LIST` sans résultat. Tables et vues construites, relance corrigée sans ajout de lignes et stage vide confirmés. Étape 3 terminée avant toute purge et installation de la gouvernance.

## 4. Installer la gouvernance et documenter — fin du jour 1

- [x] Étudier les exemples `00_bac_a_sable.sql` et `01_role_gouvernance.sql` dans leur environnement indépendant : exécutions confirmées par le titulaire le 4 novembre 2026, 6 clients et 5 colonnes taguées attendues.
- [x] Écrire `snowflake/gouvernance/01_gouvernance.sql` : rôle, schéma, droits, trois tags et table `QUALITE_RESULTATS`, selon le guide et le contrat.
- [x] Accorder à `TRANSFORMER` les droits nécessaires aux tags, aux résultats de qualité et à la future vue du catalogue : attributions confirmées par les résultats Snowsight transmis le 4 novembre 2026.
- [x] Compléter la carte des droits et des propriétaires dans `docs/ACCES.md`.
- [x] Exécuter le modèle de catalogue de `DIM_DEPOT` : exécution confirmée par le titulaire le 4 novembre 2026 ; huit références de tags reçues (deux par colonne), valeurs conformes, aucun tag personnel. Descriptions à confirmer au contrôle global.
- [x] Créer dans `snowflake/rh/catalogue/` les fiches complètes de `RAW.DRIVERS` et de `MARTS.DIM_DRIVER` : description de table, de chaque colonne et tags.
- [x] Créer les fiches courtes de `RAW.DRIVER_SHIFTS` et de `MARTS.MART_DRIVER_MONTHLY` : description de table et tags requis.
- [x] Taguer les colonnes personnelles de l’inventaire, y compris les colonnes calculées comme `driver_name` : extension `donnee_professionnelle` autorisée, scripts exécutés avec succès et 38 lignes au contrôle confirmées par le titulaire le 6 novembre 2026.
- [x] Vérifier les descriptions et les tags ; enregistrer une capture des tags d’une table : contrôle global conforme et `docs/tags_dim_driver.png` examinée le 6 novembre 2026, complétée par l’export CSV de 31 lignes.

**État au 4 novembre 2026 :** exemples 00 et 01 exécutés dans leur environnement indépendant, résultats transmis par le titulaire : `NB_CLIENTS = 6`, puis CLIENT_ID/identifiant, EMAIL/email, NOM/nom, SCORE/score et TELEPHONE/telephone. Initialisation de la variable utilisateur corrigée avec une sous-requête et un identifiant délimité ; attribution des rôles confirmée réussie. Script d’installation et quatre fiches de catalogue écrits, carte des droits documentée avec distinction prévu/vérifié. Contrôle `snowflake/rh/catalogue/verification_catalogue.sql` préparé. Le modèle DIM_DEPOT est corrigé pour ne plus sélectionner la colonne inexistante `level` dans TAG_REFERENCES_ALL_COLUMNS. Les exécutions sont effectuées par le titulaire dans Snowsight ; aucune exécution directe depuis cette session et aucune capture produite ici. Installation confirmée par les résultats transmis, consignés ci-dessous.

**Écart conservé sur décision du titulaire :** catégories absentes du contrat pour les dates professionnelles, dépôts, horaires et métriques. Les fiches préparent les 18 tags de catégories établies ; la couverture de toutes les données personnelles reste partielle et doit être clarifiée avec le formateur.

**Catalogue DIM_DEPOT — résultat transmis le 4 novembre 2026 :** DEPOT, QUARTIER, OUVERT_EN et NB_PLACES héritent chacun de `SENSIBILITE = interne` et de `DUREE_CONSERVATION = sans limite : référentiel de l’entreprise`. Aucun tag DONNEE_PERSONNELLE dans le résultat. Le tableau des descriptions n’a pas été transmis ; leur présence reste à confirmer avec `verification_catalogue.sql`.

**Catalogue RAW.DRIVERS — résultats transmis le 6 novembre 2026 :** les douze colonnes, métadonnées comprises, ont une description non vide. Les sept affectations DONNEE_PERSONNELLE sont conformes : DRIVER_ID/identifiant_interne, FIRST_NAME et LAST_NAME/nom, EMAIL/email, PHONE/telephone, BIRTH_DATE/date_naissance, TLC_LICENSE_NUMBER/identifiant_officiel. Les douze colonnes héritent de SENSIBILITE/confidentiel et de la durée documentaire de cinq ans après fin du contrat (31 références de tags au total). La description de table reste à confirmer au contrôle global. Les catégories professionnelles non couvertes restent à clarifier selon la décision du titulaire. Fiche MARTS.DIM_DRIVER ensuite exécutée et contrôlée ci-dessous.

**Catalogue MARTS.DIM_DRIVER — résultats transmis le 6 novembre 2026 :** les douze colonnes disposent d’une description, y compris IS_ACTIVE et TENURE_YEARS. Les sept affectations DONNEE_PERSONNELLE sont conformes : DRIVER_ID/identifiant_interne, FIRST_NAME et LAST_NAME/nom, EMAIL/email, PHONE/telephone, BIRTH_DATE/date_naissance, TLC_LICENSE_NUMBER/identifiant_officiel. Les douze colonnes héritent de SENSIBILITE/confidentiel et de la durée documentaire de cinq ans après fin du contrat (31 références de tags au total). La description de table reste à confirmer au contrôle global. Les catégories professionnelles manquantes, notamment pour IS_ACTIVE et TENURE_YEARS, restent explicitement à clarifier. Fiche RAW.DRIVER_SHIFTS ensuite exécutée et contrôlée ci-dessous.

**Catalogue RAW.DRIVER_SHIFTS — résultats transmis le 6 novembre 2026 :** SHIFT_ID et DRIVER_ID portent DONNEE_PERSONNELLE/identifiant_interne. Les dix colonnes, métadonnées comprises, héritent de SENSIBILITE/confidentiel et de la durée documentaire de cinq ans après fin du contrat (22 références de tags au total). Les descriptions de colonnes sont vides, conformément au périmètre de la fiche courte ; la description de table reste à confirmer au contrôle global. Les autres données professionnelles personnelles restent dans l’écart de taxonomie à clarifier. Fiche MARTS.MART_DRIVER_MONTHLY ensuite exécutée et contrôlée ci-dessous.

**Catalogue MARTS.MART_DRIVER_MONTHLY — résultats transmis le 6 novembre 2026 :** DRIVER_ID porte DONNEE_PERSONNELLE/identifiant_interne et le nom calculé DRIVER_NAME porte DONNEE_PERSONNELLE/nom. Les huit colonnes héritent de SENSIBILITE/confidentiel et de la durée documentaire de cinq ans après fin du contrat (18 références de tags au total). Descriptions de colonnes vides admises pour cette fiche courte ; description de table à confirmer au contrôle global. Les 18 affectations personnelles prévues sur les quatre tables RH sont désormais confirmées individuellement. La case couvrant toutes les colonnes personnelles reste ouverte en raison de l’écart de taxonomie conservé avec le titulaire. Restent le contrôle global, la rejouabilité et la capture réelle.

**Validation actuelle au 6 novembre 2026 :** étape 4 terminée. Installation, catalogue, contrôles et relances confirmés par le titulaire (5 tables, 28 colonnes, 38 affectations personnelles). Extension donnee_professionnelle autorisée et appliquée ; capture et CSV renouvelés vérifiés. Les états antérieurs ci-dessous retracent la progression.



**Installation confirmée le 4 novembre 2026 — résultats Snowsight transmis par le titulaire :** les trois tags `SENSIBILITE`, `DONNEE_PERSONNELLE` et `DUREE_CONSERVATION` appartiennent à `GOUVERNANCE`, avec les valeurs autorisées du contrat. Le schéma et la table `QUALITE_RESULTATS` appartiennent également à ce rôle. La table contient `REGLE` (VARCHAR), `MESURE_LE` (TIMESTAMP_NTZ), `NB_ANOMALIES` (NUMBER(18,0)), `SEUIL` (NUMBER(18,2)) et `STATUT` (VARCHAR) ; `NB_MESURES = 0`. Les attributions transmises de `GOUVERNANCE` montrent USAGE sur la base, le warehouse, RAW et MARTS, les propriétés attendues et les deux privilèges globaux APPLY MASKING POLICY / APPLY ROW ACCESS POLICY ; aucun SELECT RH ni rôle de lecture hérité n’apparaît dans cette sortie. `TRANSFORMER` dispose de USAGE et CREATE VIEW sur le schéma GOUVERNANCE, APPLY sur chacun des trois tags et INSERT/SELECT sur QUALITE_RESULTATS. Catalogue, rejouabilité et capture restent à vérifier ; aucune politique créée à cette étape.




**Contrôle global du catalogue confirmé le 6 novembre 2026 — résultats Snowsight transmis par le titulaire :** contexte TRANSFORMER / NYC_TAXI_WH ; aucune ligne aux deux contrôles de descriptions manquantes ; 5 tables sur 5 décrites ; 28 colonnes sur 28 décrites pour RAW.DRIVERS, MARTS.DIM_DRIVER et MARTS.DIM_DEPOT ; 18 affectations DONNEE_PERSONNELLE sur 18 avec statut OK, dont le nom calculé DRIVER_NAME. Les quatre tables RH portent SENSIBILITE/confidentiel et la durée documentaire de cinq ans après fin du contrat ; DIM_DEPOT porte SENSIBILITE/interne et sa durée de référentiel. Les trois tags et le schéma de gouvernance appartiennent à GOUVERNANCE ; les cinq tables et les deux vues STAGING appartiennent à TRANSFORMER. Les droits attendus de TRANSFORMER sur les tags, les résultats de qualité et la création de vues sont présents. Aucun SELECT RH ni rôle de lecture hérité dans les attributions fournies de GOUVERNANCE ; son attribution à l’utilisateur testeur est confirmée, sans recopier l’identifiant dans le dépôt.

**Reste à terminer pour l’étape 4 :** rejouer le script d’installation de gouvernance et les cinq fiches, puis le contrôle global, pour confirmer la rejouabilité ; enregistrer une capture réelle des tags d’une table. La couverture des catégories professionnelles reste partielle et à clarifier avec le formateur, conformément au choix du titulaire. Ce contrôle ne valide ni la purge ni les politiques d’accès des jours suivants.




**Rejouabilité de l’installation de gouvernance confirmée le 6 novembre 2026 :** après relance de `snowflake/gouvernance/01_gouvernance.sql`, le titulaire transmet les trois tags avec leurs dates de création initiales et les valeurs autorisées inchangées, la structure conforme de QUALITE_RESULTATS, les propriétaires et droits attendus pour GOUVERNANCE et TRANSFORMER, puis NB_MESURES = 0. Cette relance est validée sur ces résultats ; la conservation de mesures préexistantes n’est pas testée puisque la table est vide. La relance des cinq fiches, le nouveau contrôle global et la capture restent à confirmer.


**Export des tags DIM_DRIVER vérifié le 6 novembre 2026 :** `docs/tags_dim_driver.csv` contient 31 références : 7 DONNEE_PERSONNELLE, 12 DUREE_CONSERVATION et 12 SENSIBILITE. Le fichier contient uniquement des métadonnées de colonnes et tags. Il complète les résultats transmis mais ne constitue pas la capture d’écran demandée par le brief ; capture partielle lisible enregistrée dans `docs/tags_dim_driver.png` et examinée le 6 novembre 2026.

**Confirmation finale des contrôles après relance — 6 novembre 2026 :** le titulaire confirme tous les résultats attendus : aucune description manquante, compteurs 5/5 et 28/28, 18 tags OK. Installation, fiches, contrôle global, rejouabilité et preuve des tags réalisés. Seule la couverture des données professionnelles sans catégorie autorisée reste ouverte, conformément à la décision de conserver cet écart pour clarification avec le formateur.

**Extension autorisée le 6 novembre 2026 — état actuel :** le titulaire accepte `donnee_professionnelle`. Cette décision remplace le maintien de l’écart dans les états précédents. Tag existant, quatre fiches, inventaire et contrôle global adaptés localement : 20 affectations supplémentaires, 38 attendues au total. Déploiement et contrôle Snowflake restent à confirmer ; la case de taggage intégral reste ouverte jusqu’à réception des 38 statuts OK. Après validation, actualiser les preuves DIM_DRIVER (12 tags personnels, 36 références au total).

**Extension appliquée — confirmation du titulaire le 6 novembre 2026 :** tous les scripts passent et le contrôle affiche les quantités attendues : 5 tables, 28 colonnes et 38 lignes pour les tags personnels. Les deux propriétés du tag ont été modifiées par des ALTER TAG séparés. La case de taggage intégral est cochée sur cette confirmation. Le classement professionnel est désormais appliqué ; le contrat pédagogique reste inchangé, l’adaptation étant documentée. Le titulaire confirme ici la réussite et les quantités ; aucun nouveau tableau détaillé des statuts n’a été transmis. Les preuves PNG/CSV conservées décrivent l’ancien état de DIM_DRIVER (7 tags personnels, 31 références) et restent à actualiser pour l’extension (12 tags personnels, 36 références).

**Preuves renouvelées vérifiées le 6 novembre 2026 :** `docs/tags_dim_driver.csv` contient 36 références : 12 DONNEE_PERSONNELLE, 12 DUREE_CONSERVATION et 12 SENSIBILITE. Les cinq affectations donnee_professionnelle attendues sont présentes sur DEPOT, HIRE_DATE, END_DATE, IS_ACTIVE et TENURE_YEARS. La capture `docs/tags_dim_driver.png` renouvelée est lisible, affiche 36 lignes au total et montre la nouvelle catégorie sur les premières lignes. Elle complète le CSV intégral. Ces preuves remplacent les anciens fichiers à 31 références. Étape 4 terminée avec l’extension de taxonomie autorisée par le titulaire et documentée, sans modification du contrat fourni.

## 5. Définir et tester les accès — jour 2

- [x] Exécuter les exemples `02_masquage_par_tag.sql` et `03_acces_par_ligne.sql` dans le bac à sable, en prévoyant les résultats avant les tests.
- [x] Écrire `snowflake/gouvernance/02_roles_metier.sql` : quatre rôles, droits sur les objets autorisés, warehouse et accès futur au catalogue.
- [x] Définir la représentation des valeurs masquées pour chaque type.
- [x] **Avant d’écrire les politiques**, compléter les résultats attendus du cahier de tests dans `docs/ACCES.md`.
- [x] Décider, colonne par colonne, du masquage ou de la suppression ; justifier les choix dans le README.
- [x] Écrire `snowflake/gouvernance/03_masquage.sql` avec `GOUVERNANCE`.
- [x] Prévoir le maintien de `driver_id` pour les rôles métier, l’année de naissance pour l’analyste et les valeurs nécessaires au pipeline pour `TRANSFORMER`.
- [x] Écrire `snowflake/gouvernance/04_acces_depot.sql` : table `ACCES_DEPOT`, correspondances et politique d’accès par ligne.
- [x] Contrôler les 29 attachements avant activation : 27 masquages et 2 filtres, tous OK ; propriétaires et droits de GOUVERNANCE/TRANSFORMER conformes aux sorties transmises le 6 novembre 2026.
- [x] Tester les quatre rôles métier, `TRANSFORMER`, `GOUVERNANCE` et `ACCOUNTADMIN`, rôles secondaires désactivés.
- [x] Vérifier les restrictions sur RAW et STAGING, en plus des lignes et valeurs visibles dans MARTS.
- [x] Ajouter temporairement un dépôt à un responsable pour prouver que la politique n’a pas besoin d’être modifiée ; rétablir ensuite les accès prévus.
- [x] Relancer les transformations avec `TRANSFORMER` et vérifier que les valeurs réelles, descriptions, tags et politiques sont conservés.
- [x] Rejouer les scripts de gouvernance pour vérifier leur rejouabilité.
- [ ] Compléter les résultats obtenus et enregistrer une capture de la même requête avec deux rôles.

**Validation :** cahier de tests vert et pipeline toujours fonctionnel après mise en place des protections.

**Préparation locale du 6 novembre 2026 :** attendus écrits dans docs/ACCES.md avant les politiques ; décisions colonne par colonne ajoutées au README. Les scripts 02/03/04 sont écrits : huit politiques de masque, 27 attachements directs et deux filtres de lignes ; les 38 tags personnels restent inchangés. L’attribution au testeur est séparée dans activation_roles_metier.sql et protégée par une vérification des 29 associations. Tests par rôle, extension temporaire avec nettoyage, comparaison du pipeline aux sources et capture agrégée préparés. Les cases de rédaction cochées attestent uniquement les fichiers locaux, pas leur déploiement. Aucun exemple, script ou test Snowflake de l’étape 5 n’a encore été exécuté depuis cette session ou confirmé par le titulaire ; aucun résultat obtenu ni capture inventé. Suivre l’ordre du README, commencer par les exemples 00/01 si nécessaire puis 02/03, et transmettre les résultats par blocs.

**Contrôle local de préparation :** 264 évaluations des expressions de masque et dix scénarios de comparaison des métadonnées réussis dans SQLite avec adaptation des fonctions ; volumes et prédicat de filtrage vérifiés à partir des CSV. Cohérence des manifestes, du catalogue et des copies des transformations contrôlée. Ce contrôle ne valide pas la compilation, les autorisations ni l’exécution Snowflake.

**Bac à sable — résultats partiels transmis le 6 novembre 2026 :** exemple 02, R1 conforme (cinq associations au tag PII : quatre MASK_TEXTE, une MASK_NOMBRE sur SCORE) ; R2 conforme sur C1 avec EX_PIPELINE (valeurs réelles) ; R3 conforme sur C1 avec EX_VENDEUR (nom et téléphone réels, e-mail partiellement masqué avec domaine conservé, score affiché vide pour NULL attendu). Aucun nom ni coordonnée du témoin recopié dans cette synthèse. Le volume total n’est pas établi par ces requêtes filtrées sur C1. R4 ensuite reçu et conforme avec EX_ANALYSTE : identifiant et région conservés, identité masquée, e-mail partiellement masqué et score 700. Prédicat sur e-mail ensuite confirmé sous EX_ANALYSTE : COUNT(*) = 0, conforme. Exemple 03 ensuite reçu : test 1 en écart (Nord 2 et Sud 2 au lieu de Nord seul) ; test 2 conforme (trois régions, deux lignes chacune) ; résultat du test 3 conforme (Nord 2, Sud 2), mais l’élargissement n’est pas prouvé puisque Sud était déjà visible au test 1 ; test 4 conforme pour les masques analyste de C1. Une relance du test 1 après l’ajout de Sud pourrait expliquer l’écart, sans confirmation de l’ordre réel. Rétablissement ciblé ensuite confirmé le 6 novembre 2026 : EX_VENDEUR voit Nord seul, deux lignes, après retrait de Sud. Contrôle EX_PIPELINE ensuite reçu le 6 novembre 2026 : NB_CLIENTS = 6 et CONTROLE_PIPELINE = OK, confirmant six clients et le témoin en clair avec score 720 après reconstruction. Vérifications du bac à sable terminées sur ces résultats ; écart initial conservé dans le suivi, avec retour confirmé à Nord seul après retrait de Sud. Aucune politique modifiée pour corriger cet écart. La case d’exécution des exemples est cochée ; les validations NYC_TAXI restent ouvertes.

**Rôles métier — script 02 confirmé le 6 novembre 2026 :** résultats des douze SHOW transmis et conformes. Chaque rôle RH_PAIE, RESP_DEPOT_QUEENS, RESP_DEPOT_BRONX et ANALYSTE possède sept droits actuels : USAGE sur NYC_TAXI, NYC_TAXI_WH, MARTS et GOUVERNANCE, puis SELECT sur DIM_DEPOT, DIM_DRIVER et MART_DRIVER_MONTHLY. Chaque rôle possède SELECT sur les vues futures de GOUVERNANCE ; ANALYSTE possède aussi SELECT sur les tables et vues futures de MARTS. Aucun SELECT RAW/STAGING ni rôle hérité n’apparaît dans les attributions fournies ; aucun GRANT OPTION vrai. Les quatre SHOW GRANTS OF ROLE ne renvoient aucune ligne : aucun de ces rôles n’est encore attribué à un utilisateur ou à un autre rôle dans ces sorties. Aucun droit actuel sur une vue n’est affiché, ce qui est compatible avec l’absence de vue à ce stade. Les rôles sont préparés mais non activés ; politiques 03/04, contrôle des associations et tests fonctionnels restent à exécuter.

**Masquage — création des politiques confirmée le 6 novembre 2026 :** SHOW MASKING POLICIES transmis contient exactement les huit politiques attendues dans NYC_TAXI.GOUVERNANCE, toutes propriétaires GOUVERNANCE : MASK_CONTACT, MASK_DRIVER_ID, MASK_NAISSANCE, MASK_PAIE, MASK_RAW_DATE, MASK_RAW_FLOAT, MASK_RAW_NUMBER et MASK_RAW_VARCHAR. Cette sortie confirme leur existence et leur propriétaire ; elle ne montre ni leurs corps ni leurs associations aux colonnes. Le résultat du bloc d’attachement n’a pas été transmis : les 27 attachements restent à confirmer avec verification_politiques.sql après le script 04. Aucun test fonctionnel NYC_TAXI ni activation métier n’est validé à ce stade.

**Accès par dépôt — résultats du script 04 reçus le 6 novembre 2026 :** contenu ACCES_DEPOT conforme aux cinq correspondances attendues : ANALYSTE, RH_PAIE et TRANSFORMER sur *, RESP_DEPOT_QUEENS sur Queens et RESP_DEPOT_BRONX sur Bronx. SHOW ROW ACCESS POLICIES confirme RAP_DEPOT dans NYC_TAXI.GOUVERNANCE, propriétaire GOUVERNANCE. La lecture du contenu ne prouve pas la propriété d’ACCES_DEPOT, attendue GOUVERNANCE selon le script. Le résultat du bloc d’attachement n’a pas été transmis ; les deux associations RAP_DEPOT et les 27 masquages restent à vérifier dans verification_politiques.sql avant activation des rôles métier. Aucun test fonctionnel NYC_TAXI n’est encore confirmé.

**Contrôle des protections confirmé le 6 novembre 2026 :** verification_politiques.sql retourne exactement 29 lignes OK : dix masques sur RAW.DRIVERS, huit sur RAW.DRIVER_SHIFTS, sept sur MARTS.DIM_DRIVER, deux sur MARTS.MART_DRIVER_MONTHLY et un filtre RAP_DEPOT sur chacune des deux tables MARTS RH. Aucune association manquante, différente ou supplémentaire dans ce contrôle, notamment sur DIM_DEPOT. SHOW GRANTS TO ROLE GOUVERNANCE confirme les propriétés des huit masques, de RAP_DEPOT, d’ACCES_DEPOT, de QUALITE_RESULTATS, des trois tags et du schéma, avec les privilèges APPLY globaux attendus ; aucun SELECT RH ni rôle de lecture hérité n’apparaît. Les droits de TRANSFORMER restent conformes : propriété des cinq tables et deux vues STAGING, accès aux sources et warehouse, création de vues/tâches, EXECUTE TASK, APPLY sur les trois tags et INSERT/SELECT sur QUALITE_RESULTATS ; aucun SELECT ACCES_DEPOT transmis. Identifiant de compte non recopié. Précondition d’activation validée ; attribution des quatre rôles métier, tests fonctionnels, relance du pipeline et rejouabilité encore à confirmer.

**Attribution des rôles métier confirmée le 6 novembre 2026 :** résultat transmis du bloc activation_roles_metier.sql : « Quatre rôles attribués à l’utilisateur courant ; tester un rôle principal à la fois. » Le bloc a donc franchi son contrôle des 29 associations et exécuté les quatre attributions prévues. Aucun identifiant utilisateur recopié. Les rôles RH_PAIE, RESP_DEPOT_QUEENS, RESP_DEPOT_BRONX et ANALYSTE sont désormais attribués au testeur ; leur activation par USE ROLE et leurs lectures effectives restent à vérifier dans les blocs B0 à B8 de 05_tests_acces.sql, dans une même session Snowsight. Aucune ligne de résultats fonctionnels n’est validée sur ce seul message.

**Correction du test de refus RH_PAIE — 6 novembre 2026 :** le titulaire transmet une erreur du bloc de restrictions de B1 indiquant que RAW est inaccessible à RH_PAIE faute de privilège sur le schéma. Ce refus est attendu ; aucun droit supplémentaire n’est accordé. Le gestionnaire initial ne reconnaissait que SQLSTATE 42501 et 42S02 ; les six blocs de refus de 05_tests_acces.sql acceptent désormais aussi 02000 uniquement si le message contient « does not exist or not authorized », cas documenté par Snowflake. Les autres erreurs continuent à être relancées ; les refus reconnus affichent désormais SQLSTATE et SQLCODE pour diagnostic, sans copier le message ni une identité utilisateur. Le SQLSTATE exact de l’erreur reçue n’a pas été communiqué. Premier refus RAW observé, mais bloc B1 complet et cinq résultats attendus encore à confirmer après correction ; B0 et autres tests non validés sans résultats transmis. Référence : [exemple officiel Snowflake d’objet inaccessible avec 002003 (02000)](https://docs.snowflake.com/en/user-guide/budgets/troubleshoot).

**Exécution regroupée — 6 novembre 2026 :** à la demande du titulaire de réduire les manipulations et les résultats à transmettre, 05_tests_acces_synthese.sql enchaîne les mêmes 31 groupes fonctionnels du fichier détaillé et affiche un seul tableau final pour les huit rôles. Il prépare automatiquement les références, réutilise le gestionnaire de refus corrigé, transforme les erreurs imprévues en statuts non conformes et rétablit le rôle initial à la fin. Aucun droit ni objet persistant modifié ; les vérifications métier ne sont pas marquées réussies tant que ce tableau n’a pas été transmis. Le message « Tests terminés » précédemment reçu ne prouvait pas les résultats individuels. Tests dépôt, reconstruction, rejouabilité et capture restent ensuite à valider.

**Synthèse fonctionnelle reçue le 6 novembre 2026 :** huit rôles, 31 groupes sur 31 OK, aucun détail d’écart. TRANSFORMER : 400 chauffeurs et 914 lignes mensuelles, 6/6 ; RH_PAIE : 400/914, 3/3 ; responsable Queens : 161/365, 4/4 ; responsable Bronx : 122/290, 4/4 ; ANALYSTE : 400/914, 3/3 ; GOUVERNANCE : lectures RH refusées, 1/1 ; ACCOUNTADMIN et SYSADMIN : 0/0, 5/5 chacun. Les groupes valident les masques et périmètres par comparaison aux références TRANSFORMER, le témoin, les refus RAW/STAGING et ACCES_DEPOT et les protections des sources pour les administrateurs. Le groupe GOUVERNANCE rassemble sept refus ; les cellules de volume vides ne sont pas des comptes à zéro. Les valeurs complètes de référence sont celles des MARTS actuels : leur comparaison indépendante à RAW sera validée avec P3, pas déduite de cette seule synthèse. Contrôles initiaux par rôle et restrictions validés ; extension temporaire, reconstruction et métadonnées après reconstruction, rejouabilité et capture restent ouverts.

**Extension de dépôt validée le 6 novembre 2026 :** le résultat du bloc test_extension_depot.sql confirme l’extension Queens + Brooklyn à 278 chauffeurs et 624 lignes mensuelles, le retour à Queens seul à 161/365 et cinq correspondances après retrait de l’accès temporaire. Aucune politique modifiée. P1/P2 sont validés ; la reconstruction est la prochaine vérification. verification_pipeline_acces.sql a été regroupé pour une exécution en entier avec un seul tableau de quatre contrôles, sans modifier les transformations métier. Cette adaptation n’est pas une preuve de reconstruction : P3 reste ouvert jusqu’au résultat transmis, et P4/P5/P7 restent à confirmer.

**Correction du contrôle pipeline — 6 novembre 2026 :** le titulaire transmet « INTO clause is not allowed in this context » sur la version regroupée. Deux SELECT…INTO sans FROM avaient été introduits : capture initiale des empreintes et contrôle du contenu conservé. La capture utilise désormais trois agrégats SELECT HASH_AGG(*) INTO … FROM table ; le contrôle avant/après lit trois sous-requêtes agrégées avec FROM/CROSS JOIN. Les comparaisons indépendantes à RAW, les transformations et le tableau final de quatre contrôles sont conservés. Vérification locale : chaque affectation SELECT…INTO possède une clause FROM au niveau principal, et les transformations restent identiques aux fichiers métier. P3 demeure non validé jusqu’à réception du résultat corrigé. Référence : [syntaxe INTO de Snowflake](https://docs.snowflake.com/en/sql-reference/constructs/into).

**Premier résultat pipeline reçu le 6 novembre 2026 :** CONTENU_CONSERVE = ECART ; DIMENSION_CONFORME_A_RAW = OK avec 0 différence ; MENSUEL_CONFORME_A_RAW = OK avec 0 différence ; CONTACT_TEMOIN_RESTE_REEL = OK. Les tables reconstruites correspondent au recalcul indépendant depuis RAW, mais au moins une empreinte diffère de l’état précédent. P3 reste partiel : l’écart avant/après n’est pas effacé. Hypothèse documentée : TENURE_YEARS utilise CURRENT_DATE pour les chauffeurs actifs ; la construction initiale est datée du 4 novembre et la reconstruction du 6 novembre. Un calcul local décimal sur les CSV montre 23 anciennetés arrondies différentes entre ces deux dates ; cela ne prouve pas que l’état Snowflake précédent était exactement celui du 4 novembre ni que cette colonne explique tout l’écart. Prochaine vérification : relancer le même fichier sans modification des données pour tester la stabilité de la reconstruction désormais à jour. Si l’écart persiste, examiner les tables/colonnes concernées ; aucune règle de contrôle n’est assouplie. Métadonnées, relance des accès, rejouabilité de gouvernance et capture restent à confirmer.

**Reconstruction stable confirmée le 6 novembre 2026 :** seconde exécution de verification_pipeline_acces.sql : CONTENU_CONSERVE = OK, DIMENSION_CONFORME_A_RAW = OK / 0 différence, MENSUEL_CONFORME_A_RAW = OK / 0 différence et CONTACT_TEMOIN_RESTE_REEL = OK. P3 est validé pour cette seconde exécution : contenu stable et conforme aux sources, coordonnées de paie réelles. Le premier ECART reste consigné ; l’hypothèse des anciennetés recalculées selon CURRENT_DATE n’est pas une identification certaine de sa cause. Les comparaisons indépendantes à RAW prévues pour D1/D5 sont désormais acquises ; les accès devront encore être rejoués après reconstruction. verification_post_pipeline.sql regroupe en un tableau les cinq contrôles de descriptions, tags de table, tags personnels et politiques ; P4 reste ouvert jusqu’à réception de ce tableau. Rejouabilité de gouvernance et capture restent à confirmer.

**Métadonnées après reconstruction validées le 6 novembre 2026 :** tableau verification_post_pipeline.sql reçu avec cinq statuts OK et aucun écart : 5 tables décrites, 28 colonnes décrites, 5 tables portant les tags de table attendus, 38 affectations personnelles conformes et 29 associations de politiques conformes. P4 et la case de reconstruction avec conservation des métadonnées sont validés. Les tests initiaux des accès sont déjà conformes ; la synthèse devra encore être relancée après la rejouabilité pour confirmer l’ensemble des lectures après ces opérations. Pour réduire les manipulations, rejouabilite_gouvernance.sql reprend en un fichier les opérations des scripts 01 à 04 et des cinq fiches catalogue, puis affiche le même tableau final de cinq contrôles. Aucun résultat de cette relance n’est encore reçu : P5 reste ouvert, ainsi que P7 pour la capture.

**Relance gouvernance et catalogue reçue le 6 novembre 2026 :** après exécution de rejouabilite_gouvernance.sql, le titulaire transmet le tableau final : 5 tables décrites, 28 colonnes décrites, 5 tables taguées, 38 affectations personnelles et 29 politiques, tous conformes, zéro écart. La relance des opérations 01 à 04 et des cinq fiches atteint donc son contrôle final sans échec signalé, avec métadonnées et associations préservées. Pour clore P5, la synthèse fonctionnelle des huit rôles doit encore être rejouée sur cet état ; aucune réussite de cette relecture n’est déduite du seul tableau des métadonnées. La capture comparative P7 reste également à fournir.

**Relecture finale des accès validée le 6 novembre 2026 :** après reconstruction, contrôle des métadonnées et relance des scripts de gouvernance/catalogue, le titulaire transmet à nouveau les huit rôles avec 31 groupes sur 31 OK, aucun détail d’écart et les mêmes volumes attendus (400/914 pour TRANSFORMER, paie et analyste ; 161/365 Queens ; 122/290 Bronx ; refus GOUVERNANCE ; 0/0 administrateurs). P5 et la case de rejouabilité sont validés. Tous les contrôles fonctionnels de l’étape 5 sont acquis ; seule la preuve de capture P7 reste ouverte. capture_acces.sql est désormais exécutable en entier : la même requête agrégée passe sous RH_PAIE et ANALYSTE, puis affiche un tableau unique de six lignes, sans valeur personnelle. Capture attendue dans docs/acces_comparaison_roles.png ; aucun fichier image n’est présumé créé.

**Capture examinée le 6 novembre 2026 :** docs/acces_comparaison_roles.png existe et a été ouverte pour inspection. Le tableau montre les six lignes attendues : RH_PAIE et ANALYSTE voient chacun Bronx 122, Brooklyn 117 et Queens 161. Les compteurs de masquage paie sont nuls ; pour ANALYSTE, noms/prénoms/e-mails masqués sur tous les effectifs, téléphones masqués 117/115/156 (NULL préservés), naissances réduites au 1er janvier 122/117/161. Deux naissances paie du Bronx tombent déjà un 1er janvier, ce qui est compatible avec les données réelles et ne remplace pas les tests exhaustifs déjà validés. Le contenu du résultat est conforme. En revanche, l’image montre tout le bureau, des onglets personnels et un identifiant de compte dans l’URL : cadrage à corriger avant inclusion dans le dépôt public, conformément au brief. Aucune de ces identités n’est recopiée ici. Remplacer le même PNG par une capture limitée au tableau de résultats ; aucun recadrage ni remplacement de l’original effectué par l’assistant. P7 reste partiel et la dernière case de l’étape 5 reste ouverte jusqu’à vérification du cadrage corrigé.

## 6. Gérer la conservation et la qualité — jour 3, matin

- [ ] Compter les chauffeurs concernés par la purge avant de la lancer.
- [ ] Écrire `snowflake/rh/purge_rh.sql` pour supprimer les données des chauffeurs partis depuis plus de cinq ans, en couvrant les services et toutes les copies concernées.
- [ ] Prévoir l’ordre des suppressions pour retrouver les services des chauffeurs à purger avant de supprimer ces chauffeurs.
- [ ] Vérifier la disparition des données concernées, y compris après reconstruction des MARTS.
- [ ] Prouver avec Time Travel qu’une ligne supprimée reste temporairement lisible.
- [ ] Écrire `snowflake/rh/conservation_rh.sql` avec `TRANSFORMER` : rétention limitée à un jour sur chaque table concernée.
- [ ] Vérifier à nouveau que le stage est vide.
- [ ] Documenter Time Travel et Fail-safe dans le registre, en distinguant restauration accessible et conservation résiduelle.
- [ ] Implémenter au moins `licence_unique`, `service_rattache` et une troisième règle dans `snowflake/rh/controles/`.
- [ ] Documenter l’énoncé, le seuil et la gravité de chaque règle ; convertir les seuils en pourcentage en nombres au moment de la mesure.
- [ ] Créer `GOUVERNANCE.V_CATALOGUE` avec `TRANSFORMER`, dans un script de `snowflake/rh/catalogue/`.
- [ ] Vérifier que l’analyste peut lire le catalogue des trois tables MARTS, avec descriptions, types et tags.

**Validation :** conservation vérifiée, règles de qualité définies et catalogue accessible à un rôle métier.

## 7. Automatiser et prouver — jour 3, après-midi

- [ ] Écrire `snowflake/rh/taches_rh.sql` avec `TRANSFORMER` : chaîne quotidienne `T_PURGE → T_QUALITE → T_TABLES`.
- [ ] Faire enregistrer les mesures dans `QUALITE_RESULTATS` avant de lever une erreur en cas de dépassement bloquant.
- [ ] Activer le graphe, lancer une exécution et vérifier la réussite des trois tâches.
- [ ] Vérifier les résultats de qualité enregistrés et les volumes après purge.
- [ ] Provoquer un dépassement bloquant contrôlé : abaisser temporairement le seuil, en suspendant la racine avant toute modification du graphe.
- [ ] Prouver que `T_QUALITE` échoue, que le résultat `ALERTE` est enregistré et que `T_TABLES` ne démarre pas.
- [ ] Rétablir le seuil du contrat et vérifier une nouvelle exécution réussie.
- [ ] Vérifier après reconstruction la présence des politiques, tags et descriptions et la validité des accès.
- [ ] Écrire `snowflake/gouvernance/06_audit.sql` : lectures de `DIM_DRIVER` sur sept jours, avec utilisateur et rôle, en reliant `ACCESS_HISTORY` à `QUERY_HISTORY`.
- [ ] Tenir compte du délai de disponibilité de l’historique lors de la collecte des preuves.
- [ ] Enregistrer les captures : graphe réussi, contenu de `QUALITE_RESULTATS`, audit et lignage de `MART_DRIVER_MONTHLY`.
- [ ] Terminer la partie 2 du registre et la section « Gouvernance » du README : ordre d’exécution, choix techniques, écarts, preuves et limites.
- [ ] Documenter le comportement prévu si les RH renvoient un fichier complet contenant des chauffeurs déjà purgés.
- [ ] Vérifier l’absence de secrets et de données personnelles dans les fichiers et captures destinés au dépôt public.
- [ ] Suspendre la tâche racine à la fin des essais.

**Validation :** chaîne réussie prouvée, blocage qualité démontré, protections conservées et audit exploitable.

## 8. Préparer la soutenance et vérifier les livrables

- [ ] Préparer environ 5 minutes de veille : droit applicable, écart principal du contrat et dispositif de suivi.
- [ ] Préparer environ 10 minutes de démonstration : catalogue, comparaison des rôles, ajout d’un dépôt, tâches, purge et audit.
- [ ] Répartir les deux parties entre les membres du binôme ; chacun doit pouvoir expliquer l’ensemble.
- [ ] Répéter la démonstration avec les bons rôles et des requêtes prêtes.
- [ ] Vérifier que le README permet de rejouer l’installation dans l’ordre.
- [ ] Vérifier la présence de `docs/VEILLE.md`, `docs/REGISTRE.md`, `docs/ACCES.md`, des scripts SQL et des sept captures demandées.
- [ ] Vérifier les critères C4, C19, C20 et C21 dans le brief avant la présentation.

**Validation finale :** dépôt prêt à être évalué et présentation de 15 minutes maximum, suivie de 5 minutes de questions.

## Bonus — une fois le socle terminé

- [ ] Comparer la classification automatique Snowflake à l’inventaire manuel.
- [ ] Créer une alerte lorsqu’une règle de qualité passe en `ALERTE`.
- [ ] Étudier une politique d’agrégation pour l’analyste.
