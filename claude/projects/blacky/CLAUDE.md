# blacky — CLAUDE.md

App de comptage entrées/boissons pour association, avec types de soirée configurables (prix optionnels en centimes par article), occurrences datées et catégories d’entrées. Les actions sont journalisées dans `CountAction` et chaque appareil peut annuler ses dernières actions (pas de bouton -1). Totaux en euros sur la page cachée `/a/{accessSlug}/recettes` (hors navigation, lien discret en bas de la config). Next.js 15 / TypeScript / Prisma / PostgreSQL. Spec Kit workflow dans `specs/001-headcount-drink-tracking/`, `specs/002-event-types-undo/` et `specs/003-prices-ui-density/`, design system dans `DESIGN.md`.

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
- Restart sûr : `pgrep -f "next-serve[r]" | xargs -r kill` puis relancer `next start` en nohup, puis **vérifier le log de démarrage**. Deux pièges déjà rencontrés : (1) sous zsh `kill $PID` multi-lignes ne tue rien → EADDRINUSE silencieux, l'ancien process sert un build périmé → ChunkLoadError côté client ; (2) le pattern sans `[r]` matche la ligne de commande du shell Bash-tool lui-même → le kill tue la commande en cours (exit 144) avant le relancement.

## Environnement

- PostgreSQL 16 local (port 5432), bases `blacky_dev` / `blacky_test`, rôle `blacky`. Connexion via `DATABASE_URL` de `.env` (peer auth désactivée pour ce rôle : toujours passer l'URL à `psql`).
- Accès utilisateur via Tailscale (`tailscale ip -4`) — les Artifacts claude.ai ne fonctionnent pas pour lui ; utiliser le skill projet `serve-tailscale` pour montrer des fichiers live.
- Exposition publique (activée 2026-07-17 pour partage) : Tailscale Funnel proxy le port 3000 sur `https://vmi3441682.tail6d4461.ts.net`. Désactiver : `sudo tailscale funnel --https=443 off`. Le funnel survit aux restarts de Next mais l'app n'a aucune auth à part le slug secret.
- L'`accessSlug` de l'association de test est sensible : le lire en base si besoin, ne pas le republier.
