# CLAUDE.md — Manuscrit_M2

Mémoire de M2 (alternance idextend) sur la conformité **AI Act** des LLMs : audit empirique des biais et calibration de scores de confiance pour un déploiement on-premise.

Documents de pilotage, à lire avant toute rédaction :
- **`PLAN.md`** : structure complète, problématique, 3 sous-questions (SQ1 biais, SQ2 cross-paradigme, SQ3 confiance), thèse défendue, tableau pivot AI Act ↔ métriques, détail chapitre par chapitre.
- **`TODO.md`** : liste vivante. Cocher et dater à chaque avancée (respecter le format existant, mettre à jour la ligne « Dernière mise à jour »).
- **`README.md`** : commandes de compilation et dépendances.

Les expériences (données, notebooks, figures sources) vivent hors de ce repo, dans `../Memoire_experiments/` (et `LLM_Bias/`).

## Compilation

LuaLaTeX + biber, classe `MemoireMimo.cls` (à ne pas éditer sans raison forte) :

```bash
lualatex MonMemoire.tex && biber MonMemoire && lualatex MonMemoire.tex
```

Distribution **TinyTeX** dans `~/.TinyTeX` (binaires dans `~/.TinyTeX/bin/x86_64-linux`, à mettre dans le `PATH` ; `TEXMFHOME=~/.TinyTeX/texmf-local`), `biber` 2.21. Paquets installés à la demande via `tlmgr install <paquet>` (si `tlmgr` refuse : `tlmgr update --self` d'abord, puis `mktexlsr`). Au-delà du TinyTeX de base, ce mémoire requiert : `aeguill`, `doublestroke`, `mdwtools` (mathenv), `dpfloat`, `biblatex`, `biber`, `tcolorbox`, `titlesec`, `lettrine`, `tex-gyre`, `tex-gyre-math`, `rsfs`, `pdfcol`, `makecell`, `enumitem`, `placeins`, `supertabular`, `tocbibind`, `lipsum`.

**Build après chaque modification du manuscrit** : relancer le cycle complet ci-dessus, vérifier que les 3 passes rendent exit 0 et qu'aucun `undefined`/`Rerun` ne subsiste dans le log. Ne pas committer les fichiers auto-générés (`.aux`, `.bbl`, `.bcf`, `.log`, `.out`, `.toc`, `.run.xml`, `.idx`, `.pdf`) : vérifier avant `git add`.

## Structure

- `MonMemoire.tex` : préambule, page de titre, `\include{chapters/...}`. Contient les infos de couverture (titre, tuteur, jury, résumés FR/EN, mots-clés), dont plusieurs restent des placeholders ou `\lipsum` (voir TODO).
- `chapters/*.tex` : un fichier par chapitre. Ordre : `remerciements`, `abreviations`, `introduction`, `cadre-reglementaire` (**contient le tableau pivot `tab:grille-pivot`**), `etat-de-l-art`, `volet-biais` (H1 à H7), `volet-confiance` (human oversight, HITL), `discussion`, `conclusion`, `annexes`.
- `figures/` : 27 figures d'expériences copiées, **7 activées** (une par hypothèse H1 à H7). Les autres sont disponibles comme figures secondaires.
- `Bibliographie.bib` : biblatex. `\nocite{*}` est **temporairement** actif dans `MonMemoire.tex`, à retirer en fin de rédaction.

Chaque section non rédigée porte une note italique « contenu prévu » (visible dans le PDF) et des commentaires `%` listant figures et références à placer.

## Gotchas

1. **`tabularx` interdit** : incompatible avec le paquet `mathenv` chargé par `MemoireMimo.cls`. Utiliser `tabular` + `booktabs`.
2. **`\lipsum` = placeholder** : à supprimer au fil de la rédaction (résumés FR/EN, sections vides). Ne jamais laisser de lipsum dans une version rendue.
3. **Compiler après chaque changement bibliographique** avec le cycle complet lualatex, biber, lualatex, sinon les citations restent en `[?]`.
4. **`MonMemoire.pdf` committé** sert d'artefact de suivi : le régénérer avant de le committer, ne pas le corriger à la main.

## Conventions de rédaction

Ton et forme d'un mémoire académique français, cohérents avec l'existant :

- **Langue** : français académique, registre soutenu mais lisible. Phrases claires, pas de remplissage. On (impersonnel) ou nous de modestie, en restant cohérent avec le chapitre en cours.
- **Ponctuation** : limiter clairement le tiret en incise ou deux points (tiret cadratin `—`, double tiret `--`). Préférer virgules, parenthèses ou une phrase séparée. Le tiret simple des mots composés reste normal.
- **Typographie française** : espaces insécables avant `; : ! ?` et dans les nombres/unités ; guillemets `\og … \fg` (ou « … ») ; « AI Act », « on-premise », « open-weight » en romain (anglicismes assumés du domaine).
- **Terminologie stable** (ne pas faire varier les termes clés) : *AI Act* (pas « IA Act »), *human oversight* / *HITL*, *score de confiance*, *biais implicite/comportemental*, *logprobs*, *calibration*, *Annexe III*, articles cités « art. 10 », « art. 14 »… Réutiliser exactement les formulations de `PLAN.md`.
- **Structure d'argumentation** : chaque volet expérimental relie une exigence AI Act, une grandeur mesurable, un protocole et un résultat (logique du tableau pivot). Ne pas présenter un résultat sans son ancrage réglementaire.
- **Citations** : biblatex, `\autocite{clef}` / `\textcite{clef}`. Vérifier que la clé existe dans `Bibliographie.bib`, sinon l'ajouter, ne pas inventer de référence.
- **Figures** : `\ref{}` et caption informative (ce que la figure montre ET ce qu'on en conclut), pas juste un titre. Labels `fig:h<n>_...` cohérents avec les noms de fichiers.
- **Hypothèses H1 à H7** : garder la numérotation et les intitulés déjà fixés dans PLAN.md et le volet biais.
- **Rédaction assistée** : proposer des drafts au niveau section, signaler explicitement les affirmations à sourcer (marquer `% TODO source` plutôt qu'inventer un chiffre ou une citation).

## Préférences de travail

- Avant un changement de structure (nouveau chapitre, réorganisation, choix de mise en page), proposer 2 ou 3 options plutôt que trancher seul.
- Modifications chirurgicales : ne pas reformater ou « améliorer » du texte adjacent non demandé.
- Mettre à jour la doc dès que nécessaire `CLAUDE.md` `PLAN.md` `TODO.md`
- ⚠ **Calendrier AI Act** : l'échéance « haut risque Annexe III » du 2 août 2026 est un point mouvant (reports, omnibus possibles). Le re-vérifier au moment du rendu, ne pas figer une date sans le signaler.
