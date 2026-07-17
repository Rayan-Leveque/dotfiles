# blacky — CLAUDE.md

App de comptage entrées/boissons pour association. Next.js 15 / TypeScript / Prisma / PostgreSQL. Spec Kit workflow dans `specs/001-headcount-drink-tracking/`, design system dans `DESIGN.md`.

## Workflow d'implémentation (règle stricte)

**Toute implémentation de code dans ce repo doit être faite par `codex` (modèle `gpt-5.6-sol`), jamais par Claude directement. Claude (Fable) se limite à la revue du code produit.**

- Lancer codex via Bash avec `-s danger-full-access` (le sandbox bwrap est cassé dans ce container — permission pré-autorisée, voir mémoire `codex-orchestration-retex`).
- Prudence avec les agents multiples : si plusieurs sessions codex tournent en parallèle, surveiller la duplication de code entre sessions (problème déjà observé lors de l'implémentation initiale).
- Après implémentation codex, Fable relit le diff (audit léger : peu d'angles, une passe de lecture partagée — voir mémoire `audit-token-cost`).

## Commandes

- Tests : `npx vitest run` (intégration API, nécessite PostgreSQL local + `TEST_DATABASE_URL` dans `.env`)
- Typecheck : `npx tsc --noEmit`
- Build prod : `npx next build` puis `npx next start -H 0.0.0.0 -p 3000` (lié sur toutes les interfaces pour l'accès Tailscale)
- Le serveur tourne en mode production : après tout changement de code, rebuild + restart nécessaires pour le voir.
- Restart sûr : `pgrep -f next-server | xargs -r kill` puis relancer `next start` en nohup, puis **vérifier le log de démarrage** (piège déjà rencontré : sous zsh `kill $PID` multi-lignes ne tue rien → EADDRINUSE silencieux, l'ancien process sert un build périmé → ChunkLoadError côté client).

## Environnement

- PostgreSQL 16 local (port 5432), bases `blacky_dev` / `blacky_test`, rôle `blacky`. Connexion via `DATABASE_URL` de `.env` (peer auth désactivée pour ce rôle : toujours passer l'URL à `psql`).
- Accès utilisateur via Tailscale (`tailscale ip -4`) — les Artifacts claude.ai ne fonctionnent pas pour lui ; utiliser le skill projet `serve-tailscale` pour montrer des fichiers live.
- L'`accessSlug` de l'association de test est sensible : le lire en base si besoin, ne pas le republier.
