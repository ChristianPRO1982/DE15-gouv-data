# Les accès — carte des droits et cahier de tests

Préparé à partir du modèle le 3 novembre 2026. Carte initiale complétée le 4 novembre 2026 ; attendus de l’étape 5 écrits le 6 novembre 2026 avant les politiques. Bac à sable et droits du script 02 confirmés sur les résultats transmis le 6 novembre 2026 ; création des huit politiques de masque confirmée ; cinq correspondances de dépôt et existence/propriété de RAP_DEPOT confirmées ; 29 attachements confirmés OK ; attribution des quatre rôles au testeur confirmée ; 31 groupes fonctionnels NYC_TAXI confirmés OK ; extension de dépôt, reconstruction, rejouabilité et capture encore attendues.

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
| Politiques de masquage | `GOUVERNANCE`, propriété des huit politiques et 27 attachements confirmés le 6 novembre 2026 |
| Politique d'accès par ligne | `GOUVERNANCE`, propriété de RAP_DEPOT et deux attachements confirmés le 6 novembre 2026 |
| Table `ACCES_DEPOT` | `GOUVERNANCE`, propriété confirmée par SHOW GRANTS le 6 novembre 2026 ; cinq correspondances conformes |
| Table `QUALITE_RESULTATS` | `GOUVERNANCE`, propriété confirmée le 4 novembre 2026 |
| Vue `V_CATALOGUE` | `TRANSFORMER`, création prévue jour 3 |

### Qui fait quoi, avec quel droit

| Action | Rôle qui la fait | Privilège nécessaire | Accordé par |
|---|---|---|---|
| Créer un tag | `GOUVERNANCE` | `CREATE TAG` sur le schéma, ou en être propriétaire | `ACCOUNTADMIN` |
| Poser un tag sur une colonne de `DIM_DRIVER` | `TRANSFORMER` | Propriété de la table + `APPLY` sur le tag + accès base/schémas | `GOUVERNANCE` accorde APPLY et USAGE sur son schéma |
| Créer une politique de masquage | `GOUVERNANCE` | Propriété du schéma (ou CREATE MASKING POLICY) | `ACCOUNTADMIN` transfère le schéma ; création jour 2 |
| Attacher un masque directement à une colonne | `GOUVERNANCE` | APPLY MASKING POLICY global + accès base/schéma ; aucun SELECT requis | `ACCOUNTADMIN` ; 27 attachements confirmés le 6 novembre 2026 |
| Ajouter une politique d'accès par ligne à une table | `GOUVERNANCE` | APPLY ROW ACCESS POLICY sur le compte, accès base/schéma | `ACCOUNTADMIN` ; deux attachements confirmés le 6 novembre 2026 |
| Écrire une ligne dans `QUALITE_RESULTATS` | `TRANSFORMER` | INSERT sur la table, USAGE sur base/schéma | `GOUVERNANCE` ; SELECT également accordé pour contrôler |
| Lire `DIM_DRIVER` | `TRANSFORMER` ; quatre rôles métier créés et attribués au testeur le 6 novembre 2026 | Propriété ou SELECT, USAGE base/schéma et warehouse | Propriété TRANSFORMER ; droits métier du script 02 confirmés le 6 novembre 2026 |
| Exécuter une requête | chaque rôle | USAGE warehouse et droits sur objets visés | `ACCOUNTADMIN` pour NYC_TAXI_WH |
| Créer la future vue de catalogue | `TRANSFORMER` | CREATE VIEW et USAGE sur GOUVERNANCE ; accès aux sources | `GOUVERNANCE` |

