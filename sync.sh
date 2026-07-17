#!/bin/bash
# Sync dotfiles : git pull + symlinks CLAUDE.md des projets.
# Tout le travail idempotent est fait en bash. Claude n'est lancé
# qu'en dernier recours, si un conflit demande un jugement.
# Usage: ./sync.sh
set -e

DOTFILES="$HOME/dotfiles"

if [ ! -d "$DOTFILES/.git" ]; then
  echo "Erreur : $DOTFILES n'est pas un repo git."
  exit 1
fi

# --- Cron daily ---
CRON_ENTRY="0 9 * * * cd ~/dotfiles && git pull --ff-only >> ~/dotfiles/sync.log 2>&1"
if ! crontab -l 2>/dev/null | grep -qF "dotfiles && git pull"; then
  (crontab -l 2>/dev/null; echo "$CRON_ENTRY") | crontab -
  echo "✓ Cron daily configuré (git pull à 9h)"
else
  echo "✓ Cron daily déjà en place"
fi

# --- git pull (non bloquant si hors ligne) ---
cd "$DOTFILES"
if ! git fetch --quiet 2>/dev/null; then
  echo "⚠ git fetch a échoué (hors ligne ?) — on continue avec l'état local"
elif [ -n "$(git rev-list HEAD..@{u} 2>/dev/null)" ]; then
  git pull --ff-only
  echo "✓ Dotfiles mis à jour"
else
  echo "✓ Dotfiles déjà à jour"
fi

CONFLICTS=()

# --- CLAUDE.md global ---
GLOBAL_SRC="$DOTFILES/claude/CLAUDE.md"
GLOBAL_LINK="$HOME/.claude/CLAUDE.md"
if [ ! -f "$GLOBAL_SRC" ]; then
  echo "✗ global : pas de CLAUDE.md source dans dotfiles"
elif [ -L "$GLOBAL_LINK" ]; then
  echo "✓ global : déjà lié"
elif [ -e "$GLOBAL_LINK" ]; then
  echo "⚠ global : CLAUDE.md existe et n'est PAS un symlink → $GLOBAL_LINK"
  CONFLICTS+=("global|$GLOBAL_LINK|$GLOBAL_SRC")
else
  mkdir -p "$(dirname "$GLOBAL_LINK")"
  ln -s "$GLOBAL_SRC" "$GLOBAL_LINK"
  echo "✓ global : symlink créé → $GLOBAL_LINK"
fi

# --- Machine context (importé par le CLAUDE.md global via @~/.claude/machine.md) ---
if [ "$(uname)" = "Darwin" ]; then
  MACHINE_SRC="$DOTFILES/claude/machines/mac.md"
else
  MACHINE_SRC="$DOTFILES/claude/machines/contabo.md"
fi
MACHINE_LINK="$HOME/.claude/machine.md"
if [ ! -f "$MACHINE_SRC" ]; then
  echo "✗ machine : pas de source $MACHINE_SRC dans dotfiles"
elif [ -L "$MACHINE_LINK" ]; then
  echo "✓ machine : déjà lié"
elif [ -e "$MACHINE_LINK" ]; then
  echo "⚠ machine : machine.md existe et n'est PAS un symlink → $MACHINE_LINK"
  CONFLICTS+=("machine|$MACHINE_LINK|$MACHINE_SRC")
else
  mkdir -p "$(dirname "$MACHINE_LINK")"
  ln -s "$MACHINE_SRC" "$MACHINE_LINK"
  echo "✓ machine : symlink créé → $MACHINE_LINK"
fi

# --- Skills Claude ---
SKILLS_SRC="$DOTFILES/claude/skills"
SKILLS_LINK="$HOME/.claude/skills"
if [ -d "$SKILLS_SRC" ]; then
  if [ -L "$SKILLS_LINK" ]; then
    echo "✓ skills : déjà liés"
  elif [ -e "$SKILLS_LINK" ]; then
    echo "⚠ skills : $SKILLS_LINK existe et n'est PAS un symlink — à arbitrer manuellement"
  else
    mkdir -p "$HOME/.claude"
    ln -s "$SKILLS_SRC" "$SKILLS_LINK"
    echo "✓ skills : symlink créé → $SKILLS_LINK"
  fi
fi

# --- Symlinks projets ---
# Liste des projets : noms entre backticks sous la section "## Projets" de setup.md
PROJECTS=$(awk '/^## Projets/{f=1; next} f' "$DOTFILES/setup.md" \
  | grep -oE '`[^`]+`' | head -n 100 | tr -d '`')

for proj in $PROJECTS; do
  src="$DOTFILES/claude/projects/$proj/CLAUDE.md"
  if [ ! -f "$src" ]; then
    echo "✗ $proj : pas de CLAUDE.md source dans dotfiles"
    continue
  fi

  # Trouver le dossier projet sur la machine (hors copie interne dotfiles)
  dir=$(find "$HOME" -maxdepth 6 -name "$proj" -type d 2>/dev/null \
    | grep -v "$DOTFILES/" | head -n 1)

  if [ -z "$dir" ]; then
    echo "✗ $proj : non trouvé sur cette machine"
    continue
  fi

  link="$dir/CLAUDE.md"
  if [ -L "$link" ]; then
    echo "✓ $proj : déjà lié"
  elif [ -e "$link" ]; then
    echo "⚠ $proj : CLAUDE.md existe et n'est PAS un symlink → $link"
    CONFLICTS+=("$proj|$link|$src")
  else
    ln -s "$src" "$link"
    echo "✓ $proj : symlink créé → $link"
  fi
done

# --- Escalade vers Claude uniquement si conflit ---
if [ ${#CONFLICTS[@]} -gt 0 ]; then
  echo ""
  echo "⚠ ${#CONFLICTS[@]} conflit(s) détecté(s), lancement de Claude pour décider…"
  LISTE=""
  for c in "${CONFLICTS[@]}"; do
    IFS='|' read -r name link src <<< "$c"
    LISTE+="- $name : fichier existant $link  (source : $src)
"
  done
  PROMPT="Ces CLAUDE.md existent déjà et ne sont PAS des symlinks. Pour chacun, compare le fichier existant avec la source dotfiles, montre-moi les différences, puis demande-moi quoi faire (remplacer par un symlink, fusionner, ou ignorer). Ne fais rien sans ma validation.
$LISTE"
  if command -v yoloclaude &>/dev/null; then
    yoloclaude "$PROMPT"
  else
    claude "$PROMPT"
  fi
else
  echo ""
  echo "✓ Rien à arbitrer — sync terminé sans lancer Claude."
fi
