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

Sources vérifiées le 4 novembre 2026 : [privilèges Snowflake](https://docs.snowflake.com/en/user-guide/security-access-control-privileges), [gestion des tags](https://docs.snowflake.com/en/user-guide/object-tagging/work). Résultats de `01_gouvernance.sql` reçus et conformes le 4 novembre 2026 : propriétés du schéma, des trois tags et de QUALITE_RESULTATS, droits globaux de GOUVERNANCE, droits de TRANSFORMER sur les tags, les résultats et la création de vues. Aucun SELECT RH ni rôle de lecture hérité dans les attributions fournies de GOUVERNANCE ; NB_MESURES = 0. Le contrôle du catalogue reste à exécuter.

---

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
