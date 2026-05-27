#!/bin/bash
# Lance Claude Code avec le prompt de sync dotfiles.
# Usage: ./sync.sh [chemin_projet]
set -e

DOTFILES="$HOME/dotfiles"

# S'assurer qu'on est bien dans le repo dotfiles
if [ ! -d "$DOTFILES/.git" ]; then
  echo "Erreur : $DOTFILES n'est pas un repo git."
  exit 1
fi

# Configurer le cron daily si pas encore en place
CRON_ENTRY="0 9 * * * cd ~/dotfiles && git pull --ff-only >> ~/dotfiles/sync.log 2>&1"
if ! crontab -l 2>/dev/null | grep -qF "dotfiles && git pull"; then
  (crontab -l 2>/dev/null; echo "$CRON_ENTRY") | crontab -
  echo "✓ Cron daily configuré (git pull à 9h)"
else
  echo "✓ Cron daily déjà en place"
fi

PROMPT="$(cat "$DOTFILES/setup.md")"

# Lancer Claude Code dans le dossier projet si fourni, sinon depuis dotfiles
TARGET="${1:-$DOTFILES}"
cd "$TARGET"

claude "$PROMPT"
