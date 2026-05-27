# Dotfiles Setup — New Machine

Configure les symlinks pour les CLAUDE.md de projet sur cette machine.

## Instructions

Pour chaque projet listé dans `~/dotfiles/claude/projects/` :

1. Cherche où ce projet existe sur cette machine avec `find ~ -maxdepth 6 -name <projet> -type d 2>/dev/null`
2. Si trouvé : crée le symlink `ln -s ~/dotfiles/claude/projects/<projet>/CLAUDE.md <chemin_trouvé>/CLAUDE.md` (ne pas écraser si le fichier existe déjà — demander d'abord)
3. Si non trouvé : note-le comme absent sur cette machine

À la fin, affiche un récapitulatif :
- ✓ Symlinks créés
- ✗ Projets non trouvés sur cette machine

## Projets

- `LLM_Bias` — pipeline biais LLMs, ethnicity × SES