**Rôles métier — script 02 confirmé le 6 novembre 2026 :** résultats des douze SHOW transmis et conformes. Chaque rôle RH_PAIE, RESP_DEPOT_QUEENS, RESP_DEPOT_BRONX et ANALYSTE possède sept droits actuels : USAGE sur NYC_TAXI, NYC_TAXI_WH, MARTS et GOUVERNANCE, puis SELECT sur DIM_DEPOT, DIM_DRIVER et MART_DRIVER_MONTHLY. Chaque rôle possède SELECT sur les vues futures de GOUVERNANCE ; ANALYSTE possède aussi SELECT sur les tables et vues futures de MARTS. Aucun SELECT RAW/STAGING ni rôle hérité n’apparaît dans les attributions fournies ; aucun GRANT OPTION vrai. Les quatre SHOW GRANTS OF ROLE ne renvoient aucune ligne : aucun de ces rôles n’est encore attribué à un utilisateur ou à un autre rôle dans ces sorties. Aucun droit actuel sur une vue n’est affiché, ce qui est compatible avec l’absence de vue à ce stade. Les rôles sont préparés mais non activés ; politiques 03/04, contrôle des associations et tests fonctionnels restent à exécuter.

**Masquage — création des politiques confirmée le 6 novembre 2026 :** SHOW MASKING POLICIES transmis contient exactement les huit politiques attendues dans NYC_TAXI.GOUVERNANCE, toutes propriétaires GOUVERNANCE : MASK_CONTACT, MASK_DRIVER_ID, MASK_NAISSANCE, MASK_PAIE, MASK_RAW_DATE, MASK_RAW_FLOAT, MASK_RAW_NUMBER et MASK_RAW_VARCHAR. Cette sortie confirme leur existence et leur propriétaire ; elle ne montre ni leurs corps ni leurs associations aux colonnes. Le résultat du bloc d’attachement n’a pas été transmis : les 27 attachements restent à confirmer avec verification_politiques.sql après le script 04. Aucun test fonctionnel NYC_TAXI ni activation métier n’est validé à ce stade.

**Accès par dépôt — résultats du script 04 reçus le 6 novembre 2026 :** contenu ACCES_DEPOT conforme aux cinq correspondances attendues : ANALYSTE, RH_PAIE et TRANSFORMER sur *, RESP_DEPOT_QUEENS sur Queens et RESP_DEPOT_BRONX sur Bronx. SHOW ROW ACCESS POLICIES confirme RAP_DEPOT dans NYC_TAXI.GOUVERNANCE, propriétaire GOUVERNANCE. La lecture du contenu ne prouve pas la propriété d’ACCES_DEPOT, attendue GOUVERNANCE selon le script. Le résultat du bloc d’attachement n’a pas été transmis ; les deux associations RAP_DEPOT et les 27 masquages restent à vérifier dans verification_politiques.sql avant activation des rôles métier. Aucun test fonctionnel NYC_TAXI n’est encore confirmé.

**Contrôle des protections confirmé le 6 novembre 2026 :** verification_politiques.sql retourne exactement 29 lignes OK : dix masques sur RAW.DRIVERS, huit sur RAW.DRIVER_SHIFTS, sept sur MARTS.DIM_DRIVER, deux sur MARTS.MART_DRIVER_MONTHLY et un filtre RAP_DEPOT sur chacune des deux tables MARTS RH. Aucune association manquante, différente ou supplémentaire dans ce contrôle, notamment sur DIM_DEPOT. SHOW GRANTS TO ROLE GOUVERNANCE confirme les propriétés des huit masques, de RAP_DEPOT, d’ACCES_DEPOT, de QUALITE_RESULTATS, des trois tags et du schéma, avec les privilèges APPLY globaux attendus ; aucun SELECT RH ni rôle de lecture hérité n’apparaît. Les droits de TRANSFORMER restent conformes : propriété des cinq tables et deux vues STAGING, accès aux sources et warehouse, création de vues/tâches, EXECUTE TASK, APPLY sur les trois tags et INSERT/SELECT sur QUALITE_RESULTATS ; aucun SELECT ACCES_DEPOT transmis. Identifiant de compte non recopié. Précondition d’activation validée ; attribution des quatre rôles métier, tests fonctionnels, relance du pipeline et rejouabilité encore à confirmer.

