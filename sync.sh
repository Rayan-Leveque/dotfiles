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

PROMPT="$(cat "$DOTFILES/setup.md")"

# Lancer Claude Code dans le dossier projet si fourni, sinon depuis dotfiles
TARGET="${1:-$DOTFILES}"
cd "$TARGET"

claude "$PROMPT"
