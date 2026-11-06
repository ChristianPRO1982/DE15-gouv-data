# Les accès — carte des droits et cahier de tests

Préparé à partir du modèle le 3 novembre 2026. Carte complétée le 4 novembre 2026 à partir des scripts ; déploiement et droits effectifs à vérifier dans Snowsight ; les tests attendus seront écrits au jour 2 avant les politiques. Aucun résultat « obtenu » n’est encore disponible.

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
| Attacher une politique de masquage à un tag | `GOUVERNANCE` | Propriété du tag + privilège global APPLY MASKING POLICY | `ACCOUNTADMIN` ; attachement jour 2 |
| Ajouter une politique d'accès par ligne à une table | `GOUVERNANCE` | APPLY ROW ACCESS POLICY sur le compte, accès base/schéma | `ACCOUNTADMIN` ; attachement jour 2 |
| Écrire une ligne dans `QUALITE_RESULTATS` | `TRANSFORMER` | INSERT sur la table, USAGE sur base/schéma | `GOUVERNANCE` ; SELECT également accordé pour contrôler |
| Lire `DIM_DRIVER` | `TRANSFORMER` ; rôles métier prévus jour 2 | Propriété ou SELECT, USAGE base/schéma et warehouse | Propriété TRANSFORMER ; droits métier à créer jour 2 |
| Exécuter une requête | chaque rôle | USAGE warehouse et droits sur objets visés | `ACCOUNTADMIN` pour NYC_TAXI_WH |
| Créer la future vue de catalogue | `TRANSFORMER` | CREATE VIEW et USAGE sur GOUVERNANCE ; accès aux sources | `GOUVERNANCE` |

### Ce que cette carte permet à un rôle de défaire

`TRANSFORMER`, propriétaire des tables et autorisé à appliquer les tags, peut retirer un tag et compromettre le futur masquage par tag. `GOUVERNANCE` peut changer les règles ou les détacher avec ses privilèges globaux ; il ne reçoit aucun SELECT sur RAW, STAGING ou MARTS, ni aucun rôle de lecture en héritage. Les administrateurs peuvent changer les droits : les futures politiques doivent aussi tester leur lecture.

Ces pouvoirs sont nécessaires au montage pédagogique ; l’audit des lectures et changements reste à mettre en place au jour 3. Les droits métier et les politiques ne sont pas créés à cette étape. Contrôler `SHOW GRANTS TO ROLE GOUVERNANCE` avec ACCOUNTADMIN, y compris les éventuels rôles hérités préexistants ; `CREATE IF NOT EXISTS` ne supprime pas d’anciens droits.

