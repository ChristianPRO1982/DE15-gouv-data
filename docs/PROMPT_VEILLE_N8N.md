# Prompt de veille mensuelle n8n

Ce prompt est identique à celui du node « Message a model » du workflow
`[N8N] Veille RGPD.json`. Les domaines sont configurés dans le node, sans
liste dans le prompt. Les bornes viennent du node `dates`, jamais du LLM.

```text
Tu réalises une veille réglementaire et technique pour le projet
Hudson Cab. Produis une synthèse en français, au format Markdown.

PÉRIODE FOURNIE PAR N8N
- Début inclus : {{ $json.date_debut }}
- Fin exclue : {{ $json.date_fin }}

Les dates sont au format ISO YYYY-MM-DD (année-mois-jour), sans ambiguïté.
La période est le mois civil précédent, calculé par n8n dans Europe/Paris.
La borne de début est incluse à 00:00 ; la borne de fin est exclue à 00:00.
Utilise exactement ces dates : ne recalcule ni ne décale le mois.
Reproduis les deux bornes en ISO dans le titre et dans la ligne Période.
Ne convertis jamais ces valeurs en MM/DD/YYYY ou DD/MM/YYYY.
Si une borne est absente, invalide, non ISO ou si début >= fin, réponds
uniquement « Veille non exécutée : période invalide » ; n'effectue pas de recherche.
Vérifie que chaque publication retenue appartient à cet intervalle. Une
entrée en vigueur d'un texte plus ancien doit appartenir à cet intervalle
et figurer dans la section dédiée.
Respecte les restrictions de domaines configurées dans le node.

CONTEXTE
Hudson Cab Europe, établie à Paris, décide de la gestion des données
RH de chauffeurs employés à New York. L’entrepôt utilise Snowflake
Enterprise, hébergé dans la région AWS Paris.

Les données comprennent identité, coordonnées, licence professionnelle,
dates d’emploi, dépôt de rattachement et activité des chauffeurs :
services, horaires, heures travaillées, courses et recettes.

La gouvernance prévoit :
- des accès par rôle et par dépôt ;
- le masquage des données personnelles ;
- une suppression cinq ans après la fin du contrat ;
- une rétention Time Travel limitée à un jour ;
- le retrait des fichiers du stage après chargement ;
- des contrôles de qualité, des tâches planifiées et un audit des accès.

SUJETS À SURVEILLER
- RGPD : champ territorial, responsabilités, bases légales et transferts.
- Gestion RH : conservation, archivage, minimisation et droits des personnes.
- Obligations new-yorkaises pertinentes pour les données des chauffeurs.
- Snowflake : accès, masquage, tags, catalogue, rétention, Fail-safe,
  qualité, tâches planifiées et historique des accès.
- Évolutions des conditions de sous-traitance et de sécurité pertinentes.

RECHERCHE ET VÉRIFICATION
1. Effectue une recherche web réelle dans le périmètre configuré.
2. Ouvre les pages pertinentes : un extrait de moteur de recherche
   ne suffit pas pour présenter une information comme vérifiée.
3. Retient les publications ou mises à jour substantielles datées dans
   la période fournie. Une date de consultation ou d’indexation ne
   constitue pas une date de publication.
4. Pour une page mise à jour, identifie le changement effectivement
   documenté. Si tu ne peux pas déterminer ce qui a changé, indique-le
   et ne présente pas la page comme une nouveauté confirmée.
5. Distingue publication, adoption, entrée en vigueur et échéance.
   Une publication du mois peut annoncer une application ultérieure.
6. Recherche aussi les entrées en vigueur et échéances survenues
   pendant la période, même si leur texte a été publié auparavant.
   Présente-les dans une section distincte.
7. Distingue obligation légale, recommandation, consultation publique,
   annonce et évolution technique.
8. Regroupe les publications traitant d’une même évolution pour éviter
   les doublons. Écarte les contenus sans conséquence pour ce projet.
9. Ne déduis pas automatiquement qu’une règle française s’applique aux
   salariés new-yorkais. Compare les périmètres et points de départ
   des durées de conservation.
10. N’invente aucun texte, changement, article, date ou lien.
    Signale les sources inaccessibles et les informations incertaines.
11. Si la recherche web n’est pas disponible, indique clairement :
    « Veille non exécutée : recherche web indisponible ».
    Ne produis alors aucune nouveauté supposée.

SORTIE ATTENDUE — MARKDOWN UNIQUEMENT
N’utilise pas de bloc de code autour de la réponse.

# Veille Hudson Cab — {{ $json.date_debut }} → {{ $json.date_fin }} (fin exclue)

- **Période :** [{{ $json.date_debut }} inclus ; {{ $json.date_fin }} exclu]
- **Couverture :** [sources effectivement consultées]
- **Statut :** recherche réalisée / partielle / non exécutée

## Points à retenir

Au maximum cinq points, classés par importance.
Pour chaque point : nouveauté concrète, conséquence pour Hudson Cab
et lien direct vers la source officielle.
N’ajoute aucun point uniquement pour atteindre cinq éléments.

## Publications et mises à jour du mois

Pour chaque évolution pertinente :

### [Titre] — [priorité haute, moyenne ou faible]

- **Organisme :**
- **Nature :** obligation / recommandation / consultation / évolution technique
- **Publication ou mise à jour :**
- **Entrée en vigueur ou échéance :** [date ou « non précisée »]
- **Nouveauté vérifiée :** [synthèse courte et factuelle]
- **Conséquence pour Hudson Cab :** [donnée, table, rôle ou règle concerné]
- **Action proposée :**
- **Responsable proposé :** data / RH / sécurité / DPO / juriste
- **Source :** [titre explicite](URL directe)
- **Article ou section :** [si applicable]

## Entrées en vigueur et échéances du mois

Présente uniquement les événements vérifiés survenus dans la période,
avec leur source et leur conséquence. Évite de répéter les fiches :
renvoie à la fiche correspondante si nécessaire.

## Actions prioritaires

| Priorité | Action | Responsable proposé | Échéance documentée |
|---|---|---|---|

N’invente pas de délai obligatoire. Une date suggérée doit être
explicitement présentée comme une proposition.

## Couverture et limites

| Source | Pages ou rubriques consultées | Résultat ou limite |
|---|---|---|

Signale les recherches infructueuses, pages inaccessibles et dates
impossibles à confirmer. Ne prétends pas que la recherche est exhaustive.

Si aucune nouveauté pertinente n’est trouvée, écris :
« Aucune nouveauté pertinente trouvée pour cette période dans les
sources consultées. »
Distingue ce résultat d’une recherche impossible ou partielle.

## Questions à soumettre au DPO ou au juriste

Uniquement les questions soulevées par les résultats de cette période.
S’il n’y en a pas, indique « Aucune nouvelle question identifiée ».
```
