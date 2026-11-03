# Veille réglementaire et technique — Hudson Cab

Première analyse du 3 novembre 2026 · RGPD, CNIL, CEPD, droit français et Snowflake

## 1. Premières conclusions vérifiées

L'analyse confirme que le contrat pédagogique constitue une base de travail, mais qu'il ne suffit pas à démontrer une conformité RGPD.

Trois conclusions sont particulièrement importantes pour ta présentation orale.

Le RGPD s'applique bien au traitement. Le fondement pertinent est l'article 3, paragraphe 1 : Hudson Cab Europe est établie à Paris et décide, selon le brief, des finalités et des moyens du traitement. Le paragraphe 2 ne constitue pas le fondement principal, puisqu'il concerne les traitements réalisés par des organismes non établis dans l'Union, dans les conditions prévues par cet article. La nationalité des chauffeurs et la localisation AWS Paris ne déterminent pas, à elles seules, l'applicabilité du règlement.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://www.cnil.fr\&sz=32)

CNIL+1



R1 — La suppression cinq ans après le départ nécessite une justification. Le RGPD n'impose pas une durée universelle de cinq ans. Cette durée apparaît notamment à l'article R.1221-26 du Code du travail français pour les mentions du registre unique du personnel, mais il faut vérifier si cette obligation concerne les salariés new-yorkais. La CNIL distingue aussi la conservation en base active de l'archivage intermédiaire.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://www.cnil.fr\&sz=32)

CNIL+2



R2 — Un jour de Time Travel ne signifie pas une disparition physique après un jour. Dans une table permanente Snowflake, sept jours de Fail-safe s'ajoutent normalement au délai de Time Travel. Pour un délai d'un jour, on arrive donc à environ huit jours de conservation historique, sans compter d'éventuelles autres copies. Les tables transient n'ont pas de Fail-safe, mais présentent des compromis de récupération des données.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://docs.snowflake.com\&sz=32)

Snowflake Documentation+1



Ces deux dernières questions doivent figurer parmi les écarts à signaler dans le README, sans modification unilatérale du contrat.

## 2. Un point supplémentaire : le droit new-yorkais

La recherche a fait apparaître un élément important qui n'était pas explicité dans le contrat : la section 195(4) du New York Labor Law impose généralement aux employeurs concernés de conserver certains documents de paie pendant au moins six ans.

Cela ne signifie pas automatiquement que toutes les colonnes de `RAW.DRIVERS` et `RAW.DRIVER_SHIFTS` doivent être conservées six ans. En revanche, les champs `hours_worked`, `shift_date` et les identifiants permettant de rapprocher les services des chauffeurs méritent une analyse : s'ils participent aux documents de paie légalement requis, leur suppression ne peut pas être décidée en ignorant cette obligation.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://www.nysenate.gov\&sz=32)

NYSenate.gov+1



Il faudra donc distinguer la durée de conservation des données d'exploitation, celle des justificatifs de paie et celle des éventuelles archives.

Autre source récente vérifiée : le Data Processing Addendum de Snowflake affiche une mise à jour au 11 janvier 2026. Il précise le rôle de Snowflake comme sous-traitant pour les données de ses clients et prévoit notamment l'encadrement des sous-traitants ultérieurs. Il reste nécessaire de vérifier quelle version contractuelle s'applique réellement au compte Hudson Cab.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://www.snowflake.com\&sz=32)

Snowflake+1



## 3. Livrable prêt pour le dépôt GitHub

Télécharger VEILLE.md

Note Markdown · 202 lignes · prête à intégrer dans `docs/`

Le document comprend :

- 7 fiches de veille sourcées, dont une consacrée au droit new-yorkais.
- La confrontation de R1, R2, R3, de la matrice d'accès et des 8 règles de qualité.
- Les limites techniques concernant les données pseudonymisées, le réimport, Time Travel et Fail-safe.
- Les écarts à reporter dans `README.md`, les questions juridiques et un journal daté des sources consultées.
- Une proposition de veille hebdomadaire, avec répartition des responsabilités.

Limites de cette première exécution : EUR-Lex a bloqué la lecture directe du règlement ; son contenu a été recoupé avec la publication officielle de la CNIL. La recherche ne constitue pas une vérification juridique exhaustive.

Le contrat de gouvernance n'a pas été modifié. Aucun test Snowflake, abonnement ou rappel n'a été exécuté.

Il reste deux preuves à produire personnellement dans ton environnement : la capture réelle de cette recherche dans ChatGPT web et celle d'un abonnement officiel effectivement activé, afin de satisfaire complètement au critère C4 du brief.

La prochaine revue proposée est le lundi 9 novembre 2026 à 9 h, heure de Paris, sous réserve de confirmation dans ton binôme.