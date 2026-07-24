# Dotfiles Setup — New Machine or Sync

## Instructions

1. **Vérifie si le repo dotfiles est à jour** :
   ```bash
   cd ~/dotfiles && git fetch && git status
   ```
   Si des commits sont en retard (`behind`), fais `git pull`.

2. **Vérifie le CLAUDE.md global** (`~/.claude/CLAUDE.md`) :
   - Il doit être un symlink vers `~/dotfiles/claude/CLAUDE.md`.
   - Si le symlink n'existe pas : crée-le avec `ln -s ~/dotfiles/claude/CLAUDE.md ~/.claude/CLAUDE.md`
   - Si le fichier existe déjà mais n'est pas un symlink : demande avant d'écraser
   - Vérifie aussi qu'il est bien suivi par git : `cd ~/dotfiles && git ls-files claude/CLAUDE.md`

3. **Vérifie le contexte machine** (`~/.claude/machine.md`) :
   - Le CLAUDE.md global l'importe via `@~/.claude/machine.md` ; ce doit être un symlink vers `~/dotfiles/claude/machines/<machine>.md` (`mac.md` si `uname` = Darwin, sinon `contabo.md`).
   - `sync.sh` le crée automatiquement ; à la main : `ln -s ~/dotfiles/claude/machines/contabo.md ~/.claude/machine.md`
   - Nouvelle machine : créer d'abord son fichier dans `~/dotfiles/claude/machines/` et adapter la sélection dans `sync.sh`.

4. **Pour chaque projet listé dans `## Projets`** :
   - Cherche où ce projet existe sur cette machine : `find ~ -maxdepth 6 -name <projet> -type d 2>/dev/null`
   - Si trouvé et que le symlink `<chemin>/CLAUDE.md` n'existe pas encore : crée-le avec `ln -s ~/dotfiles/claude/projects/<projet>/CLAUDE.md <chemin>/CLAUDE.md`
   - Si le fichier existe déjà mais n'est pas un symlink : demande avant d'écraser
   - Si non trouvé : note-le comme absent sur cette machine

5. **Affiche un récapitulatif** :
   - ✓ CLAUDE.md global : symlink OK / créé
   - ✓ Déjà à jour / mis à jour
   - ✓ Symlinks créés
   - ✗ Projets non trouvés sur cette machine

## Projets

- `idextend` — système RAG d'enquête judiciaire (Gendarmerie/CFIA), symlink dans `<repo>/.claude/CLAUDE.md` (pas à la racine)
- `LLM_Bias` — pipeline biais LLMs, ethnicity × SES
- `llm_bridage_modeles` — bridage LLM sur restitution de contenu sensible (idextend)
- `Manuscrit_M2` — mémoire M2 LaTeX, conformité AI Act des LLMs (biais + confiance), alternance idextend
- `Contabo` — doc des VPS (contabo neuf + vps ancien) : accès, sécurité, Tailscale, workflow Claude Code depuis l'iPhone
- `solar_pv` — projet M2 : prévision de la production solaire (dc_power) à partir de météo, dans le monorepo `Projets_M2`
- `blacky` — app Next.js de comptage entrées/boissons pour association ; règle : implémentation par `codex` uniquement, Claude (Fable) en revue
- `plongee` — backend API (FastAPI/uv) pour une app de plongée, clients web/iOS/Android prévus en projets séparés