**Attribution des rôles métier confirmée le 6 novembre 2026 :** résultat transmis du bloc activation_roles_metier.sql : « Quatre rôles attribués à l’utilisateur courant ; tester un rôle principal à la fois. » Le bloc a donc franchi son contrôle des 29 associations et exécuté les quatre attributions prévues. Aucun identifiant utilisateur recopié. Les rôles RH_PAIE, RESP_DEPOT_QUEENS, RESP_DEPOT_BRONX et ANALYSTE sont désormais attribués au testeur ; leur activation par USE ROLE et leurs lectures effectives restent à vérifier dans les blocs B0 à B8 de 05_tests_acces.sql, dans une même session Snowsight. Aucune ligne de résultats fonctionnels n’est validée sur ce seul message.

### Ce que cette carte permet à un rôle de défaire

`TRANSFORMER`, propriétaire des tables, peut modifier les objets et dispose de leur contenu réel. Le masquage retenu à l’étape 5 est direct : retirer un tag ne le retire pas. Ses possibilités de détachement et les droits APPLY doivent être surveillés. `GOUVERNANCE` peut changer les règles ou les détacher avec ses privilèges globaux ; il ne reçoit aucun SELECT sur RAW, STAGING ou MARTS, ni aucun rôle de lecture en héritage. Les administrateurs peuvent changer les droits : les futures politiques doivent aussi tester leur lecture.

Ces pouvoirs sont nécessaires au montage pédagogique ; l’audit des lectures et changements reste à mettre en place au jour 3. Les droits métier du script 02 sont désormais confirmés ; les huit politiques de masque existent ; RAP_DEPOT existe et les cinq correspondances sont conformes ; les 29 attachements sont confirmés OK. Contrôler `SHOW GRANTS TO ROLE GOUVERNANCE` avec ACCOUNTADMIN, y compris les éventuels rôles hérités préexistants ; `CREATE IF NOT EXISTS` ne supprime pas d’anciens droits.

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

Exécuter désormais `snowflake/gouvernance/05_tests_acces_synthese.sql` **en entier** : les références et changements de rôles sont automatiques, avec rôles secondaires désactivés. Un seul tableau de huit lignes regroupe les 31 groupes de tests (TRANSFORMER 6, RH_PAIE 3, Queens 4, Bronx 4, ANALYSTE 3, GOUVERNANCE 1, ACCOUNTADMIN 5, SYSADMIN 5). Chaque ligne doit afficher STATUT = OK et GROUPES_OK = GROUPES_DE_TESTS. Les refus attendus sont comptabilisés ; une lecture autorisée inattendue ou une erreur SQL rend la synthèse non conforme. Le script détaillé reste disponible pour diagnostiquer une ligne en écart.

| N° | Rôle | DIM_DRIVER | MART_DRIVER_MONTHLY | DIM_DEPOT | Obtenu | Conforme ? |
|---|---|---:|---:|---:|---|---|
| V1 | RH_PAIE | 400 | 914 | 3 | 400 / 914 / 3 ; 3 groupes sur 3 OK | Oui — 6 novembre 2026 |
| V2 | RESP_DEPOT_QUEENS | 161, Queens seul | 365, Queens seul | 3 | 161 / 365 / 3 ; Queens seul ; 4 groupes sur 4 OK | Oui — 6 novembre 2026 |
| V3 | RESP_DEPOT_BRONX | 122, Bronx seul | 290, Bronx seul | 3 | 122 / 290 / 3 ; Bronx seul ; 4 groupes sur 4 OK | Oui — 6 novembre 2026 |
| V4 | ANALYSTE | 400 | 914 | 3 | 400 / 914 / 3 ; 3 groupes sur 3 OK | Oui — 6 novembre 2026 |
| V5 | TRANSFORMER | 400 | 914 | 3 | 400 / 914 / 3 ; 6 groupes sur 6 OK (référence incluse) | Oui — 6 novembre 2026 |
| V6 | GOUVERNANCE | Lecture refusée | Lecture refusée | Lecture refusée | Sept refus RH confirmés ; 1 groupe sur 1 OK ; les cellules vides ne représentent pas zéro ligne | Oui — 6 novembre 2026 |
| V7 | ACCOUNTADMIN | 0 | 0 | 3 (héritage propriétaire) | 0 / 0 / 3 ; 5 groupes sur 5 OK | Oui — 6 novembre 2026 |
| V8 | SYSADMIN, absent de la matrice métier | 0 | 0 | 3 (héritage propriétaire) | 0 / 0 / 3 ; 5 groupes sur 5 OK | Oui — 6 novembre 2026 |

