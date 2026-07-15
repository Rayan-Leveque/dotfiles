# solar_pv — notes projet

Projet M2 (voir `Enonce_projet_solar_pv.md`) : prédire `dc_power` à partir de
météo + variables calendaires. `ac_power` interdite en variable explicative
(dérivée de `dc_power`).

## Décisions prises

- **Groupe de données : 1** (`*_groupe_1.csv`, à placer dans `data/raw/`, non versionné).
- **Livrable : notebook Jupyter** (`notebooks/analysis.ipynb`), pas d'app Streamlit.
- **Tooling : uv** (`pyproject.toml` + `uv.lock`), même pattern que `../dm_python_louis`.
- **Split train/test : chronologique (`shuffle=False`)** — les mesures sont à la
  maille 15 min et fortement autocorrélées ; un split aléatoire fuiterait de
  l'information entre train et test.
- **Tests : minimaux**, seulement sur `core/features.py` (`create_features`,
  `create_final_dataset`), pour un projet noté sans exigence de couverture de
  tests — pas d'investissement au-delà.
- **Bonus (sections 6-9 de l'énoncé : cascade `ac_power`, efficacité onduleur,
  résidus) : non implémenté.** `core/models.py` (`split_train_test`, `evaluate`)
  et `core/features.py` sont conçus pour être réutilisables tels quels si cette
  section est ajoutée plus tard.
- **Rapport : `report.md`**, à exporter en PDF par l'utilisateur avant rendu (4 pages max avec figures).

## Structure

Voir le README pour l'arborescence complète et les commandes `uv run ...`.

## État

Projet complet : les 4 CSV du groupe 1 sont dans `data/raw/`, le notebook
(`notebooks/analysis.ipynb`) s'exécute de bout en bout, `report.md` contient
les résultats réels (RandomForestRegressor retenu, R² = 0.893 vs 0.884 pour
LinearRegression ; `irradiation` domine l'importance des variables à 91 %).
Tests (`uv run pytest`) passent. Reste à faire par l'utilisateur : exporter
`report.md` en PDF (4 pages max) avant le rendu du 15 juillet 2025 ; le bonus
(cascade `ac_power`, sections 6-9) n'est pas traité.
