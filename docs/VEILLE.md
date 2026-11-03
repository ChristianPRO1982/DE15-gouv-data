# Note de veille réglementaire et technique — Hudson Cab

**Première recherche :** 3 novembre 2026 (Europe/Paris)

**Période examinée :** textes de référence en vigueur et documentation accessibles au 03/11/2026 ; recherche non exhaustive, sans point de comparaison antérieur.

**Périmètre :** traitement RH fictif de chauffeurs new-yorkais, piloté depuis Paris dans Snowflake Enterprise, AWS Paris (`AWS_EU_WEST_3`).

**État :** analyse documentaire et propositions uniquement ; aucune politique Snowflake exécutée, aucun abonnement ou rappel activé, aucune validation juridique.

Cette note reprend le livrable de la première recherche réalisée par le titulaire dans ChatGPT web le 3 novembre 2026. Le compte rendu exporté est conservé dans [resultat_chatgpt.md](resultat_chatgpt.md) ; les prompts réutilisables sont dans [PROMPT_VEILLE.md](PROMPT_VEILLE.md). Relecture ciblée dans cette session : référentiel CNIL RH du 2 avril 2026, NY Labor Law §195(4) et DPA public Snowflake. Les mentions de consultation du journal d’origine décrivent la recherche ChatGPT rapportée ; elles ne signifient pas que toutes les sources ont été intégralement revérifiées lors de cette relecture. La capture de la conversation reste à fournir.

## 1. Droit applicable et qualification des acteurs

### 1.1 Champ territorial : RGPD article 3

- **Article 3 §1 — applicable dans le scénario fourni.** Hudson Cab Europe est une filiale établie à Paris qui décide désormais des finalités et moyens de gestion des données RH. Le traitement est donc réalisé dans le cadre des activités d'un établissement européen du responsable, y compris lorsque les personnes concernées travaillent à New York. L'emplacement AWS Paris ne crée ni ne supprime à lui seul ce rattachement.
- **Article 3 §2 — pas le fondement retenu.** Il cible les traitements de personnes se trouvant dans l'Union par des responsables/sous-traitants non établis dans l'Union, en lien avec une offre de biens/services ou un suivi comportemental dans l'Union. Ces critères ne décrivent pas les faits fournis.
- **Article 2 §1 — champ matériel.** Chargement, stockage, transformations, consultation, accès et purge sont des traitements automatisés de données personnelles. La nationalité des chauffeurs est sans effet sur le critère d'établissement de l'article 3 §1.

**Sources vérifiées :** règlement (UE) 2016/679 du 27 avril 2016, articles 2, 3 et 4, reproduit par la CNIL (page du 23/05/2016 ; rectificatif JOUE du 23/05/2018) : https://www.cnil.fr/fr/reglement-europeen-protection-donnees/chapitre1 ; CEPD, *Lignes directrices 3/2018 sur le champ d'application territorial*, version 2.0 adoptée le 12/11/2019, § critère d'établissement et exemple 4 : https://www.edpb.europa.eu/sites/default/files/files/file1/edpb_guidelines_3_2018_territorial_scope_after_public_consultation_en.pdf . **Consulté le 03/11/2026.** La page EUR-Lex du règlement a été tentée mais a présenté un contrôle anti-robot, donc elle n'est pas déclarée lue intégralement : https://eur-lex.europa.eu/legal-content/FR/TXT/?uri=CELEX:32016R0679 .

### 1.2 Qui décide, qui exécute ?

| Acteur | Qualification de travail | Motif / limite |
|---|---|---|
| **Hudson Cab Europe (Paris)** | **Responsable du traitement présumé** (art. 4 §7, 24) | Le brief lui attribue les finalités et moyens de gestion ; à corroborer par les délégations et accords intragroupe. |
| **Hudson Cab Partners (New York)** | Employeur et fournisseur de données ; rôle juridique à **qualifier** | Ne pas le considérer d'office comme simple sous-traitant : sa maîtrise de la paie, des obligations d'employeur et des finalités peut en faire un responsable distinct ou un responsable conjoint pour certaines opérations (art. 26). |
| **Snowflake** | Sous-traitant du client pour les *Customer Personal Data* (art. 4 §8, 28) | Le DPA public Snowflake décrit cette qualité. Vérifier la version contractuelle acceptée, les entités signataires, sous-traitants ultérieurs et mesures de sécurité. |
| **AWS et autres intervenants** | Sous-traitants ultérieurs possibles | Vérifier la liste contractuelle applicable ; ne pas déduire les intervenants réels de la seule désignation AWS Paris. |
| **Équipe data, Priya, rôles Snowflake** | Personnes habilitées / identités techniques, pas « responsables du traitement » par leur seul rôle SQL | Les fonctions SQL ne suffisent pas à qualifier juridiquement les acteurs. |
| **CNIL** | Autorité française de contrôle pertinente (art. 55) | Autorité chef de file **possible** si un traitement transfrontalier au sens du RGPD et un établissement principal/unique français sont démontrés (art. 4 §16, 56). Ne pas présumer automatiquement l'existence d'un traitement transfrontalier européen au seul motif que des chauffeurs sont aux États-Unis. |

**Sources vérifiées :** RGPD art. 4, 24, 26, 28 et 30, https://www.cnil.fr/fr/reglement-europeen-protection-donnees/chapitre4 ; art. 55–56, https://www.cnil.fr/fr/reglement-europeen-protection-donnees/chapitre6 ; Snowflake, *Data Processing Addendum*, mise à jour affichée **11/01/2026**, sections 3, 4 et 5, https://www.snowflake.com/en/legal/addenda/data-processing-addendum/ . Consulté le 03/11/2026.

