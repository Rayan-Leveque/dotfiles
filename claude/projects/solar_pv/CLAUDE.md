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

Le squelette du projet (core/, utils/, notebooks/, tests/) est en place et
testé (`uv run pytest`). Le notebook ne peut pas encore être exécuté de bout
en bout : les CSV du groupe 1 ne sont pas encore présents dans `data/raw/`.
