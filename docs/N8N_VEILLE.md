# Veille n8n — dates et validation

Correction locale du 2026-11-03. Fichier à importer : `[N8N] Veille RGPD.json`.
Le prompt exporté est également disponible dans [PROMPT_VEILLE_N8N.md](PROMPT_VEILLE_N8N.md).

## Période retenue

Le workflow recherche les nouveautés du **mois civil précédent**, et non celles des 32 derniers jours. Le fuseau du workflow et celui du node `currentDate` sont `Europe/Paris`.

Le node `currentDate` capture une seule date/heure ISO. Le node `dates` la convertit avec Luxon, calcule le premier jour du mois courant et le premier jour du mois précédent, puis produit deux dates `YYYY-MM-DD`. Les anciens nodes de formatage américain et de soustraction de 32 jours sont retirés. Les déclencheurs manuel et mensuel passent par le même calcul.

| Instant d’exécution | Début inclus | Fin exclue | Mois couvert |
|---|---|---|---|
| 2026-11-03, heure de Paris | 2026-10-01 | 2026-11-01 | Octobre 2026 |
| 2026-12-01 à 07:00 Paris | 2026-11-01 | 2026-12-01 | Novembre 2026 |
| 2027-01-01 à 07:00 Paris | 2026-12-01 | 2027-01-01 | Décembre 2026 |
| 2028-03-01 à 07:00 Paris | 2028-02-01 | 2028-03-01 | Février bissextile |

La fin exclue représente le premier jour du mois suivant à 00:00 Paris : ce jour ne doit pas être inclus dans les publications retenues. Les dates de publication et d’entrée en vigueur restent distinguées dans le rapport. Aucune date d’exécution supplémentaire n’est injectée dans le prompt.

Planification explicite : une fois par mois, le 1er à 07:00, fuseau Paris. Le décalage UTC suit le changement d’heure. L’objet Outlook reprend les deux bornes du node `dates`.

## Premier e-mail reçu

`Veille RGPD.msg` conserve le contenu du premier essai. Ses dates visibles et celles de son aperçu ont été normalisées en ISO : **2026-02-10 inclus à 2026-03-11 exclu**, période réellement traitée par le LLM. Les dates des publications ont également été converties en ISO ; les métadonnées de transport du message restent inchangées. Il ne faut pas le renommer ou modifier ses dates pour le présenter comme une veille d’octobre ; ses sources ont été sélectionnées pour une autre période. Le nouveau rapport devra résulter d’une nouvelle recherche.

## Vérifications après import dans n8n

1. Importer l’export corrigé ou reporter les modifications dans le workflow existant ; vérifier les credentials locaux.
2. Vérifier le fuseau `Europe/Paris`, la planification mensuelle et les deux chemins vers `currentDate → dates → Message a model`.
3. Exécuter seulement `currentDate` puis `dates` pour contrôler les bornes sans lancer de recherche ni envoyer de message.
4. Contrôler le prompt résolu : dates ISO présentes, début antérieur à fin, aucun `undefined`, aucun format avec `/`.
5. Lancer ensuite une exécution complète et vérifier que le titre, la ligne Période et l’objet Outlook reprennent exactement ces bornes. Vérifier les dates et sources des nouveautés retenues avant d’intégrer le rapport au journal.
6. Conserver la preuve de réussite et l’e-mail daté ; publier/activer le workflow dans n8n pour les exécutions planifiées.

L’export local est **désactivé**. Aucun appel au modèle, envoi Outlook ou changement de l’instance n8n n’a été effectué lors de cette correction. La validation locale porte sur le JSON et les connexions ; l’évaluation des expressions Luxon dans le moteur n8n reste à confirmer après import.

Références techniques : [dates et Luxon dans n8n](https://docs.n8n.io/build/work-with-data/handle-special-data-types/work-with-dates-and-times.md), [Schedule Trigger](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.scheduletrigger/).
