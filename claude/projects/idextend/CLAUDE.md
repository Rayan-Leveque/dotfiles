# IDeXtend

RAG-based judicial investigation system (Gendarmerie / CFIA). Classified
**high-risk under EU AI Act Annex III §6** — confidence scoring and traceability
lare first-class requirements, not optional polish.

Install/requirements are in `README.md`; this file only covers what isn't obvious
from the code.

## Running

- Server: `./start_server.sh` (activates the venv, sets `PYTHONPATH`, runs `website/main.py`).
- **`PYTHONPATH` must be the repo root** or imports like `from DataPipelines… / from ressources…` break. This is the most common footgun.
- venv naming is inconsistent in the repo: `start_server.sh` uses `venv/`, `Tests/Makefile` defaults to `idextend_env/`. Check which one exists.
- Frontend lives in `vue_front/`: `npm run build` outputs into `website/templates/`. For the intranet build, uncomment the `/idextend/` base path in `vue_front/src/main.js`.

## Configuration

Almost everything is driven by `config.ini` (~30 sections: `LLM`, `NER`, `DATABASE`,
`GEOCODING`, `OCR`, `WHISPER`, `REPORTS`, `Prompts.{english,french,german}`, …).
Read it via `utils/config.py → get_config()`. Add new settings there instead of hardcoding.

## Architecture

- `DataPipelines/` — ingestion tasks + model wrappers (`AbstractTask`, `AbstractModel`, `ModelManager`, OCR/LLM/Embeddings/Gliner2/Whisper). `pipelines_definition.json` wires pipelines.
- `LargeLanguageHandler/` — `rag.py`, `reranker.py`, answer streaming, prompt providers.
- `website/` — Flask + flask_restx API (`main.py`, `endpoints/`, `rights/`).
- `persistence/` — graph DB layer (ArcadeDB at `localhost:2480`, Neo4j).
- `geo/`, `image/`, `utils/` — geocoding, OCR/video, shared helpers.
- Workspace tools (frontend): GoldenLayout tools are auto-discovered from
  `vue_front/src/components/gltools/gl*.vue` (contract enforced by
  `modules/toolIntegrity.js`); cross-tool data flows through
  `modules/orchestrator.js` dataFeeds (`KNOWLEDGE_MAP`, `TIMELINE`, …).
- NER entities list (`gl-NerList`, dashboard-style cards): `DataPipelines/NerSummary.py
  → NerSummaryTask` (last procedure of both ingestion pipelines) precomputes the
  top 10 entities (by chunk occurrences) of the 4 main categories (PERSON,
  ORGANIZATION, DATE, LOCATION incl. `LOCATION_GEOCODABLE`) into
  `<base_internal_data_path>/<case>/ner_summary.json` — the tool reads it via
  `GET /cases/<id>/ner_summary` instead of querying the graph; clicking an entity
  hits `GET /cases/<id>/ner_focus/<rid>` (cypher: the node + everything directly
  linked to it, `NER_direct_graph`) which feeds `KNOWLEDGE_MAP` (Knowledge/Tabular
  graph). File is absent until the first ingestion after this feature landed.
- Home dashboard `gl-Home` (in progress): full spec and ticket breakdown in
  `docs/SPEC_gl-home.md` — read it before any work on the home screen. One
  ticket = one branch = one MR; base branch is `feature/NER_list` until it
  merges into `develop` (the NER feature only exists there). Sections marked
  « A implementer plus tard » are backlog: do not implement them.

## Gotchas

- Confidence scoring (AI Act): docs root is `scoring_rayan/docs/`; `ConfidenceScore` is defined in `DataPipelines/AbstractModel.py`; scoring runs centrally in `ModelManager.infer()`; log format is `[CONFIDENCE] model=… score=… metadata=…`.
- `arcadedb_installation_path` in `config.ini` must be the home of the ArcadeDB instance
  actually listening on `address:port` — auth user lookup (`get_users()` reads
  `config/server-users.jsonl`), case backup, and case restore access that directory
  directly on disk while everything else goes over HTTP. If the two diverge, login
  fails with "doesn't exist" right after a successful register.


## Conventions

Match surrounding style; Comments in English. Prefer `config.ini` over
hardcoded constants.