### 1.3 Base légale, finalité et registre

Les finalités « administration RH », « paie », « planification des services », « analyses opérationnelles » et « conservation probatoire » doivent être distinguées. Déterminer pour chacune une base de l'article 6 §1 avant la mise en production (contrat, obligation légale, intérêt légitime selon les faits) ; ne pas postuler un consentement salarié. Documenter catégories, destinataires, durées, localisation, transferts et garanties dans `docs/REGISTRE.md` (art. 30). Vérifier les modalités d'information des chauffeurs (art. 13 ou 14), la gestion de leurs droits et le besoin éventuel d'une AIPD (art. 35). Les données de prises de service pourraient servir au contrôle individuel d'activité : le référentiel CNIL « gestion courante du personnel » **exclut de son périmètre** les traitements ayant pour objet ou effet le contrôle individuel des salariés ; ne pas appliquer ses tableaux sans précaution à cette finalité.

**Sources :** RGPD art. 5, 6, https://www.cnil.fr/fr/reglement-europeen-protection-donnees/chapitre2 ; art. 13–14, https://www.cnil.fr/fr/reglement-europeen-protection-donnees ; art. 30 et 35, https://www.cnil.fr/fr/reglement-europeen-protection-donnees/chapitre4 ; CNIL, *Référentiel relatif aux traitements de données à caractère personnel mis en œuvre aux fins de gestion du personnel*, adopté le **21/11/2019**, sections 1–4 et 7, https://www.cnil.fr/sites/cnil/files/atoms/files/referentiel_grh_novembre_2019_0.pdf ; CNIL, *Le registre des activités de traitement*, page datée du **13/04/2018**, https://www.cnil.fr/fr/RGPD-le-registre-des-activites-de-traitement . Consultés le 03/11/2026.

## 2. Dispositif de veille durable

| Organisme officiel / outil documentaire | Sujets surveillés | Fréquence proposée | Qui effectue / décide |
|---|---|---|---|
| **CNIL** — https://www.cnil.fr/fr/actualites ; flux annoncé https://www.cnil.fr/fr/rss.xml | RH, conservation, archivage, sécurité, fiches pratiques, décisions | Chaque lundi 9h (Paris), et chaque jour du brief | Porteur `chris/`, relecture du binôme ; DPO/juriste pour l'interprétation |
| **CEPD / EDPB** — https://www.edpb.europa.eu/news/news_fr ; documents https://www.edpb.europa.eu/our-work-tools/our-documents_fr | Lignes directrices, recommandations, consultations, transferts hors EEE | Idem | Porteur ; DPO/juriste |
| **EUR-Lex / Légifrance** — https://eur-lex.europa.eu/ ; https://www.legifrance.gouv.fr/ | Modifications du RGPD, rectificatifs, droit du travail français **si pertinent** | Idem | Porteur ; juriste |
| **Snowflake** — https://docs.snowflake.com/en/release-notes ; https://docs.snowflake.com/en/user-guide/data-time-travel | Time Travel, Fail-safe, RBAC, masquage, audit, tâches, évolution DPA | Idem | Porteur ; responsable technique |
| **New York State Senate / NY Attorney General** — https://www.nysenate.gov/legislation/laws/LAB/195 ; https://ag.ny.gov/resources/organizations/data-breach-reporting/shield-act | Paie, conservation des preuves, sécurité, violations | Idem | Porteur ; conseil juridique américain |

**Outil retenu :** ChatGPT web avec recherche web, relancé manuellement. Une première recherche est désormais fournie dans `resultat_chatgpt.md` et dans cette note ; elle ne constitue pas un abonnement.

**Procédure :** ouvrir les publications officielles, comparer aux fiches précédentes, noter date de publication, date d'effet lorsqu'elle existe, catégorie (obligation / recommandation / consultation / annonce technique), impact sur tables et politiques, décision et propriétaire, puis consigner l'issue dans un journal. En cas d'absence d'évolution : « aucune évolution pertinente trouvée dans les sources consultées », jamais « aucune évolution juridique ». Une trouvaille ancienne n'est pas une nouveauté de la semaine.

**Preuves / activation :** aucune souscription RSS, newsletter ou tâche automatique n'a été réalisée dans cette conversation. Le lien RSS CNIL est identifié mais son contenu XML n'a pas pu être ouvert par l'outil de consultation web (type MIME `application/rss+xml` non pris en charge) : tester dans un lecteur RSS, activer l'abonnement et capturer sa confirmation. ChatGPT web est uniquement un **outil de revue manuelle** dans cette configuration ; une capture des citations d'une conversation prouve une consultation, **pas** un abonnement. Le brief requiert une capture d'abonnement : utiliser une souscription officielle réelle ou faire valider explicitement l'adaptation par le formateur.

## 3. Fiches de veille

### Fiche 1 — Application territoriale du RGPD

