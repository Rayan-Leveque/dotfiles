# Dotfiles Setup — New Machine or Sync

## Instructions

1. **Vérifie si le repo dotfiles est à jour** :
   ```bash
   cd ~/dotfiles && git fetch && git status
   ```
   Si des commits sont en retard (`behind`), fais `git pull`.

2. **Pour chaque projet listé dans `## Projets`** :
   - Cherche où ce projet existe sur cette machine : `find ~ -maxdepth 6 -name <projet> -type d 2>/dev/null`
   - Si trouvé et que le symlink `<chemin>/CLAUDE.md` n'existe pas encore : crée-le avec `ln -s ~/dotfiles/claude/projects/<projet>/CLAUDE.md <chemin>/CLAUDE.md`
   - Si le fichier existe déjà mais n'est pas un symlink : demande avant d'écraser
   - Si non trouvé : note-le comme absent sur cette machine

3. **Affiche un récapitulatif** :
   - ✓ Déjà à jour / mis à jour
   - ✓ Symlinks créés
   - ✗ Projets non trouvés sur cette machine

## Projets

- `LLM_Bias` — pipeline biais LLMs, ethnicity × SES
