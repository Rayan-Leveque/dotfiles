# blacky — CLAUDE.md

App de comptage entrées/boissons pour association : « événements récurrents » configurables (catégories d’entrées et boissons avec prix optionnels en centimes — entité `EventType` en base), occurrences datées lancées depuis la config. Les actions sont journalisées dans `CountAction` et chaque appareil peut annuler **au choix** une de ses 10 dernières actions non annulées (pas de bouton -1) : le bouton « Annuler » ouvre un bottom sheet listant les actions de l'appareil (libellé + heure), l'API undo accepte un `actionId` optionnel (409 si autre appareil / déjà annulée / hors fenêtre). **Piège** : le sheet doit être rendu via `createPortal(document.body)` — l'UndoButton vit dans une barre sticky `z-40` (stacking context) et la nav du bas est `fixed z-50`, donc sans portal la nav intercepte les taps du bas du sheet quel que soit son z-index. La page Boissons a un mode « Offert » (bascule locale, désactivée après un verre) : l'increment accepte `offered:true`, colonnes `CountAction.offered` + `DrinkCounter.offeredCount`, recettes = `(value − offeredCount) × priceCents`, récap « dont X offerts ». La nav du bas a 3 onglets : Entrées, Boissons, Gestion. « Gestion » ouvre un mini-hub (`/a/{slug}/gestion`) à trois boutons : Récap (`/recap`, inclut la section Recettes — totaux € par soirée via l'API `/revenue` ; la page `/recettes` n'existe plus), Paramètres (`/config` : cartes des événements récurrents avec bouton Lancer, sous-pages `evenements/[id]`, `boissons` catalogue, `soiree` occurrence active) et Historique. Toute la zone gestion (gestion, config, recap, historique — route group `(gestion)`) est derrière un PIN 4 chiffres : champ `adminPin String?` sur Association (null = pas de barrière), gate client dans `(gestion)/layout.tsx` (déverrouillage mémorisé en sessionStorage), API `GET/POST /api/a/{slug}/verify-pin`. Pages Entrées et Boissons : compteur affiché sur chaque bouton, incrément optimiste SWR (pas de désactivation globale pendant le POST) ; `CounterButton` a des hauteurs fixes (h-24/h-32) pour des grilles alignées. Next.js 15 / TypeScript / Prisma / PostgreSQL. Spec Kit workflow dans `specs/001…005`, design system dans `DESIGN.md`.

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

## Push en prod (procédure éprouvée — a marché à chaque update des features 002 à 004)

`blacky_dev` **est la base de prod** : pendant le dev, les migrations ne s'appliquent qu'à `blacky_test` (`DATABASE_URL="$TEST_DATABASE_URL" npx prisma migrate deploy`). `blacky_dev` n'est migrée qu'au moment de la bascule, serveur arrêté. Ordre :

1. **Vérifier avant** : `npx tsc --noEmit` et `npx vitest run` verts.
2. **S'il y a une migration avec backfill** : relever les totaux sur `blacky_dev` via psql (`source .env` puis `psql "$DATABASE_URL" -c ...` — éviter `export $(grep ...)` et le quoting imbriqué, ça déclenche le classifieur de permissions) pour comparaison après.
3. **Build** : `npx next build` (l'ancien serveur peut tourner pendant le build — fenêtre d'incohérence d'assets courte et acceptable ; un build en échec avant la bascule = rien n'est cassé). Piège connu : un fichier `route.ts` qui exporte autre chose que des handlers casse le build — les helpers vont dans `src/lib/`.
4. **Stop** : `pgrep -f "next-serve[r]" | xargs -r kill` (le `[r]` est indispensable — sans lui le pattern matche le shell Bash-tool lui-même et tue la commande en cours, exit 144). Le classifieur auto-mode peut bloquer ce kill : demander l'autorisation à l'utilisateur, pré-acquise en général en début de session (voir mémoire `deploy-permission-kill`).
5. **Migrer** (seulement maintenant) : `npx prisma migrate deploy` (DATABASE_URL par défaut = blacky_dev). Vérifier les totaux post-migration vs relevé de l'étape 2.
6. **Start** : `nohup npx next start -H 0.0.0.0 -p 3000 > /tmp/blacky-next.log 2>&1 &` puis **lire le log** (`tail /tmp/blacky-next.log` : attendre `✓ Ready`, pas d'EADDRINUSE — un kill raté laisse l'ancien process servir un build périmé → ChunkLoadError côté client).
7. **Vérifier** : `curl` 200 sur la page et les routes clés, funnel public en 200, puis `npx playwright test` (la config `webServer.reuseExistingServer` fait tourner l'E2E contre le serveur fraîchement déployé ; il seed une association jetable dans blacky_dev et la supprime).

Migration additive (colonnes nullables) : la même séquence s'applique, c'est juste plus tolérant. Sans migration : sauter les étapes 2 et 5.

## Environnement

- PostgreSQL 16 local (port 5432), bases `blacky_dev` / `blacky_test`, rôle `blacky`. Connexion via `DATABASE_URL` de `.env` (peer auth désactivée pour ce rôle : toujours passer l'URL à `psql`).
- Accès utilisateur via Tailscale (`tailscale ip -4`) — les Artifacts claude.ai ne fonctionnent pas pour lui ; utiliser le skill projet `serve-tailscale` pour montrer des fichiers live.
- Exposition publique (activée 2026-07-17 pour partage) : Tailscale Funnel proxy le port 3000 sur `https://vmi3441682.tail6d4461.ts.net`. Désactiver : `sudo tailscale funnel --https=443 off`. Le funnel survit aux restarts de Next mais l'app n'a aucune auth à part le slug secret.
- L'`accessSlug` de l'association de test est sensible : le lire en base si besoin, ne pas le republier.
