# CLAUDE.md — LLM_Bias

Projet de recherche sur les biais des LLMs dans l'évaluation de CV (mémoire).
Design : ethnicity (french / maghrebin / african) × SES (adresse riche / pauvre) × single eval + comparative eval + IAT.

Pour le setup et les commandes de lancement → voir README.md.

## Venvs

- **`.venv/`** — pipeline uniquement (`openai`, `yaml`, vllm client). Toujours utiliser `.venv/bin/python`, jamais `python` ou `python3`.
- **`/home/rayan/idextend/venv`** — analyse et Jupyter (`pandas`, `numpy`, `matplotlib`, `seaborn`, `scipy`, `plotly`). Lancer avec `/home/rayan/idextend/venv/bin/jupyter lab`.

## État des runs (2026-05-27)

| Modèle | Steps complétés | Données |
|---|---|---|
| Qwen3.6-27B-FP8 | 3a + 3b + 3c | `behavioral_results.csv` (~43k lignes), `iat_ethnicity_a.csv`, `iat_ethnicity_c.csv` |
| Gemma-4-31B-it | 3a + 3b (partiel) | `behavioral_results_Gemma-4-31B-it.csv` (~6k lignes) |
| Qwen3.7-max-Novita | — | En attente NOVITA_API_KEY |
| Mistral-Nemo-Novita | — | En attente NOVITA_API_KEY |

## Gotchas critiques

1. **IAT + modèles thinking (Qwen3)** : toujours ajouter `--no-think` pour l'étape `--step 3c`. Sans ça, le mode thinking consomme tous les tokens → `finish_reason=length` → crash.
2. **Pipeline backgroundée** : utiliser `nohup .venv/bin/python run_pipeline.py ... > logs/... 2>&1 &` depuis un screen/tmux. Si lancé directement dans Claude Code, le process est tué à la fermeture.
3. **Gemma** : model ID = `google/gemma-4-31B-it` (HuggingFace). Ne pas utiliser la variante GGUF unsloth — conflict vLLM. Requiert `quantization: fp8` dans config.yml.
4. **`--models`** prend les **display names** (ex: `"Gemma-4-31B-it"`), pas les model IDs.

## Notebook d'analyse

`notebooks/analysis.ipynb` — entièrement en français, inspiré de Bai et al. (2402) et Gallegos et al. (2602).

Cellules clés :
- Cell 1 : setup + chargement data (`verbalized` → `.astype(bool)`, pas `.map()`)
- Cell 3 : biais décision individuelle (point plot + CI)
- Cell 5 : biais décision comparative (+ stars binomial test)
- Cell 7 : dissociation individuel/comparatif
- Cell 9 : effet CSP (point plot cercle/carré + lignes connectées par groupe)
- Cells 11-12 : IAT (barplot horizontal proportion par mot)
- Cell 14 : verbalisation (barplot horizontal + annotations fraction)
- Cell 16 : tests statistiques (McNemar + Mann-Whitney)
- Cell 18 : dashboard récapitulatif 2×2

`notebooks/model_comparison.ipynb` — notebook dédié à la comparaison inter-modèles (Qwen3.6 / Qwen3.7-max / Gemma) et à l'extraction de connaissances (slope CSP, verbalisation, text-mining des marqueurs, IAT mono-modèle). Régénérable via `notebooks/_build_model_comparison.py`.

## Prochaines étapes

- [ ] Obtenir `NOVITA_API_KEY` → lancer run Novita (Qwen3.7-max + Mistral-Nemo)
- [ ] Compléter run Gemma-4-31B (GPUs libres chez pierre)
- [x] Ajouter figures multi-modèles au notebook