- **Source / date :** Parlement européen et Conseil, règlement (UE) 2016/679, **27/04/2016**, art. 2–4, rectificatif du **23/05/2018** ; CNIL https://www.cnil.fr/fr/reglement-europeen-protection-donnees/chapitre1 ; CEPD, lignes directrices 3/2018, version finale **12/11/2019**, https://www.edpb.europa.eu/sites/default/files/files/file1/edpb_guidelines_3_2018_territorial_scope_after_public_consultation_en.pdf . Consultation : 03/11/2026.
- **Synthèse (3 phrases) :** Le critère de l'article 3 §1 concerne un traitement dans le cadre des activités d'un établissement européen. L'article 3 §2 repose sur un autre critère, visant des organismes non établis dans l'Union qui proposent des biens/services à des personnes dans l'Union ou y suivent leur comportement. Le CEPD confirme qu'un traitement de personnes hors UE peut relever du paragraphe 1.
- **Conséquence :** classer les données de `RAW.DRIVERS`, `RAW.DRIVER_SHIFTS`, `MARTS.DIM_DRIVER` et `MARTS.MART_DRIVER_MONTHLY` selon leur caractère personnel, documenter finalités/acteurs et appliquer la gouvernance RGPD.
- **Action : À faire** — `docs/REGISTRE.md` ; validation DPO.

### Fiche 2 — Limitation de conservation, base active et archivage

- **Source / date :** RGPD art. 5 §1 e, https://www.cnil.fr/fr/reglement-europeen-protection-donnees/chapitre2 (texte de 2016 et rectificatif 2018) ; CNIL, *Les durées de conservation des données*, page datée du **02/04/2026**, https://www.cnil.fr/fr/passer-laction/les-durees-de-conservation-des-donnees ; référentiel CNIL RH **21/11/2019**, section 7, https://www.cnil.fr/sites/cnil/files/atoms/files/referentiel_grh_novembre_2019_0.pdf . Consultation : 03/11/2026.
- **Synthèse :** La durée dépend de la finalité et d'éventuelles obligations particulières, sans limite uniforme imposée par le RGPD. Des données sorties de la base active peuvent être conservées en archivage intermédiaire lorsqu'un motif le justifie, avec accès restreint. Le référentiel RH illustre des durées selon les pièces et les activités, sans les rendre universelles.
- **Conséquence :** distinguer visibilité opérationnelle et archivage des données dans `RAW`, `MARTS` et les copies ; documenter une durée par finalité et par type de preuve.
- **Action : À signaler / à faire** — DPO, RH, responsable de la gouvernance.

