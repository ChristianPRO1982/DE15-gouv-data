# Veille avec ChatGPT web — mode d’emploi et prompts

Préparé le 3 novembre 2026. Outil choisi par le titulaire : ChatGPT web. Utiliser la recherche web et ouvrir les références pour vérifier les conclusions ; les citations apparaissent lorsque ChatGPT utilise la recherche ([documentation officielle OpenAI](https://learn.chatgpt.com/docs/web-search)).

## Documents à joindre

- **Indispensables pour la première analyse** : `brief/Snowflake+Gouvernance/BRIEF.md` (contexte de Paris et New York) et `CONTRAT_GOUVERNANCE.md` (règles à confronter).
- **Utiles** : `exemples/FICHE_JURIDIQUE.md`, `brief/Snowflake+Gouvernance/RESSOURCES.md` et `docs/VEILLE_MODELE.md` pour le format attendu. Ce sont des supports pédagogiques, pas des sources de droit.
- **Pour les mises à jour** : joindre aussi la dernière version de `docs/VEILLE.md` et le compte rendu de veille précédent, afin de comparer les résultats.
- **Inutiles pour la veille juridique** : les deux CSV RH, les secrets de connexion, les captures du compte Snowflake et les résultats de requêtes nominatives. L’inventaire sans valeurs nominatives dans `docs/REGISTRE.md` suffit pour comprendre les catégories de données.

## Prompt initial à copier

```text
Tu m’aides à réaliser une veille technique et réglementaire pour un brief
d’école de Data Engineer. Réponds en français, avec des explications que je
pourrai défendre à l’oral. Effectue une recherche web réelle avant de rédiger.
Si tu ne peux pas naviguer, indique cette limite et ne présente pas de
référence comme vérifiée.

CONTEXTE
Hudson Cab Partners emploie des chauffeurs à New York. Hudson Cab Europe,
filiale établie à Paris, porte l’entrepôt Snowflake et l’équipe data et
décide désormais des finalités et moyens de gestion de ces données.
Le compte Snowflake du projet est en édition Enterprise, région AWS Paris
(AWS_EU_WEST_3). Les CSV d’exercice sont fictifs ; on raisonne comme pour un
vrai fichier RH. Je joins le brief et le contrat. Le contrat est une exigence
pédagogique à examiner, pas une preuve de conformité juridique.

MÉTHODE ET SOURCES
1. Indique la date réelle de la recherche et la période couverte.
2. Utilise des sources primaires : EUR-Lex pour le RGPD, CNIL, CEPD/EDPB,
   Légifrance pour les textes français et documentation officielle Snowflake
   pour les contraintes techniques. Pour le droit américain, utilise les
   autorités officielles compétentes et sépare cette analyse du RGPD.
3. Ouvre les pages citées. Pour chaque affirmation juridique importante,
   donne à proximité un lien direct, le titre, l’organisme, l’article ou la
   section, la date de publication/mise à jour si indiquée et la date de
   consultation. N’invente aucune date, citation ni URL. Signale les pages
   inaccessibles et les points que tu ne peux pas vérifier.
4. Cherche les versions en vigueur et les textes plus récents que les liens
   fournis dans le brief. Sépare publication, entrée en vigueur, recommandation,
   consultation publique et texte obligatoire. Vérifie les rectificatifs.
5. Distingue faits du brief, règles des textes, recommandations et tes
   déductions. N’affirme pas que les sources consultées sont exhaustives.

TRAVAIL ATTENDU
A. Explique le champ territorial du RGPD : compare les paragraphes 1 et 2 de
   l’article 3 et justifie celui qui s’applique ici, indépendamment de la
   nationalité des chauffeurs et de la région de stockage.
B. Identifie responsable du traitement, sous-traitant et autorité de contrôle
   à partir des faits et des articles pertinents ; expose les hypothèses.
C. Propose un dispositif durable avec au moins trois organismes officiels,
   sujets suivis, fréquence hebdomadaire et responsable fonctionnel. ChatGPT
   web sert à une revue relancée manuellement ; ne prétends pas avoir créé
   un abonnement, une notification ou une tâche sans preuve de son activation.
D. Rédige au moins quatre fiches. Pour chacune : source et date, synthèse en
   trois phrases maximum, conséquence concrète sur les tables/colonnes/rôles
   de l’entrepôt et action (à faire / à signaler / aucune).
E. Confronte chaque règle du contrat : R1 cinq ans après départ, R2 Time Travel
   un jour, R3 retrait des fichiers du stage, matrice des accès et chacune
   des huit règles de qualité. Tableau : règle | texte/article | appréciation
   justifiée | écart ou limite | proposition | destinataire de la décision.
F. Examine particulièrement : base active et archivage intermédiaire,
   justification par finalité, portée française du registre unique du personnel,
   données professionnelles indirectement identifiantes, pseudonymisation,
   Time Travel et Fail-safe, réimport d’un fichier complet après purge,
   contrat de sous-traitance et éventuels accès depuis un pays hors EEE.
G. Termine par les écarts à reporter au README, les questions pour le juriste
   ou le DPO et un journal des sources effectivement consultées.

Ne modifie pas le contrat et ne produis pas de code ni de résultat de test
Snowflake. Ne confonds pas proposition technique et mesure déjà appliquée.
```

## Prompt pour la revue hebdomadaire

```text
Reprends le contexte, les exigences de sources et la méthode du prompt initial.
Je joins la note de veille et le dernier compte rendu.
Dernière revue : [DATE À RENSEIGNER]. Date de cette revue : [DATE DU JOUR].
Recherche réellement les publications et évolutions sur cette période auprès
de la CNIL, du CEPD/EDPB, d’EUR-Lex/Légifrance et de Snowflake. Pour chaque
source, indique ce qui a été consulté et les limites de recherche.
Ne présente pas une ancienne publication découverte aujourd’hui comme une
nouveauté juridique ; signale-la séparément comme complément de couverture.
Pour chaque évolution pertinente : titre, organisme, lien direct vérifié,
date de publication, date d’effet si connue, article/section, changement par
rapport à la note jointe, conséquence pour Hudson Cab, priorité, action et
personne chargée de décider. Si aucune évolution pertinente n’est trouvée,
écris « aucune évolution pertinente trouvée dans les sources consultées ».
Propose les seules modifications nécessaires de VEILLE.md et du README.
Termine par une ligne de journal datée. N’invente ni abonnement actif,
ni notification, ni validation juridique, ni preuve d’exécution technique.
```

## Fréquence, responsabilité et preuve

Revue chaque lundi à 9 h, heure de Paris, relancée manuellement par le porteur de ce travail (`chris/`), proposition à confirmer dans le binôme. Pendant le brief, revue au début de chaque journée. Le second membre relit ; le DPO/juriste et la direction arbitrent les points juridiques. Consigner la date, les nouveautés, les décisions et la prochaine revue dans `VEILLE.md`.

Après la première exécution dans ChatGPT web, enregistrer dans `docs/veille_chatgpt_2026-11-03.png` (adapter la date) une capture réelle montrant le sujet, la date de recherche et les citations/sources. Masquer les informations du compte. Conserver également une synthèse datée dans `VEILLE.md`.

**État : prompt préparé ; première exécution dans le compte web et capture non reçues.** Une conversation exécutée prouve une consultation ; elle ne prouve pas un abonnement. Le brief exige un dispositif qui prévient des nouveautés et une capture d’abonnement : une revue manuelle seule ne remplit pas cette exigence. Faire valider cette adaptation par le formateur ou compléter ChatGPT par un abonnement officiel (par exemple le flux CNIL `https://www.cnil.fr/fr/rss.xml`), puis conserver sa capture. Aucun abonnement ni rappel automatique n’a été activé ici.
