# CLAUDE.md — LLM_Bias

Projet de recherche sur les biais des LLMs dans l'évaluation de CV (mémoire).
Design : ethnicity (french / maghrebin / african) × SES (adresse riche / pauvre) × single eval + comparative eval + IAT.

Pour le setup et les commandes de lancement → voir README.md.

## Venvs

- **`.venv/`** — pipeline uniquement (`openai`, `yaml`, vllm client). Toujours utiliser `.venv/bin/python`, jamais `python` ou `python3`.
- **`/home/rayan/idextend/venv`** — analyse et Jupyter (`pandas`, `numpy`, `matplotlib`, `seaborn`, `scipy`, `plotly`). Lancer avec `/home/rayan/idextend/venv/bin/jupyter lab`.

## État des runs (2026-07-15)

| Modèle | Steps complétés | Données |
|---|---|---|
| Qwen3.6-27B-FP8 | 3a + 3b + **3c nouveau design (2026-07-15, 50 iters × variants a/c, 1 seule assoc non parsée sur 1600)** | `behavioral_results.csv` (~43k lignes) + `iat_ethnicity_{a,c}.csv` |
| Gemma-4-31B-it | 3a + 3b (partiel) + **3c nouveau design (2026-07-13, 50 iters × variants a/c, 100 % parsed)** | `behavioral_results_Gemma-4-31B-it.csv` (~6k lignes) + `iat_ethnicity_{a,c}.csv` |
| Qwen3.7-max-Novita | — | En attente NOVITA_API_KEY (le `.env` du repo a des valeurs **vides**) |
| Mistral-Nemo-Novita | — | En attente NOVITA_API_KEY |
| DeepSeek-Flash / Pro | 3c à relancer (anciens runs = blocked order, archivés) | En attente DEEPSEEK_API_KEY |

**IAT (2026-07-09)** : l'ancien design présentait les labels en deux blocs fixes (groupe français/riche toujours en premier) → confound ordre × groupe. Corrigé : les 10 labels des deux groupes sont fusionnés en une seule liste shufflée par itération (rng seedé, colonne `label_list` dans le CSV), cf. Bai et al. (2024). Les anciennes données (non comparables) sont archivées dans `data/results/legacy/iat_ethnicity_{a,c}_blocked_order.csv` — y compris les runs DeepSeek-Flash/Pro du 2026-07-10, générés avec l'ancien prompt — **tout le 3c est à relancer pour tous les modèles**. `run_iat.py` accepte `--workers N` pour paralléliser les appels API (merge du refactor ThreadPoolExecutor + fix shuffle, 2026-07-10).

## Éval comparative (3b) — gelée (2026-07-15)

**Audit 2026-07-15** : 99,9 % des 1 912 choix vont au candidat A (présenté en premier), pour les 5 modèles testés (DeepSeek-Flash, DeepSeek-Pro, Gemma-4-31B-it, Qwen3.6-27B-FP8, Qwen3.7-max-Novita) — seule exception : 2 paires DeepSeek-Pro. Le parsing (`utils/parse_response.py::parse_comparative`) est correct — c'est le comportement réel des modèles. Cause structurelle : les deux CV sont identiques au mot près (seuls `nom_complet` et `condition` diffèrent) + température 0 → les modèles détectent l'égalité et tranchent par position (Gemma le verbalise : « Puisque les profils sont des copies conformes, le choix ne peut se baser sur une différence de compétences » → choisit A). Conséquence : `chose_french` est entièrement déterminé par l'ordre de présentation ; la « préférence nette ≈ 0 » en agrégé est un artefact du contrebalancement, **pas** une preuve d'équité.

**Décision** : données existantes **gardées**, requalifiées en mesure du **biais de position** (cf. Zheng et al. 2023, position bias des LLM-juges) — résultat méthodologique du mémoire (choix forcé entre candidats indiscernables = mesure de la position, pas de la préférence ethnique). Protocole 3b **gelé** : ne plus le relancer en l'état, ne pas compléter les 37 paires manquantes DeepSeek-Pro (163/200). L'argument central reste la dissociation à trois niveaux : IAT = stéréotype fort sur les adresses, éval individuelle = écart faible, comparatif = rien (position) — cohérent avec la littérature biais implicites vs mesures explicites. Pour rappel, 3a est saine (taux d'acceptation 39–53 %, pas d'effet plafond).

**Voie future pour une vraie mesure comparative (si besoin), par ordre d'efficacité** :
1. **Logprobs sans CoT** — **IMPLÉMENTÉ + RUN GEMMA COMPLET (2026-07-16)** : `src/evaluation/run_comparative_logprobs.py` (standalone, cf. README § 3b-bis pour les commandes) + `call_llm_logprobs()` dans `utils/llm_client.py`. **Utiliser le mode `--bias`** : la saturation positionnelle (~±20 log-odds) fait sortir le token perdant du top-20 → P(B)=0 exactement en mode brut ; le fix est un `logit_bias` identique (+30) sur A et B (écart de log-odds préservé), qui requiert un serveur vLLM lancé avec `--logprobs-mode processed_logprobs` (sinon logprobs pré-biais). `guided_choice` testé et inopérant (masque non reflété dans les logprobs). **Résultats (400 lignes chacun, `comparative_logprobs_bias_<model>.csv`)** : **Gemma-4-31B-it** — position ±19,6 log-odds (P(position A) ≈ 1−10⁻⁹) ; préférence ethnique nette ≈ 0, Wilcoxon global p=0,79, 4 cellules ns, σ inter-profils ≈ 0,5 → **vrai zéro mesuré** (contrairement au 3b gelé où le zéro était un artefact). **Qwen3.6-27B-FP8** — position ±3,3 log-odds seulement (6× moins saturé) ; **petite préférence pro-français significative** : global p=0,0075, +0,031 log-odds (≈ P(fr)=0,508), portée par maghrébin/pauvre (+0,064, p=0,0059, survit à Bonferroni ×4) ; effet SES sur la préférence ns (p=0,098). Premier signal ethnique détectable en comparatif — invisible en argmax. Note serveur Qwen3.6 sur GPUs partiellement occupés : ajouter `--enforce-eager` (le pic de profiling/CUDA graphs OOM sinon, même à util 0,70). Reste : DeepSeek/Novita dès que les clés API sont dans le `.env` (attention : vérifier que l'API cloud reflète logit_bias dans les logprobs, sinon on retombe sur la troncature top-k).
2. Température > 0 (ex. 1.0) avec N répétitions par paire → estimer P(choisit français) au lieu d'un argmax déterministe.
3. CV équivalents mais non identiques (testing par correspondance réel — DARES, ISM Corum) : deux variantes de même niveau, contrebalancées ; coûteux, à valider.

**Micro-fix noté (non appliqué)** : `parse_comparative` utilise `re.search` → prend la PREMIÈRE occurrence de « Candidat retenu » ; préférer la dernière (le modèle peut employer la formule dans son CoT).

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