Sources vérifiées le 4 novembre 2026 : [privilèges Snowflake](https://docs.snowflake.com/en/user-guide/security-access-control-privileges), [gestion des tags](https://docs.snowflake.com/en/user-guide/object-tagging/work). Résultats de `01_gouvernance.sql` reçus et conformes le 4 novembre 2026 : propriétés du schéma, des trois tags et de QUALITE_RESULTATS, droits globaux de GOUVERNANCE, droits de TRANSFORMER sur les tags, les résultats et la création de vues. Aucun SELECT RH ni rôle de lecture hérité dans les attributions fournies de GOUVERNANCE ; NB_MESURES = 0. Contrôle global du catalogue reçu le 6 novembre 2026 : conforme (5 tables décrites, 28 colonnes décrites, 18 tags personnels OK) ; propriétés TRANSFORMER sur les cinq tables et les deux vues STAGING confirmées. Attribution de GOUVERNANCE à l’utilisateur testeur confirmée, aucun identifiant personnel recopié. Rejouabilité et capture encore attendues.

---



**Rejouabilité de l’installation de gouvernance confirmée le 6 novembre 2026 :** après relance de `snowflake/gouvernance/01_gouvernance.sql`, le titulaire transmet les trois tags avec leurs dates de création initiales et les valeurs autorisées inchangées, la structure conforme de QUALITE_RESULTATS, les propriétaires et droits attendus pour GOUVERNANCE et TRANSFORMER, puis NB_MESURES = 0. Cette relance est validée sur ces résultats ; la conservation de mesures préexistantes n’est pas testée puisque la table est vide. La relance des cinq fiches, le nouveau contrôle global et la capture restent à confirmer.

**Clôture des vérifications de l’étape 4 le 6 novembre 2026 :** après relance des scripts, le titulaire confirme aucune description manquante, 5 tables décrites sur 5, 28 colonnes décrites sur 28 et 18 tags personnels OK sur 18. Capture `docs/tags_dim_driver.png` examinée et export complet `docs/tags_dim_driver.csv` vérifié. Rejouabilité confirmée sur ces résultats. L’écart de taxonomie professionnelle reste à clarifier ; aucune politique métier n’est validée par ces contrôles.

**Extension autorisée le 6 novembre 2026 — état actuel :** le titulaire accepte `donnee_professionnelle`. Cette décision remplace le maintien de l’écart dans les états précédents. Tag existant, quatre fiches, inventaire et contrôle global adaptés localement : 20 affectations supplémentaires, 38 attendues au total. Déploiement et contrôle Snowflake restent à confirmer ; la case de taggage intégral reste ouverte jusqu’à réception des 38 statuts OK. Après validation, actualiser les preuves DIM_DRIVER (12 tags personnels, 36 références au total).

**Extension appliquée — confirmation du titulaire le 6 novembre 2026 :** tous les scripts passent et le contrôle affiche les quantités attendues : 5 tables, 28 colonnes et 38 lignes pour les tags personnels. Les deux propriétés du tag ont été modifiées par des ALTER TAG séparés. La case de taggage intégral est cochée sur cette confirmation. Le classement professionnel est désormais appliqué ; le contrat pédagogique reste inchangé, l’adaptation étant documentée. Le titulaire confirme ici la réussite et les quantités ; aucun nouveau tableau détaillé des statuts n’a été transmis. Les preuves PNG/CSV conservées décrivent l’ancien état de DIM_DRIVER (7 tags personnels, 31 références) et restent à actualiser pour l’extension (12 tags personnels, 36 références).

**Preuves renouvelées vérifiées le 6 novembre 2026 :** `docs/tags_dim_driver.csv` contient 36 références : 12 DONNEE_PERSONNELLE, 12 DUREE_CONSERVATION et 12 SENSIBILITE. Les cinq affectations donnee_professionnelle attendues sont présentes sur DEPOT, HIRE_DATE, END_DATE, IS_ACTIVE et TENURE_YEARS. La capture `docs/tags_dim_driver.png` renouvelée est lisible, affiche 36 lignes au total et montre la nouvelle catégorie sur les premières lignes. Elle complète le CSV intégral. Ces preuves remplacent les anciens fichiers à 31 références. Étape 4 terminée avec l’extension de taxonomie autorisée par le titulaire et documentée, sans modification du contrat fourni.

## Partie 2 — Cahier de tests

Décidez d'abord à quoi ressemble une valeur masquée pour chaque type de colonne (texte, date) et notez-le ici : ______. Puis remplissez en deux temps : la colonne « attendu » **avant** d'écrire les politiques, à partir de la matrice du contrat ; la colonne « obtenu » après, en exécutant la requête avec le rôle indiqué (`USE ROLE ...`).

Un test est vert quand « obtenu » est identique à « attendu ». Un accès refusé (`Object does not exist or not authorized`) est un résultat comme un autre : écrivez-le.

### Lignes visibles

| N° | Rôle | Requête | Attendu | Obtenu | Vert ? |
|---|---|---|---|---|---|
| 1 | `RH_PAIE` | `SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER` | | | |
| 2 | `RESP_DEPOT_QUEENS` | la même | | | |
| 3 | `RESP_DEPOT_QUEENS` | `SELECT DISTINCT depot FROM NYC_TAXI.MARTS.DIM_DRIVER` | | | |
| 4 | `RESP_DEPOT_BRONX` | `SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY` | | | |
| 5 | `ANALYSTE` | `SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER` | | | |
| 6 | `GOUVERNANCE` | la même | | | |
| 7 | `ACCOUNTADMIN` | la même | | | |
| 8 | `RH_PAIE` | `SELECT COUNT(*) FROM NYC_TAXI.RAW.DRIVER_SHIFTS` | | | |
| 9 | `ANALYSTE` | `SELECT COUNT(*) FROM NYC_TAXI.RAW.DRIVERS` | | | |
| 9 bis | `ACCOUNTADMIN` | `SELECT first_name, email FROM NYC_TAXI.RAW.DRIVERS LIMIT 3` | | | |

### Valeurs visibles

Pour le chauffeur `D0003`, la valeur que chaque rôle doit lire dans chaque colonne (ou « colonne absente », ou « ligne invisible »).

| Colonne | `RH_PAIE` | `RESP_DEPOT_QUEENS` | `RESP_DEPOT_BRONX` | `ANALYSTE` |
|---|---|---|---|---|
| nom et prénom | | | | |
| e-mail | | | | |
| téléphone | | | | |
| date de naissance | | | | |
| numéro de licence | | | | |
| `driver_name` dans `MART_DRIVER_MONTHLY` | | | | |

### Le pipeline fonctionne toujours

| N° | Vérification | Attendu | Obtenu | Vert ? |
|---|---|---|---|---|
| 10 | Avec le rôle des outils, après avoir relancé les fichiers SQL : nombre de lignes de `DIM_DRIVER` | | | |
| 11 | Avec `RH_PAIE` : l'e-mail de `D0003` est toujours une vraie adresse | | | |
| 12 | Les politiques sont toujours attachées après la relance (requête de la section 7 du contrat) | | | |

Ajoutez vos propres tests : un cahier qui ne contient que des tests verts dès le premier essai n'a probablement pas cherché les cas limites.
