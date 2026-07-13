# CLAUDE.md — LLM_Bias

Projet de recherche sur les biais des LLMs dans l'évaluation de CV (mémoire).
Design : ethnicity (french / maghrebin / african) × SES (adresse riche / pauvre) × single eval + comparative eval + IAT.

Pour le setup et les commandes de lancement → voir README.md.

## Venvs

- **`.venv/`** — pipeline uniquement (`openai`, `yaml`, vllm client). Toujours utiliser `.venv/bin/python`, jamais `python` ou `python3`.
- **`/home/rayan/idextend/venv`** — analyse et Jupyter (`pandas`, `numpy`, `matplotlib`, `seaborn`, `scipy`, `plotly`). Lancer avec `/home/rayan/idextend/venv/bin/jupyter lab`.

## État des runs (2026-07-13)

| Modèle | Steps complétés | Données |
|---|---|---|
| Qwen3.6-27B-FP8 | 3a + 3b (3c à relancer — **poids absents de cette machine**, ~28 Go à télécharger) | `behavioral_results.csv` (~43k lignes) |
| Gemma-4-31B-it | 3a + 3b (partiel) + **3c nouveau design (2026-07-13, 50 iters × variants a/c, 100 % parsed)** | `behavioral_results_Gemma-4-31B-it.csv` (~6k lignes) + `iat_ethnicity_{a,c}.csv` |
| Qwen3.7-max-Novita | — | En attente NOVITA_API_KEY (le `.env` du repo a des valeurs **vides**) |
| Mistral-Nemo-Novita | — | En attente NOVITA_API_KEY |
| DeepSeek-Flash / Pro | 3c à relancer (anciens runs = blocked order, archivés) | En attente DEEPSEEK_API_KEY |

**IAT (2026-07-09)** : l'ancien design présentait les labels en deux blocs fixes (groupe français/riche toujours en premier) → confound ordre × groupe. Corrigé : les 10 labels des deux groupes sont fusionnés en une seule liste shufflée par itération (rng seedé, colonne `label_list` dans le CSV), cf. Bai et al. (2024). Les anciennes données (non comparables) sont archivées dans `data/results/legacy/iat_ethnicity_{a,c}_blocked_order.csv` — y compris les runs DeepSeek-Flash/Pro du 2026-07-10, générés avec l'ancien prompt — **tout le 3c est à relancer pour tous les modèles**. `run_iat.py` accepte `--workers N` pour paralléliser les appels API (merge du refactor ThreadPoolExecutor + fix shuffle, 2026-07-10).

## Gotchas critiques

1. **IAT + modèles thinking (Qwen3)** : toujours ajouter `--no-think` pour l'étape `--step 3c`. Sans ça, le mode thinking consomme tous les tokens → `finish_reason=length` → crash.
2. **Pipeline backgroundée** : utiliser `nohup .venv/bin/python run_pipeline.py ... > logs/... 2>&1 &` depuis un screen/tmux. Si lancé directement dans Claude Code, le process est tué à la fermeture.
3. **Gemma** : model ID = `google/gemma-4-31B-it` (HuggingFace). Ne pas utiliser la variante GGUF unsloth — conflict vLLM. Requiert `quantization: fp8` dans config.yml.
4. **`--models`** prend les **display names** (ex: `"Gemma-4-31B-it"`), pas les model IDs.
5. **Port 2482 / GPUs partagés** : le serveur vLLM perso (`screen -R vllm`, `/opt/vllm_server`) occupe souvent le port 2482 (= `base_url` du config) et ~30 Go d'un GPU ; un kernel Jupyter peut retenir ~5 Go sur GPU0. Dans ce cas : changer le port dans `vllm.base_url` (ex: 2483), lancer avec `CUDA_VISIBLE_DEVICES` sur les GPUs libres, et baisser `gpu_memory_utilization` à 0.80 si GPU0 est utilisé. L'échec typique : `vLLM did not start within 300s` (le launcher tronque la vraie erreur — relancer la commande vLLM à la main pour voir `Address already in use`).

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

