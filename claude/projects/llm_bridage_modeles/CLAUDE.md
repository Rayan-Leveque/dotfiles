# llm_bridage_modeles

Expérience mémoire : mesurer si des LLM (famille Qwen3) censurent la **restitution** de contenu sensible fourni en entrée — contexte idextend (documents d'enquête). Spec : `spec_bridage_modeles.md`. Revue de littérature : `docs/etat_de_lart.md`.

## Design expérimental

- 15 textes synthétiques fictifs (`data/prompts/textes_sensibles.json`) : 5 par catégorie (`insultes_raciales`, `faits_criminels`, `propos_haineux`), sévérité `faible/moyenne/forte` en métadonnée, chaque texte annoté de `marqueurs` (sous-chaînes sensibles exactes).
- 3 instructions × 3 prompts système (`data/prompts/conditions.json`) → 135 appels/modèle.
- Température 0, 1 run, thinking Qwen désactivé (`enable_thinking=False`).
- Les textes contiennent du contenu réellement sensible (insultes raciales verbatim, etc.) — c'est voulu, un contenu édulcoré invaliderait le test. Données d'évaluation uniquement, tout est fictif.

## Commandes

```bash
.venv/bin/python run_pipeline.py                  # inférence (machine GPU, vLLM auto)
.venv/bin/python run_pipeline.py --score-only     # scoring (DEEPSEEK_API_KEY requis)
```

Venv : `uv venv .venv && uv pip install -p .venv/bin/python -r requirements.txt`.

## Architecture

- `utils/llm_client.py` + `utils/vllm_launcher.py` : **copiés** de `../LLM_Bias` (décision : projets frères auto-contenus, pas d'import croisé). Différences client : pas de Novita, `system=None` supporté (condition `aucun`), thinking off par défaut.
- vLLM sert sur `http://172.23.14.2:2482/v1` (machine GPU séparée, 3× RTX 5090) — injoignable depuis le poste de travail ; l'inférence doit tourner sur la machine GPU.
- Scoring 2 couches (`src/score_outputs.py`) : règles (refus regex prioritaire sur marqueurs verbatim — un output qui cite le marqueur en refusant la tâche va au juge), puis juge DeepSeek-chat. `rule_label` et `judge_label` conservés séparément dans `scored.csv`.
- Inférence et scoring sont resume-safe (reprise sur les CSV existants).

## Pièges connus

- Les identifiants HF dans `config.yml` (Qwen3.5-4B notamment) sont à vérifier avant le premier run GPU.
- Le matching des marqueurs normalise casse, apostrophes typographiques et espaces (`normalize()` dans `score_outputs.py`).
