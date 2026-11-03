# Note de veille réglementaire — Hudson Cab

État initial au **3 novembre 2026**, fuseau Europe/Paris. Analyse documentaire du jour 1 ; aucune politique ni purge n’a encore été appliquée. Sources web consultées à cette date. Le contrat reste inchangé. Les conclusions appliquent les textes aux faits du brief ; les arbitrages signalés restent à faire par le juriste/DPO.

## 1. Le droit applicable

| Question | Conclusion pour le cas du brief | Fondement |
|---|---|---|
| Le RGPD s’applique-t-il ? | Oui : la gestion RH est réalisée dans le cadre des activités de Hudson Cab Europe, établissement parisien qui décide de ce traitement. La présence des chauffeurs à New York n’écarte pas ce critère. | RGPD, **art. 3 §1** ; CEPD 3/2018, critère d’établissement [S1, S2] |
| Faut-il invoquer l’article 3 §2 ? | Ce n’est pas le fondement retenu : il vise le ciblage de personnes dans l’Union par un organisme sans établissement dans l’Union ; ces faits ne sont pas ceux du cas. | Art. 3 §2 [S1] |
| Responsable du traitement | **Hudson Cab Europe**, selon le pouvoir de décision décrit dans le brief. Une éventuelle codécision de Hudson Cab Partners demanderait une analyse complémentaire. | Art. 4(7), 26 [S1, S4] |
| Sous-traitant | **Snowflake**, pour l’hébergement et les opérations effectuées sur instruction ; contrat et entité contractante à vérifier. L’équipe data interne agit sous l’autorité du responsable. | Art. 4(8), 28, 29 [S1, S4] |
| Autorité de contrôle | **CNIL** pour l’établissement français. Le statut d’autorité chef de file en cas de traitement transfrontalier européen demanderait une vérification distincte. | Art. 55 et 56 [S5, S6] |

La région Paris est confirmée dans le README. Elle ne fonde pas l’application de l’article 3 et ne suffit pas à exclure tout transfert : examiner les destinataires, accès distants et sous-traitants (art. 44 et suivants, à instruire avec le DPO).

### Sources de référence

Toutes consultées le 3 novembre 2026 ; les dates de publication sont distinguées ci-dessous.