**Complément vérifié lors de la relecture du 03/11/2026 :** la CNIL a publié un [référentiel des durées de conservation RH le 2 avril 2026](https://www.cnil.fr/fr/referentiel-durees-conservation-donnees-rh), qui complète le référentiel de 2019. Il vise les personnels soumis au droit du travail français et distingue les recommandations des durées imposées par les textes qu’il recense. Utiliser cette source plus récente pour préparer la grille de conservation, tout en faisant qualifier le droit applicable aux chauffeurs new-yorkais.

### Fiche 3 — Registre unique français et conservation des justificatifs à New York

- **Source / date :** Légifrance, Code du travail, **art. R1221-26**, en vigueur depuis le **29/10/2015**, affiché en vigueur au **03/11/2026**, https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000031392972 ; New York State Senate, *Labor Law §195(4), Notice and record-keeping requirements*, version affichée du **02/10/2020**, https://www.nysenate.gov/legislation/laws/LAB/195 . Consultation : 03/11/2026.
- **Synthèse :** Le délai français de cinq ans porte sur les mentions du registre unique du personnel après le départ. La section 195(4) de New York prescrit une conservation d'au moins six ans de certains relevés contemporains de paie, notamment les heures travaillées par semaine. La qualification des documents Hudson Cab et l’articulation des droits doivent être confirmées par le juriste ; six ans pour les relevés ne signifient pas six ans après le départ du salarié.
- **Conséquence :** les six ans de conservation des relevés et les cinq ans après départ du contrat ont des points de départ distincts : un conflit n’est pas automatique. Comparer les dates d’expiration document par document ; ne pas effacer sans examen les données ayant valeur de justificatif de paie (`shift_date`, `hours_worked`, identifiants de rapprochement) ; envisager un archivage étroitement habilité distinct des `MARTS` actifs.
- **Action : À signaler — priorité élevée** au juriste français et au conseil américain.

### Fiche 4 — Sécurité, confidentialité, sous-traitance

- **Source / date :** RGPD art. 25, 28, 32, https://www.cnil.fr/fr/reglement-europeen-protection-donnees/chapitre4 ; Snowflake, *Data Processing Addendum*, actualisé le **11/01/2026**, sections 3–5, https://www.snowflake.com/en/legal/addenda/data-processing-addendum/ . Consultation : 03/11/2026.
- **Synthèse :** L'accès est limité au besoin et la sécurité s'adapte au risque. Un traitement confié à un sous-traitant doit être encadré par un contrat conforme à l'article 28. Le DPA public décrit Snowflake comme sous-traitant pour les données du client, sans prouver la version applicable au compte de l'exercice.
- **Conséquence :** vérifier la matrice `RH_PAIE`, `RESP_DEPOT_*`, `ANALYSTE`, `GOUVERNANCE`, `ACCOUNTADMIN`, et le rôle `TRANSFORMER` ; contrôler DPA, sous-traitants et habilitations.
- **Action : À faire / à signaler** — technique, sécurité et DPO.

### Fiche 5 — Time Travel, Fail-safe et fichiers de stage

- **Source / date :** Snowflake, documentation officielle *Understanding & using Time Travel* https://docs.snowflake.com/en/user-guide/data-time-travel ; *Understanding and viewing Fail-safe* https://docs.snowflake.com/en/user-guide/data-failsafe ; *Storage costs for Time Travel and Fail-safe* https://docs.snowflake.com/en/user-guide/data-cdp-storage-costs ; commande *REMOVE* https://docs.snowflake.com/en/sql-reference/sql/remove . **Date de publication/mise à jour non affichée** sur les pages consultées ; consultation 03/11/2026.
- **Synthèse :** Un `DATA_RETENTION_TIME_IN_DAYS` de 1 limite en principe les récupérations par Time Travel à une journée, sous réserve des paramètres de rétention minimum, des anciens objets détruits et des traitements asynchrones. Les tables permanentes conservent ensuite une fenêtre Fail-safe de sept jours ; les tables transient n'en ont pas. `REMOVE` permet de retirer les fichiers du stage, sans remplacer une politique de purge des données chargées.
- **Conséquence :** vérifier le type et les paramètres effectifs de **chaque** table et copie, les objets détruits, le stage et les reconstructions ; distinguer inaccessibilité métier et fin de rétention historique.
- **Action : À faire / à signaler** — responsable technique et DPO.

### Fiche 6 — Transfert hors EEE et accès distants

- **Source / date :** RGPD art. 44–46, https://www.cnil.fr/fr/reglement-europeen-protection-donnees/chapitre5 ; CEPD, *Guidelines 05/2021 on interplay between Article 3 and Chapter V*, version 2.0 **adoptée le 14/02/2023**, page publiée le **24/02/2023**, https://www.edpb.europa.eu/documents/guideline/guidelines-052021-on-the-interplay-between-the-application-of-article-3-and-the_fr ; texte PDF officiel https://www.edpb.europa.eu/system/files/2023-02/edpb_guidelines_05-2021_interplay_between_the_application_of_art3-chapter_v_of_the_gdpr_v2_en_0.pdf . Consultation : 03/11/2026.
- **Synthèse :** L'hébergement à Paris n'exclut pas la mise à disposition à un acteur hors EEE. Pour caractériser un transfert au sens du CEPD, il faut notamment une communication à un responsable ou sous-traitant **distinct** situé dans un pays tiers. L'accès à l'étranger par le salarié du **même responsable du traitement** n'est pas automatiquement un transfert Chapitre V, tout en restant soumis à l'analyse des risques.
- **Conséquence :** inventorier les comptes et bénéficiaires aux États-Unis, la qualité juridique du destinataire, les accès de support et les garanties de transfert si requises.
- **Action : À signaler** — DPO et responsable sécurité, avant accès de Hudson Cab Partners aux données gérées à Paris.

### Fiche 7 — Droit de New York : exigences de sécurité

- **Source / date :** Office of the New York Attorney General, *SHIELD Act*, loi signée le **25/07/2019**, https://ag.ny.gov/resources/organizations/data-breach-reporting/shield-act ; consultation 03/11/2026.
- **Synthèse :** Le SHIELD Act prévoit des garanties raisonnables administratives, techniques et physiques pour les « private information » couvertes. La notion locale de « private information » n'est pas identique à la notion large de donnée personnelle du RGPD. La présence d'un numéro de licence TLC ne suffit pas, sans analyse, à l'assimiler automatiquement au numéro de permis de conduire visé par certaines dispositions.
- **Conséquence :** documenter les contrôles d'accès, l'audit et les procédures incident ; qualifier séparément les données couvertes par la loi locale.
- **Action : À signaler** au juriste américain / sécurité.

## 4. Confrontation exhaustive du contrat aux sources

**Légende :** « compatible sous conditions » signifie que la règle peut contribuer à une mesure utile, **pas** que sa conformité est certifiée. Les seuils chiffrés de qualité sont des choix du brief, **pas** des seuils fixés par le RGPD.

| Règle du contrat | Texte / article ou documentation | Appréciation justifiée | Écart ou limite | Proposition sans réécriture du contrat | Destinataire décision |
|---|---|---|---|---|---|
| **R1** Suppression 5 ans après fin de contrat, partout | RGPD 5 §1 e ; CNIL durée/archivage ; FR R1221-26 ; NY Labor Law §195(4) | **À arbitrer** ; 5 ans n'est pas une règle générale RGPD | Archivage intermédiaire absent ; relevés de paie éventuellement soumis à 6 ans à New York, avec un point de départ distinct des 5 ans après départ ; conflit non automatique | Demander validation d'une grille de conservation et d'un archivage séparé, restreint ; purge active de toutes les copies inutiles | DPO + juristes FR/US + direction |
| **R2** Time Travel ≤ 1 jour | RGPD 5 §1 e, 32 ; Snowflake Time Travel / Fail-safe | **Conforme à l'objectif technique Time Travel seulement si effectif** | Fail-safe 7 jours pour tables permanentes ; min rétention, objets détruits, clones, long-running queries | Relever rétention effective et type par objet ; mesurer les délais de récupération ; étudier transient selon risque et besoin de récupération | Responsable technique + DPO |
| **R3** Retrait du fichier du stage | RGPD 5 §1 c/e, 25, 32 ; Snowflake REMOVE | **Compatible** | Retrait du stage ≠ effacement du RAW, des copies amont ni prévention d'un réimport | Purge vérifiable du stage après chargement et inventaire des autres copies ; valider les sources amont | Responsable technique + sécurité |
| **Matrice : RH_PAIE** tout en clair et tous dépôts | RGPD 5 §1 c, 25, 32 | **Sous justification** | « Tout » peut excéder le besoin réel de la paie (`birth_date`, TLC, téléphone, recettes) | Vérifier nécessité colonne par colonne, limiter aux tâches paie et tracer | RH + DPO |
| **Matrice : RESP_DEPOT_QUEENS / RESP_DEPOT_BRONX** | RGPD 5 §1 c, 25, 32 ; Snowflake row access | **Compatible sous conditions** | Les données des autres dépôts doivent être inaccessibles, y compris via agrégations et tables dérivées ; accès au téléphone à justifier | Contrôler `GOUVERNANCE.ACCES_DEPOT`, filtrage et masquage, tester permissions effectives | Responsables de dépôt + DPO |
| **Matrice : ANALYSTE** `driver_id` + année de naissance, toutes lignes | RGPD 4 §1/5, 5 §1 c, 25 ; CNIL RH portée §2 | **Compatible avec l’absence d’identification directe, sans anonymisation garantie** | `driver_id` reste une donnée personnelle/pseudonyme ; croisement `depot`, dates et services peut réidentifier ; analyses individuelles potentiellement hors référentiel RH | Ne pas qualifier le résultat d'anonyme ; privilégier statistiques agrégées / vue dédiée, seuils d'agrégation si besoin ; valider finalité | DPO + métier data |
| **Matrice : TRANSFORMER** accès technique nécessaire | RGPD 5 §1 c, 25, 32 | **Compatible sous conditions** | Compte technique étendu, dépendances et possibles exports ; besoin d'un contrôle des secrets | Principe du moindre privilège et journal d'exécution, pas de lecture humaine injustifiée | Responsable technique + sécurité |
| **Matrice : GOUVERNANCE et ACCOUNTADMIN** aucune donnée en clair | RGPD 25, 32 ; RBAC Snowflake | **Objectif pédagogique valide, garantie absolue non prouvée** | Privilèges administratifs, rôles secondaires, possibilités de modifier droits/politiques et copies peuvent contourner un simple test `SELECT` | Séparation des tâches, contrôle des grants, test du rôle actif et secondaire, audit des modifications, procédure break-glass | Sécurité + DPO |
| **Matrice : `driver_id` visible et rôle absent sans ligne** | RGPD 4 §1/5, 25, 32 ; row access Snowflake | **Sous conditions** | `driver_id` est un identifiant personnel ; un rôle absent ne doit pas pouvoir hériter d'autres privilèges d'accès | Tag `identifiant_interne`, vérifier héritage des rôles et accès via vues/CTAS | Gouvernance + sécurité |
| **Tags imposés** `DONNEE_PERSONNELLE` | RGPD art. 4 §1, 5 §1 c ; inventaire dans `REGISTRE.md` | **Taxonomie à clarifier** | Les six valeurs du contrat ne couvrent pas explicitement toutes les données professionnelles indirectes (dates d’emploi, horaires, recettes, rattachement) | Maintenir un inventaire exhaustif ; demander clarification au formateur, sans inventer de valeur SQL ni étendre l’exception de visibilité de `driver_id` à toutes ces colonnes | Formateur + référent gouvernance |
| **`licence_unique`** zéro conflit | RGPD 5 §1 d ; obligation qualité du contrat | **Utile et cohérente** | Doublons exacts vs formats divergents, valeurs NULL | Normaliser / distinguer absent et doublon ; documenter définitions d'anomalie | RH + data owner |
| **`telephone_renseigne`** ≤ 5 % manquant chez actifs | RGPD 5 §1 d, 5 §1 c | **Choix métier, pas norme RGPD** | Téléphone nécessaire ? seuil 5 % arbitraire et dénominateur à définir | Définir « actif » via `end_date`, vérifier nécessité métier et seuil | RH + DPO |
| **`email_valide`** contient `@` | RGPD 5 §1 d ; qualité contractuelle | **Contrôle minimal insuffisant pour prouver la validité** | Un `@` ne garantit ni syntaxe, ni livrabilité, ni propriété | Présenter comme contrôle de forme rudimentaire ; établir contrôles proportionnés et éviter vérifications intrusives | RH + data owner |
| **`dates_coherentes`** embauche ≤ aujourd'hui, fin ≥ embauche | RGPD 5 §1 d | **Utile** | Horodatages historiques, fuseaux horaires, données à date future intentionnelles selon procédure | Spécifier date métier, gestion NULL et dates futures planifiées | RH + data owner |
| **`depot_connu`** valeurs Bronx/Brooklyn/Queens | RGPD 5 §1 d ; périmètre du brief | **Utile dans ce jeu de données** | Exhaustivité du référentiel et évolutions des dépôts | Relier à `DIM_DEPOT`, journaliser valeurs non reconnues, prévoir évolutivité | Exploitation + data owner |
| **`service_rattache`** ≤ 50 services orphelins, bloquant | RGPD 5 §1 d, 32 ; contrat pédagogique | **Alerte utile, seuil non légal** | 50 services orphelins peuvent créer des analyses fausses ; possible orphelin issu de purge légitime d'un chauffeur | Mesurer taux et volume, distinguer erreurs d'ingestion et purge légitime, revue du seuil et arrêt documenté de reconstruction | Data owner + direction |
| **`service_unique`** zéro doublon de `shift_id` | RGPD 5 §1 d | **Utile** | Même identifiant avec données divergentes ; rechargements rejouables | Définir clé d'unicité et déduplication traçable | Data owner |
| **`duree_plausible`** ≤ 16 h | RGPD 5 §1 d ; qualité du contrat | **Contrôle métier, pas seuil RGPD** | Durées négatives, nulles ou manquantes non couvertes ; 16 h ≠ validation réglementaire du temps de travail | Ajouter cohérence minimale et faire confirmer règles de temps de travail par RH/US | RH + juriste US |

**Sources communes de lecture :** [RGPD principes (art. 5–6)](https://www.cnil.fr/fr/reglement-europeen-protection-donnees/chapitre2), [RGPD responsabilités, privacy by design, sécurité (art. 24, 25, 28, 32)](https://www.cnil.fr/fr/reglement-europeen-protection-donnees/chapitre4), [RGPD définitions (art. 4)](https://www.cnil.fr/fr/reglement-europeen-protection-donnees/chapitre1), [CNIL conservation (02/04/2026)](https://www.cnil.fr/fr/passer-laction/les-durees-de-conservation-des-donnees), [Code du travail R1221-26](https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000031392972), [NY Labor Law §195(4)](https://www.nysenate.gov/legislation/laws/LAB/195), [Snowflake Time Travel](https://docs.snowflake.com/en/user-guide/data-time-travel), [Snowflake Fail-safe](https://docs.snowflake.com/en/user-guide/data-failsafe), [Snowflake column security (CTAS)](https://docs.snowflake.com/en/user-guide/security-column-intro). Consultés le 03/11/2026.

## 5. Points techniques déterminants à expliquer à l'oral

1. **Base active ≠ archives intermédiaires.** Le départ d'un chauffeur devrait déclencher une revue des usages : dépublication / retrait des `MARTS` opérationnels dès que les finalités cessent, puis archivage des seuls justificatifs dont la conservation est justifiée, avec séparation logique ou physique et accès spécialisé. La loi française des cinq ans sur le registre unique ne s'étend pas automatiquement à un contrat new-yorkais ; le droit de New York doit être examiné indépendamment.
2. **`driver_id` et pseudonymisation.** `driver_id` et `shift_id` rattachables au chauffeur sont personnels. Le seul masquage des noms, un hash déterministe ou la seule année de naissance ne garantit pas l'anonymat ; la clé de correspondance et les combinaisons `depot` / dates / services comptent.
3. **Rejeu et réimport complet.** Si l'on réimporte le CSV d'origine, on peut réintroduire des salariés déjà supprimés. Une politique d'ingestion doit exclure les enregistrements expirés *avant leur exposition*, avec règles de décision pour les justificatifs devant être archivés ; puis purger les copies courantes correspondantes, laisser expirer les historiques selon les mécanismes Time Travel/Fail-safe et recontrôler les tables aval. Prévoir le traitement des erreurs de `end_date` et des données amont remises en cause. Un mécanisme de tombstones/purge registry **sans donnée nominative excessive** peut empêcher la résurrection, mais exige sa propre durée et justification.
4. **Time Travel / Fail-safe.** Un jour de Time Travel effectif ne supprime pas les sept jours de Fail-safe des tables permanentes, ni d'autres copies ; pour une table transient, aucun Fail-safe, avec perte de capacité de récupération. Une modification de la durée de rétention ne garantit pas l'effacement immédiat des données historiques : des opérations de fond et objets supprimés peuvent subsister. Les délais sont ceux des fonctions de récupération et rétention décrites par Snowflake, pas un « délai de suppression RGPD » universel.
5. **Pipeline et protections.** Snowflake indique que CTAS applique les règles de masquage en amont mais ne recopie pas automatiquement les mêmes politiques aux colonnes de la nouvelle table ; les scripts qui reconstruisent `MARTS` doivent reposer les politiques/tags ou conserver la structure protégée. Une requête exécutée avec un rôle autorisé à lire en clair peut créer une copie non masquée si elle est ensuite exposée sans politique : sécuriser le rôle technique, tester les grants et les politiques **après** reconstruction.
6. **International.** La région AWS Paris ne suffit pas à exclure des accès depuis New York ou par des prestataires hors EEE. D'après le CEPD, distinguer les accès des propres employés d'un responsable depuis un pays tiers et ceux d'une société distincte qui reçoit accès en tant que responsable/sous-traitant. Qualifier les flux avant de choisir les garanties du chapitre V.
7. **Traçabilité.** `SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY` est disponible sur Enterprise, avec une latence documentée pouvant aller jusqu'à 3 heures et une rétention d'un an ; croiser avec `QUERY_HISTORY` pour le rôle. La trace d'accès à des objets/colonnes ne prouve pas à elle seule le contenu exact vu par la personne ni chaque ligne effectivement lue : démontrer aussi les politiques et tests d'accès.

**Références Snowflake :** [Column-level Security — CTAS](https://docs.snowflake.com/en/user-guide/security-column-intro), [ACCESS_HISTORY](https://docs.snowflake.com/en/sql-reference/account-usage/access_history), [ACCOUNT_USAGE](https://docs.snowflake.com/en/sql-reference/account-usage), [Time Travel](https://docs.snowflake.com/en/user-guide/data-time-travel), [Fail-safe](https://docs.snowflake.com/en/user-guide/data-failsafe), [REMOVE](https://docs.snowflake.com/en/sql-reference/sql/remove). Consultées le 03/11/2026.

## 6. Écarts et limites à reporter dans `README.md`

1. **R1 à arbitrer :** délai unique de cinq ans après le départ non déduit du RGPD ; absence de distinction base active / archives ; articulation à vérifier avec la conservation des justificatifs de paie selon le droit de New York, en comparant les points de départ et dates d’expiration, sans conclure à un conflit automatique. Pas de modification du contrat sans validation.
2. **R2 limitée :** un jour de Time Travel n'équivaut pas à un effacement historique au bout d'un jour sur table permanente (Fail-safe sept jours, copies et objets dérivés à considérer).
3. **R3 incomplète à elle seule :** stage vide après `REMOVE` ne traite pas les données déjà chargées ou les fichiers conservés en amont.
4. **Accès non équivalents à anonymat :** `driver_id` reste une donnée personnelle ; réidentification possible par recoupements ; justification métier des colonnes RH et de la consultation des services.
5. **Rejeu non sécurisé par la seule purge :** un réimport intégral peut ressusciter les données supprimées ; reconstructions et copies doivent être protégées et auditées.
6. **Sécurité admin :** objectif de lecture masquée pour ACCOUNTADMIN à prouver dans le cadre de tests de rôle ; ne pas prétendre à une impossibilité absolue d'accès d'un administrateur privilégié.
7. **Qualité :** huit seuils contractuels utiles à l'exercice, non prescrits par la loi ; seuil 50 orphelins et vérification `@` à justifier fonctionnellement.
8. **Conformité documentaire non démontrée :** DPA applicable, rôles intragroupe, base légale, transferts, information des chauffeurs et éventuelle AIPD encore à vérifier.
9. **Taxonomie :** les valeurs de tag du contrat ne couvrent pas explicitement toutes les données professionnelles indirectes ; clarification nécessaire sans changer unilatéralement le contrat.
10. **Veille :** ChatGPT manuel ne satisfait pas à lui seul la capture d'un abonnement demandée ; preuve d'un flux officiel à fournir ou dérogation pédagogique à obtenir.

## 7. Questions à transmettre au juriste / DPO

- Hudson Cab Partners garde-t-elle la maîtrise d'une finalité RH/paie ? Faut-il un accord de responsabilité conjointe (art. 26), une relation responsable–sous-traitant, ou des responsables séparés selon les flux ?
- Quelles bases légales s'appliquent précisément à la paie, à l'affectation en dépôt, à l'analyse des recettes individuelles et à l'archivage ? Quelle information délivrer aux chauffeurs ?
- Les données de service de Hudson Cab remplissent-elles une fonction de justificatif de paie au titre de New York Labor Law §195(4) ? Quelles autres obligations TLC, fiscales ou contentieuses s'appliquent réellement ?
- À partir de quelle date et selon quel délai chaque catégorie doit-elle quitter la base active, passer éventuellement en archivage intermédiaire, puis être effacée ? Quel cadre pour les sauvegardes / Fail-safe ?
- L'analyse mensuelle individuelle pourrait-elle servir à un contrôle d'activité du personnel ? Le traitement nécessite-t-il une AIPD ou des garanties supplémentaires ?
- Quels accès sont effectivement accordés à des entités ou prestataires basés hors EEE ? Sur quelle garantie juridique repose tout transfert pertinent (adéquation, clauses contractuelles types, etc.) ?
- Quel DPA Snowflake a effectivement été accepté dans ce compte d'essai ? Quelles sous-traitances et clauses relatives à l'effacement s'appliquent ?
- Quelle protection durable après rechargement et quelle politique pour les données déjà supprimées qui réapparaîtraient dans un fichier source complet ?
- **Au formateur / référent gouvernance :** comment taguer les données professionnelles indirectes sans catégorie adaptée dans les six valeurs imposées ?
- Qui valide la grille des droits, la définition de « besoin d'en connaître » des responsables de dépôt et le besoin de données identifiantes pour l'analyste ?

**Responsables d'arbitrage :** DPO/juriste pour le droit et les transferts ; RH et direction pour finalités, catégories et durées ; sécurité et responsable Snowflake pour les mesures techniques. Le binôme **recommande et documente**, ne valide pas juridiquement.

## 8. Journal des sources effectivement consultées — 03/11/2026

| Organisme | Source (lien ouvert) | Date source affichée | Section consultée | Résultat / limite |
|---|---|---|---|---|
| CNIL (texte RGPD) | https://www.cnil.fr/fr/reglement-europeen-protection-donnees/chapitre1 | Page 23/05/2016 ; rectificatif 23/05/2018 | Art. 2–4 | Disponible ; champ territorial et définitions vérifiés |
| CNIL (texte RGPD) | https://www.cnil.fr/fr/reglement-europeen-protection-donnees/chapitre2 | Texte initial 2016 ; rectificatif 2018 | Art. 5–6 | Disponible ; finalités, minimisation, exactitude et conservation |
| CNIL (texte RGPD) | https://www.cnil.fr/fr/reglement-europeen-protection-donnees/chapitre4 | Texte initial 2016 ; rectificatif 2018 | Art. 24, 25, 26, 28, 30, 32, 35 | Disponible ; rôle, contrat, sécurité, registre |
| CNIL (texte RGPD) | https://www.cnil.fr/fr/reglement-europeen-protection-donnees/chapitre5 | Texte initial 2016 ; rectificatif 2018 | Art. 44–46 | Disponible ; transferts |
| CNIL (texte RGPD) | https://www.cnil.fr/fr/reglement-europeen-protection-donnees/chapitre6 | Texte initial 2016 ; rectificatif 2018 | Art. 55–56 | Disponible ; autorités |
| EUR-Lex | https://eur-lex.europa.eu/legal-content/FR/TXT/?uri=CELEX:32016R0679 | RGPD 27/04/2016 | Tentative d'ouverture | **Inaccessible à lecture directe** : contrôle anti-robot ; texte croisé avec publication CNIL, pas de certification exhaustive des versions et rectificatifs |
| CEPD | https://www.edpb.europa.eu/documents/guideline/guidelines-32018-on-the-territorial-scope-of-the-gdpr-article-3-version-adopted_fr | 12/11/2019 (version finale) | Page de publication ; PDF anglais 2.0 accessible | PDF français renvoie une erreur 429 ; PDF anglais officiel consulté https://www.edpb.europa.eu/sites/default/files/files/file1/edpb_guidelines_3_2018_territorial_scope_after_public_consultation_en.pdf |
| CEPD | https://www.edpb.europa.eu/documents/guideline/guidelines-052021-on-the-interplay-between-the-application-of-article-3-and-the_fr | Page 24/02/2023 ; texte adopté 14/02/2023 | Page et PDF anglais version finale | Disponible, critères de transfert et exceptions d'accès par salarié |
| CNIL | https://www.cnil.fr/sites/cnil/files/atoms/files/referentiel_grh_novembre_2019_0.pdf | 21/11/2019 | Sections 1–4, 7, tableau p. 11 | Disponible, PDF ouvert et pages pertinentes examinées |
| CNIL | https://www.cnil.fr/fr/passer-laction/les-durees-de-conservation-des-donnees | 02/04/2026 | Base active, archives, effacement | Disponible ; publication plus récente que référentiel de 2019 |
| CNIL — complément de relecture | https://www.cnil.fr/fr/referentiel-durees-conservation-donnees-rh | 02/04/2026 | Présentation, portée et articulation avec le référentiel GRH | Page vérifiée lors de la relecture du 03/11/2026 ; complément au référentiel 2019 |
| Légifrance | https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000031392972 | En vigueur depuis 29/10/2015, page au 03/11/2026 | Art. R1221-26 | Disponible ; portée au registre unique du personnel français |
| Sénat de New York | https://www.nysenate.gov/legislation/laws/LAB/195 | Version affichée du 02/10/2020 | §195(4) | Disponible ; conservation des documents de paie ≥ 6 ans |
| NY Attorney General | https://ag.ny.gov/resources/organizations/data-breach-reporting/shield-act | Loi signée 25/07/2019 ; date de page non indiquée | Information générale SHIELD Act | Disponible ; critères locaux à qualifier |
| Snowflake | https://www.snowflake.com/en/legal/addenda/data-processing-addendum/ | Mis à jour 11/01/2026 | Sect. 3–5 | Disponible ; version contractuelle du compte non vérifiée |
| Snowflake | https://docs.snowflake.com/en/user-guide/data-time-travel | Non indiquée | Retention, minimum account, objets détruits | Disponible |
| Snowflake | https://docs.snowflake.com/en/user-guide/data-failsafe | Non indiquée | Fail-safe, 7 jours | Disponible |
| Snowflake | https://docs.snowflake.com/en/user-guide/data-cdp-storage-costs | Non indiquée | Table permanente vs transient | Disponible |
| Snowflake | https://docs.snowflake.com/en/sql-reference/sql/remove | Non indiquée | Fichiers de stage | Disponible |
| Snowflake | https://docs.snowflake.com/en/user-guide/security-column-intro | Non indiquée | CTAS et masking policies | Disponible |
| Snowflake | https://docs.snowflake.com/en/sql-reference/account-usage/access_history | Non indiquée | Historique des accès | Disponible |
| CNIL RSS | https://www.cnil.fr/fr/rss.xml | Non vérifiée | Tentative de lecture | **Type XML/RSS non pris en charge par le lecteur web** ; abonnement non réalisé |

**Vérification des versions :** le rectificatif RGPD du 23/05/2018 a été relevé sur le texte de la CNIL ; la consultation directe EUR-Lex n'ayant pas abouti, aucune prétention à la vérification exhaustive de l'ensemble des rectificatifs ou amendements postérieurs. Les lignes directrices CEPD 3/2018 (2018 : consultation ; 2019 : version adoptée) et 05/2021 (2021 : consultation ; 2023 : version adoptée) sont distinguées de textes légalement contraignants. La page CNIL du 02/04/2026 et le DPA Snowflake du 11/01/2026 sont des mises à jour disponibles, **pas** des preuves qu'une nouvelle obligation est entrée en vigueur ce jour-là.

### Ligne du journal de veille

`2026-11-03 | Première analyse | RGPD art. 3 §1 confirmé ; R1 (5 ans) et R2 (Fail-safe) à arbitrer ; NY Labor Law §195(4) et DPA Snowflake 2026 ajoutés au périmètre ; aucun abonnement activé | Équipe data : documenter ; DPO/juristes : arbitrer | Prochaine revue proposée : lundi 2026-11-09 à 09:00 Europe/Paris (à confirmer dans le binôme).`

### Pièces de preuve à créer hors de cette note

- Capture réelle de la recherche web avec la date et les sources/citations (ex. `docs/veille_chatgpt_2026-11-03.png`), après masquage des informations du compte.
- Capture séparée de **l'abonnement effectivement activé** à une source officielle, ou trace écrite de l'acceptation de l'adaptation par le formateur.
- `docs/REGISTRE.md` et `docs/ACCES.md` complétés à partir des implémentations et tests réellement exécutés ; aucune exécution Snowflake prétendue ici.