Les responsables doivent voir leur dépôt exclusivement dans les deux tables RH ; les trois dépôts restent lisibles dans le référentiel DIM_DEPOT.

### Valeurs du chauffeur témoin et vérification exhaustive

D0003 appartient à Queens et possède trois lignes mensuelles à Queens. Sa naissance pour l’analyste doit devenir le 1er janvier de l’année source. Les valeurs réelles de la source restent locales. TRANSFORMER mémorise des empreintes temporaires de référence en variables de session ; les tests comparent les valeurs sans les afficher.

| N° | Vérification sur D0003 | Attendu | Obtenu | Conforme ? |
|---|---|---|---|---|
| D1 | RH_PAIE : toutes les colonnes et nom mensuel | Identiques à la transformation source | Références initiales conformes ; comparaison indépendante à RAW confirmée par P3 (zéro différence) ; contact de paie réel. Relecture des rôles après reconstruction encore prévue. | Oui — 6 novembre 2026 |
| D2 | Responsable Queens | Identifiant, noms, téléphone et professionnel réels ; e-mail/licence masqués ; naissance NULL | Valeurs et masques conformes aux références, témoin visible à Queens | Oui — 6 novembre 2026 |
| D3 | Responsable Bronx | Aucune ligne, dans les deux tables | Témoin invisible : zéro ligne dimension et mensuel | Oui — 6 novembre 2026 |
| D4 | ANALYSTE | Identifiant réel ; noms/téléphone/e-mail/licence masqués ; année seule ; professionnel réel | Masques, année seule et professionnel conformes aux références | Oui — 6 novembre 2026 |
| D5 | TRANSFORMER | Valeurs complètes conformes à la source | Références initiales conformes ; comparaison indépendante à RAW confirmée par P3 (zéro différence) ; contact de paie réel. Relecture des rôles après reconstruction encore prévue. | Oui — 6 novembre 2026 |
| D6 | Tous les rôles métier | Même comportement sur toutes les lignes de leur périmètre ; NULL préservés | Comparaison de toutes les colonnes sur chaque périmètre conforme, NULL compris | Oui — 6 novembre 2026 |

### Restrictions RAW et STAGING

| N° | Rôle | Attendu | Obtenu | Conforme ? |
|---|---|---|---|---|
| R1 | Chaque rôle métier | SELECT refusé sur les deux RAW et les deux vues STAGING | Quatre rôles métier : quatre sources refusées par rôle ; groupes de restrictions conformes | Oui — 6 novembre 2026 |
| R2 | GOUVERNANCE | SELECT refusé sur les deux RAW et les deux STAGING | Deux RAW et deux STAGING refusés, avec les trois MARTS : sept refus conformes | Oui — 6 novembre 2026 |
| R3 | TRANSFORMER | 400 chauffeurs RAW/STAGING, 25 951 services RAW, 25 933 services STAGING ; valeurs réelles | RAW 400 / 25 951 ; STAGING 400 / 25 933 ; témoin RAW en clair confirmé | Oui — 6 novembre 2026 |
| R4 | ACCOUNTADMIN et SYSADMIN | Les 18 colonnes personnelles RAW masquées ; protections aussi appliquées dans STAGING | Quatre contrôles par administrateur conformes : masques RAW et STAGING | Oui — 6 novembre 2026 |
| R5 | Rôles métier et TRANSFORMER | SELECT sur ACCES_DEPOT refusé ; la politique lit avec les droits de GOUVERNANCE | Cinq refus ACCES_DEPOT conformes : quatre métiers et TRANSFORMER | Oui — 6 novembre 2026 |

Pour R4, le masquage de `shift_id` fusionne les partitions de la vue STAGING de dédoublonnage : le nombre de services vu par l’administrateur peut différer des 25 933 vus par TRANSFORMER. Ce test vérifie les masques, pas le volume de cette vue sous l’administrateur.

### Correspondances, pipeline et rejouabilité