- **S1 — RGPD**, règlement (UE) 2016/679 du 27 avril 2016, applicable depuis le 25 mai 2018 : [texte EUR-Lex](https://eur-lex.europa.eu/eli/reg/2016/679/oj?locale=fr). L’accès automatisé EUR-Lex a renvoyé une vérification JavaScript ; articles 3 et 4 lus dans la [reproduction officielle CNIL, chapitre I](https://www.cnil.fr/fr/reglement-europeen-protection-donnees/chapitre1).
- **S2 — CEPD**, lignes directrices 3/2018, version finale du **12 novembre 2019** : [page officielle et document](https://www.edpb.europa.eu/documents/guideline/guidelines-32018-on-the-territorial-scope-of-the-gdpr-article-3-version-adopted_fr). Page de publication consultée ; téléchargement du PDF français limité par une réponse HTTP 429. Le raisonnement territorial repose directement sur l’article 3 de S1 ; ne pas prétendre avoir relu ce PDF intégralement.
- **S3 — RGPD, art. 5 et 6**, [CNIL, chapitre II](https://www.cnil.fr/fr/reglement-europeen-protection-donnees/chapitre2), texte de 2016, rectificatif de 2018 mentionné sur la page.
- **S4 — RGPD, art. 25, 26, 28 à 30 et 32**, [CNIL, chapitre IV](https://www.cnil.fr/fr/reglement-europeen-protection-donnees/chapitre4), texte de 2016 ; date de mise à jour de la page non précisée.
- **S5 — RGPD, art. 55 et 56**, [CNIL, chapitre VI](https://www.cnil.fr/fr/reglement-europeen-protection-donnees/chapitre6), texte de 2016, rectificatif de 2018 mentionné.
- **S6 — CNIL**, [présentation de l’autorité française](https://www.cnil.fr/fr/cnil-direct/question/la-cnil-cest-quoi), date de publication non précisée.
- **S7 — CNIL**, [référentiel des durées de conservation RH](https://www.cnil.fr/fr/referentiel-durees-conservation-donnees-rh), publié le **2 avril 2026**, avec lien vers le nouveau référentiel. Il complète le référentiel GRH du kit.
- **S8 — CNIL**, [cycle de vie et durées de conservation](https://www.cnil.fr/fr/passer-laction/les-durees-de-conservation-des-donnees), **2 avril 2026**.
- **S9 — Code du travail, art. R1221-26**, [Légifrance](https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000031392972), règle de conservation des mentions du registre unique du personnel ; version en vigueur à contrôler lors d’une décision opérationnelle.
- **S10 — Snowflake**, [Time Travel](https://docs.snowflake.com/en/user-guide/data-time-travel) et [Fail-safe](https://docs.snowflake.com/en/user-guide/data-failsafe), documentation technique évolutive, date de publication non indiquée.

## 2. Le dispositif de veille

**Outil choisi : ChatGPT web avec recherche web.** Le titulaire a choisi cet outil le 3 novembre 2026. Les prompts initial et hebdomadaire, les pièces à joindre et la procédure de preuve sont dans [PROMPT_VEILLE.md](PROMPT_VEILLE.md).

| Organisme officiel / source | Ce qu’on surveille | Fréquence proposée | Outil et trace |
|---|---|---|---|
| [CNIL — actualités](https://www.cnil.fr/fr/actualites), référentiels RH et sécurité | Conservation, minimisation, recommandations et décisions | Chaque lundi à 9 h Paris ; chaque matin du brief | Recherche ChatGPT web, liens ouverts et compte rendu daté |
| [CEPD/EDPB — publications](https://www.edpb.europa.eu/our-work-tools/our-documents_en) et [actualités](https://www.edpb.europa.eu/news_en) | Champ territorial, responsable/sous-traitant, transferts | Même fréquence | Même procédure ; distinguer consultations et versions finales |
| [EUR-Lex — RGPD](https://eur-lex.europa.eu/eli/reg/2016/679/oj?locale=fr) et [Légifrance](https://www.legifrance.gouv.fr/) | Textes, rectificatifs et périmètre des obligations françaises | Même fréquence | Vérification des versions ; consigner tout accès impossible |
| [Snowflake — documentation](https://docs.snowflake.com/en/) | Rétention, politiques, tags, tâches et audit | Même fréquence, et avant changement du pipeline | Recherche limitée au domaine officiel ; ce fournisseur n’est pas une autorité juridique |

Responsable proposé pour le brief : **porteur du travail `chris/`**, avec relecture du binôme ; répartition nominative à confirmer. Pour l’équipe cible : référent veille data, suppléant et DPO à désigner par Hudson Cab Europe. Le référent détecte et propose, le DPO/juriste instruit le droit, la direction valide les arbitrages. La prochaine revue proposée est le **9 novembre 2026 à 9 h Paris** ; aucun rappel n’a été créé.

**Statut honnête : dispositif préparé, activation et preuve attendues.** La recherche présente a été effectuée dans la session de travail, mais aucune exécution dans le compte ChatGPT web du titulaire ni capture n’a été reçue. Le fichier attendu est `docs/veille_chatgpt_AAAA-MM-JJ.png`. Une capture de consultation n’est pas une capture d’abonnement. Une revue manuelle ne prévient pas spontanément d’une publication : obtenir l’accord du formateur sur cette adaptation ou compléter par un abonnement officiel, dont le [flux CNIL](https://www.cnil.fr/fr/rss.xml), et sa capture. L’exigence d’alerte/abonnement du brief reste ouverte.

### Journal de suivi

| Date | Opération et résultat | Action / décision | Preuve |
|---|---|---|---|
| 2026-11-03 | Recherche initiale des textes et des contraintes Snowflake ; découverte du référentiel RH 2026 | Fiches ci-dessous et écarts à instruire | S1 à S10 ; présente note |
| À renseigner après exécution web | Première revue dans l’outil choisi | Ouvrir les citations, vérifier les conclusions, conserver la capture ; définir le mécanisme d’alerte | Capture non disponible |

## 3. Les fiches de veille

### Fiche 1 — Champ territorial et responsabilités

- **Source et date** : S1, RGPD du 27 avril 2016, art. 3 et 4 ; page de publication CEPD S2 du 12 novembre 2019. Consultation : 3 novembre 2026.
- **Synthèse** : le critère d’établissement rattache ce traitement au RGPD. La qualité de responsable dépend du pouvoir de décision ; celle de sous-traitant de l’exécution pour autrui.
- **Conséquence** : documenter Hudson Cab Europe comme responsable et vérifier le contrat Snowflake.
- **Action** : à faire dans la note ; contrat de sous-traitance à vérifier avec le juriste.

### Fiche 2 — Minimisation et exactitude

- **Source et date** : S3, RGPD du 27 avril 2016, art. 5 §1 c), d), e), f) et 6 ; consultation le 3 novembre 2026.
- **Synthèse** : données, accès et durées se justifient par la finalité. Un seuil technique de qualité ne vaut pas autorisation de laisser des erreurs sans correction.
- **Conséquence** : distinguer besoins paie, dépôt et analyse ; traiter les données d’activité reliées à `driver_id` comme personnelles.
- **Action** : inventaire, arbitrages de colonnes et procédure de correction des anomalies.

### Fiche 3 — Nouveau référentiel RH et durée de cinq ans

- **Source et date** : S7, CNIL, **2 avril 2026** ; S9, art. R1221-26 ; consultation le 3 novembre 2026.
- **Synthèse** : le référentiel distingue repères et durées imposées par un texte. Son périmètre vise le personnel soumis au droit du travail français ; le délai du registre unique ne justifie pas à lui seul tous les champs RH new-yorkais.
- **Conséquence** : les cinq ans du contrat demandent une justification par catégorie, finalité et droit applicable.
- **Action** : signaler à la direction ; faire valider les obligations locales par le juriste.

### Fiche 4 — Base active et archivage

- **Source et date** : S8, CNIL, **2 avril 2026** ; consultation le 3 novembre 2026.
- **Synthèse** : les données utiles au travail courant et celles nécessaires seulement à une obligation ou un contentieux relèvent de phases distinctes. L’archivage intermédiaire doit avoir des accès restreints.
- **Conséquence** : garder tous les chauffeurs partis dans les mêmes tables et accès pendant cinq ans demande réexamen.
- **Action** : proposer une séparation des usages actifs et archivés, sans changer unilatéralement le contrat.

### Fiche 5 — Protection par défaut et sous-traitance

- **Source et date** : S4, RGPD du 27 avril 2016, art. 25, 28 et 32 ; consultation le 3 novembre 2026.
- **Synthèse** : la sécurité doit être adaptée aux risques et les accès limités aux besoins. La sous-traitance doit être encadrée contractuellement.
- **Conséquence** : séparer gouvernance et lecture, tester les rôles, protéger le pipeline et auditer les accès et changements de politiques.
- **Action** : mise en œuvre aux jours suivants ; vérifier le contrat de service et les destinataires avec le DPO.

### Fiche 6 — Une purge n’est pas une disparition immédiate

- **Source et date** : S10, documentation officielle Snowflake, date de publication non indiquée ; consultation le 3 novembre 2026.
- **Synthèse** : Time Travel conserve les versions supprimées pendant la rétention configurée. Les tables permanentes passent ensuite par sept jours de Fail-safe, gérés par Snowflake pour la récupération d’urgence.
- **Conséquence** : avec un jour de Time Travel, compter un cycle nominal de **1 + 7 jours**, sans le présenter comme une garantie d’effacement physique à une heure précise ; une requête historique longue peut retarder la transition.
- **Action** : vérifier les paramètres effectifs et les copies, expliquer cette conservation résiduelle au registre.

## 4. Le contrat face aux textes

Les appréciations suivantes sont documentaires ; leur réalisation technique reste à prouver. Fondements transversaux : art. 5 (S3), protection par défaut et sécurité (S4), cycle de vie (S8). Les écarts se retrouvent dans le README.

| Règle | Texte / source | Appréciation et écart | Proposition à instruire |
|---|---|---|---|
| R1 : cinq ans après départ | Art. 5 §1 e) ; S7, S8, S9 | Justification insuffisante pour une durée uniforme de tous les champs ; confusion possible avec le registre français et absence de séparation actif/archive | Juriste : matrice finalité/catégorie/droit/durée ; direction : accès d’archive ; appliquer le contrat de l’exercice tout en signalant cette limite |
| R2 : Time Travel un jour | S10 ; conservation limitée S3 | Répond à une limite de restauration utilisateur, sans prouver l’effacement de toutes les copies ; Fail-safe persiste | Limiter chaque table concernée, vérifier la rétention effective et documenter les sept jours supplémentaires |
| R3 : stage vidé | Minimisation/confidentialité S3 ; sécurité S4 | Mesure cohérente ; insuffisante pour les autres copies | Vérifier le stage après chaque chargement ; traiter aussi fichiers locaux, exports et captures |
| Matrice des accès | Art. 25 et 32, S4 | Besoins métier globalement séparés ; masque et identifiant interne ne rendent pas l’activité anonyme ; comptes privilégiés peuvent modifier les protections | Tests par rôle, contrôle des changements, justification de chaque colonne et de l’accès aux anciens chauffeurs |
| Tags imposés | Art. 4(1), S1 ; minimisation S3 | Six valeurs décrivent surtout les identifiants ; aucune ne décrit clairement activité, dates d’emploi ou rattachement | Inventaire exhaustif ; demander clarification de taxonomie, sans inventer ni imposer de nouvelles valeurs |
| `licence_unique` : 0, avertissement | Exactitude S3 | Utile, mais doublons tolérés jusqu’à correction | Documenter les anomalies et leur responsable ; une licence publique reste personnelle |
| `telephone_renseigne` : 5 %, avertissement | Minimisation/exactitude S3 | Le besoin de contact doit être justifié ; seuil d’exploitation, pas dispense légale | Calculer 5 % des actifs à chaque mesure et corriger les manques nécessaires au métier |
| `email_valide` : 0, avertissement | Exactitude S3 | Présence de `@` insuffisante pour prouver une adresse utilisable | Conserver le test imposé, signaler sa portée limitée et organiser la correction |
| `dates_coherentes` : 0, avertissement | Exactitude S3 | Contrôle nécessaire ; une date fausse affecte aussi la purge | Alerter et corriger à la source, sans conserver artificiellement plus longtemps |
| `depot_connu` : 0, avertissement | Exactitude S3 | Une faute de dépôt peut fausser le filtrage métier | Mesurer sur RAW et vérifier le nettoyage avant MARTS |
| `service_rattache` : 50, bloquant au-delà | Exactitude/sécurité S3, S4 | Autorise techniquement jusqu’à 50 services orphelins ; pas une validation juridique de ces erreurs | Tracer aussi sous le seuil, corriger les rattachements ; ne pas supprimer tous les orphelins pour cacher le problème |
| `service_unique` : 0, avertissement | Exactitude S3 | Déduplication STAGING utile mais n’efface pas l’anomalie RAW | Garder mesure RAW et règle explicite de déduplication |
| `duree_plausible` : 16 h, avertissement | Exactitude S3 | Contrôle de plausibilité ; n’établit pas la conformité au droit du travail | Corriger avec les RH ; demander validation métier de la limite |

Au minimum, `licence_unique`, `service_rattache` et une troisième règle seront implémentées au jour 3. La confrontation documentaire des huit règles ne signifie pas qu’elles sont déjà codées ou testées.

## 5. Ce que la veille ne tranche pas

Questions à soumettre, sans envoi externe effectué :

1. **Juriste RH et DPO** : quelles bases légales par finalité (art. 6), quelles obligations américaines de conservation et quels champs sont nécessaires ? Le délai français du registre unique s’applique-t-il à un périmètre particulier du groupe ?
2. **Direction et DPO** : faut-il retirer les anciens chauffeurs des accès opérationnels, avec archivage restreint ? Quelles durées distinctes pour coordonnées, licences et activité ?
3. **Juridique fournisseur et DPO** : quelle entité Snowflake, quelles clauses art. 28, quels sous-traitants, accès hors EEE et garanties de transfert ? Paris seul ne tranche pas la question.
4. **DPO** : information des chauffeurs, exercice des droits et évaluation de la nécessité d’une AIPD (art. 35), au regard des usages effectifs.
5. **Direction technique et DPO** : valider le risque résiduel de Fail-safe, les copies/exports et le réimport de personnes déjà purgées.
6. **Formateur et référent gouvernance** : clarifier les tags pour les données professionnelles indirectes et la lecture des administrateurs dans RAW, distincte du refus de lignes MARTS.
7. **Formateur** : une revue ChatGPT web manuelle ne satisfait pas l’exigence d’abonnement/alerte ; quelle adaptation accepter ou quel abonnement complémentaire ajouter ?

Aucune certification globale de conformité n’est déduite de ce travail. Le jeu d’école est fictif ; le registre et les fichiers publiables n’en recopient pas les valeurs nominatives.
