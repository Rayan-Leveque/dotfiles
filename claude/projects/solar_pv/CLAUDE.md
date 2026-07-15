# solar_pv — notes projet

Projet M2 (voir `Enonce_projet_solar_pv.md`) : prédire `dc_power` à partir de
météo + variables calendaires. `ac_power` interdite en variable explicative
(dérivée de `dc_power`).

## Décisions prises

- **Groupe de données : 1** (`*_groupe_1.csv`, dans `data/raw/`, **versionné**
  dans git — rendu via GitHub, fichiers légers, pas d'étape manuelle après clone).
- **Livrable : notebook Jupyter** (`notebooks/analysis.ipynb`), pas d'app Streamlit.
- **Tooling : uv** (`pyproject.toml` + `uv.lock`), même pattern que `../dm_python_louis`.
- **Split train/test : chronologique (`shuffle=False`)** — les mesures sont à la
  maille 15 min et fortement autocorrélées ; un split aléatoire fuiterait de
  l'information entre train et test.
- **Tests : minimaux**, seulement sur `core/features.py` (`create_features`,
  `create_final_dataset`), pour un projet noté sans exigence de couverture de
  tests — pas d'investissement au-delà.
- **Bonus (sections 6-9 de l'énoncé : cascade `ac_power`, efficacité onduleur,
  résidus) : implémenté.** `M_ac` est entraîné sur `dc_power` réel (train) et
  évalué en cascade réaliste avec `dc_power_pred` (validation), conformément
  à l'énoncé.
- **Rapport : LaTeX** (`report/report.tex` → `report/report.pdf`), template
  épuré (article + geometry + booktabs, pas de boîtes "Travail avec l'agent"
  contrairement à `projet-data-accidents` — non pertinent ici, ce rendu n'est
  pas noté question par question). `report.md` (brouillon markdown) a été
  retiré une fois le `.tex` en place, pour éviter deux sources de vérité.
  Figures exportées en PNG dans `report/figures/` via un script qui réutilise
  `core/`.

## Structure

Voir le README pour l'arborescence complète et les commandes `uv run ...`.

## État

Projet complet, y compris le bonus : les 4 CSV du groupe 1 sont dans
`data/raw/` (versionnés), le notebook (`notebooks/analysis.ipynb`,
38 cellules) s'exécute de bout en bout, `report/report.pdf` (compilé,
3 pages) contient les résultats réels — RandomForestRegressor retenu pour
`dc_power` (R² = 0.893 vs 0.884 pour LinearRegression ; `irradiation`
domine l'importance des variables à 91 %), cascade `ac_power` avec
R² = 0.8945. Tests (`uv run pytest`) passent. Reste à faire par
l'utilisateur : compléter les noms des coéquipiers sur la page de titre du
rapport (placeholder laissé exprès) avant le rendu du 15 juillet 2025.