| N° | Vérification | Attendu | Obtenu | Conforme ? |
|---|---|---|---|---|
| P1 | Brooklyn ajouté temporairement à Queens | 278 chauffeurs, 624 lignes mensuelles ; aucun changement de politique | Message confirmé : extension à 278 chauffeurs et 624 lignes mensuelles, sans modification de politique | Oui — 6 novembre 2026 |
| P2 | Correspondance temporaire retirée | Retour à 161 / 365 ; cinq correspondances initiales | Message confirmé : retour à 161 / 365 et cinq correspondances après retrait de Brooklyn | Oui — 6 novembre 2026 |
| P3 | Reconstruction STAGING puis trois MARTS avec TRANSFORMER | Volumes constants, contenu identique avant/après ; noms, contacts et calculs conformes aux sources | Seconde exécution : quatre statuts OK ; dimension et mensuel sans différence avec RAW ; contenu stable et contact réel. Premier ECART conservé dans l’historique. | Oui — 6 novembre 2026 |
| P4 | Catalogue et attachements après reconstruction | 5 tables décrites, 28 colonnes décrites, 38 tags personnels OK ; 27 masquages et 2 filtres attendus | 5 / 5 tables, 28 / 28 colonnes, 5 / 5 tables taguées, 38 / 38 tags personnels et 29 / 29 politiques ; zéro écart dans les cinq contrôles | Oui — 6 novembre 2026 |
| P5 | Deuxième passage des scripts 01 à 04 et des fiches catalogue | Aucun échec, aucune politique détachée, aucune correspondance dupliquée ; tests toujours conformes | Relance et cinq contrôles de métadonnées OK ; relecture après relance : huit rôles, 31 groupes sur 31 OK, mêmes volumes | Oui — 6 novembre 2026 |
| P6 | Droits actuels/futurs, propriété et héritages | Rôles métier sans RAW/STAGING ni rôle privilégié hérité ; aucun SELECT RH pour GOUVERNANCE ; droits catalogue prévus | SHOW GRANTS actuels/futurs et propriétés reçus précédemment ; restrictions de lecture confirmées par la synthèse | Oui — 6 novembre 2026 |
| P7 | Requête de capture identique sous RH_PAIE puis ANALYSTE | Trois groupes par dépôt ; mêmes volumes, masquages différents ; aucune valeur personnelle affichée | PNG examiné : six lignes et compteurs conformes ; recadrer sur le tableau pour exclure bureau, onglets et identifiant de compte avant publication | Partiel — 6 novembre 2026 |

P1/P2 sont dans `test_extension_depot.sql` : le test rétablit les accès même si sa vérification échoue. P3 est dans `verification_pipeline_acces.sql` ; P4 utilise verification_post_pipeline.sql, qui regroupe les descriptions, les tags et les associations ; le contrôle catalogue détaillé reste disponible. `verification_politiques.sql` contrôle chaque attachement et son statut, pas seulement leur nombre.

### Bac à sable — prédictions à lire avant les exemples

Prérequis : exemples 00 puis 01 exécutés dans EXEMPLE_GOUV ; vérifier 6 clients et 5 colonnes taguées. Les résultats de ces exemples ne prouvent pas les accès NYC_TAXI.

| Bloc | Attendu | Obtenu |
|---|---|---|
| 02, attachements (R1) | Cinq colonnes PII protégées : quatre MASK_TEXTE et SCORE/MASK_NOMBRE | Conforme le 6 novembre 2026 : cinq associations transmises |
| 02, pipeline (R2) | Sur C1, valeurs réelles ; total de six lignes à vérifier séparément | Conforme sur C1 le 6 novembre 2026 ; contrôle ultérieur après reconstruction : six clients, CONTROLE_PIPELINE = OK |
| 02, vendeur (R3) | Nom/téléphone réels ; e-mail avec domaine conservé ; score NULL | Conforme sur C1 le 6 novembre 2026 : identifiant et région conservés, masquage e-mail correct, score affiché vide (NULL attendu) |
| 02, analyste (R4) | Identité masquée, identifiant visible ; score C1 arrondi à 700 | Conforme sur C1 le 6 novembre 2026 : nom/téléphone masqués, e-mail partiellement masqué, identifiant/région conservés, score 700 |
| 02, prédicat sur e-mail masqué | COUNT(*) = 0 pour le préfixe personnel réel | Conforme le 6 novembre 2026 : résultat transmis = 0 sous EX_ANALYSTE |
| 03, vendeur | Nord seul, 2 lignes | ÉCART initial le 6 novembre 2026 : Nord 2 et Sud 2 ; contrôle après retrait de Sud conforme (Nord 2 seul). Ordre initial des exécutions non établi |
| 03, analyste | Trois régions, 6 lignes | Conforme le 6 novembre 2026 : Est 2, Sud 2, Nord 2 |
| 03, ajout Sud | Vendeur : Nord et Sud, 4 lignes | Résultat conforme le 6 novembre 2026 : Nord 2 et Sud 2 ; élargissement initial non prouvé puisque le test 1 montrait déjà Sud |
| 03, reconstruction | Toujours six lignes pipeline et mêmes masques analyste | Conforme le 6 novembre 2026 : masques analyste sur C1 au test 4 ; contrôle ultérieur EX_PIPELINE : NB_CLIENTS = 6, CONTROLE_PIPELINE = OK (témoin en clair et score 720) |
| Nettoyage ciblé de Sud | Vendeur revenu à Nord, 2 lignes | Conforme le 6 novembre 2026 : résultat transmis après retrait de Sud = Nord 2, aucune autre région |

Après l’exemple 03, avec EX_GOUVERNANCE : `DELETE FROM EXEMPLE_GOUV.GOUVERNANCE.ACCES_REGION WHERE role_name = 'EX_VENDEUR' AND region = 'Sud';`. Repasser ensuite à EX_VENDEUR avec rôles secondaires désactivés et warehouse EXEMPLE_WH pour vérifier les 2 lignes. Pour rejouer l’ensemble, reprendre 00, 01, 02, 03 : le vendeur peut déjà être filtré par le 03 précédent pendant le 02.

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

### Recueil des preuves

Après chaque bloc, transmettre son identifiant, ses statuts et les quantités agrégées. Conserver les messages de refus sans nom d’utilisateur. Ne remplir « obtenu » et ne cocher les tests qu’après observation. Capture prévue : `docs/acces_comparaison_roles.png`, obtenue avec `capture_acces.sql`, sans noms, coordonnées ni identifiants de chauffeur. Premiers résultats reçus le 6 novembre 2026 : R1 à R4 de l’exemple 02, consignés ci-dessus. Prédicat e-mail confirmé ensuite : COUNT(*) = 0 sous EX_ANALYSTE. Résultats de l’exemple 03 reçus : test 1 en écart, test 2 conforme, résultat du test 3 conforme sans preuve de transition, masques de C1 conformes au test 4. Retour à Nord seul confirmé ensuite après retrait de Sud : deux lignes, aucune autre région. Contrôle EX_PIPELINE ensuite reçu : NB_CLIENTS = 6 et CONTROLE_PIPELINE = OK, confirmant le volume, le témoin en clair et son score réel après reconstruction. Vérifications du bac à sable terminées sur ces résultats ; tous les tests NYC_TAXI restent à confirmer. Les valeurs nominatives du témoin ne sont pas recopiées.

### Vérification locale de la préparation — 6 novembre 2026

Contrôle hors Snowflake réussi : 264 évaluations des corps SQL de masque sur 11 rôles et trois valeurs par type (dont NULL), via SQLite et équivalents de fonctions ; prédicat de lignes évalué contre les volumes issus des CSV, avec extension/restauration de Brooklyn ; dix scénarios sur la requête de comparaison des métadonnées, dont politiques manquantes, doublons, mauvais statut ou argument de filtre. Cohérence des 38 tags, des 27 masques et des 2 filtres, variables de session, requêtes de capture identiques et copies des transformations contrôlées. Ces vérifications n’exécutent ni le moteur Snowflake, ni ses DDL, ni ses droits : les résultats métier NYC_TAXI restent à confirmer dans Snowsight ; les premiers résultats du bac à sable sont consignés séparément ci-dessus.
