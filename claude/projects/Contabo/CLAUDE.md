# VPS Contabo — Claude Code nomade

Contexte : VPS Contabo configuré le 2026-07-15 pour faire tourner Claude Code depuis l'iPhone en voyage. Ce dossier (`~/Documents/VPS/Contabo` sur le Mac) ne contient que les mails Contabo (PDF) et cette doc.

## Les deux serveurs

| Alias ssh | IP publique | IP Tailscale | Rôle |
|---|---|---|---|
| `contabo` | 169.58.20.136 | 100.116.111.35 | Nouveau — Claude Code nomade (6 vCPU, 12 Go RAM, 96 Go) |
| `vps` | 217.160.249.176 | — | Ancien (petit) — TeXLive, Maven, .NET, bench-* |

Les deux : Ubuntu 24.04, user `rayan` (sudo NOPASSWD), **port 2222**, clé uniquement (root et mots de passe désactivés). Alias définis dans `~/.ssh/config` du Mac.

## Sécurité (contabo)

- ufw : seuls 2222/tcp et 60000:61000/udp (mosh) ouverts ; fail2ban actif (jail sshd, ban 1h) ; unattended-upgrades
- Config sshd : `/etc/ssh/sshd_config.d/00-hardening.conf` (le nommer `00-` est voulu : dans sshd, la *première* valeur gagne)
- Clés autorisées : Mac (`id_ed25519`) + iPhone (`iphone-termius`)
- Tailscale actif (tailnet Google rayaneaoo@) ; l'iPhone y est aussi (`iphone175`, 100.123.186.68)

## Environnement (contabo, cloné depuis l'ancien vps)

- zsh + oh-my-zsh (autosuggestions, syntax-highlighting), nvm + Node 24, uv, tmux, mosh
- Claude Code installé via l'installeur natif (`~/.local/bin/claude`), **connecté au compte**
- `~/.zshenv` exporte `~/.local/bin` dans le PATH (nécessaire pour `ssh contabo claude` non-interactif)
- Scripts : `~/bin/codemac`, `~/.local/bin/yoloclaude`
- spec-kit (GitHub) installé sur Mac + contabo : `specify init . --integration claude` dans un projet → commandes `/speckit.specify`, `/speckit.plan`, `/speckit.tasks`, `/speckit.implement`… (màj : `uv tool upgrade specify-cli`)
- `~/dotfiles` cloné (clé GitHub propre au serveur), cron 9h de `git pull`, `bash ~/dotfiles/sync.sh` pour relier les CLAUDE.md
- `~/Postuler` cloné (aussi sur le Mac : `~/Documents/ADM_CLAUDE/Postuler`) — **git pull en début de session, push à la fin**, sinon les deux copies divergent

## Workflow iPhone (Termius, gratuit)

1. Host Termius : 169.58.20.136, port 2222, user rayan, clé `iphone`
2. Se connecter → `tmux new -A -s main` → `claude`
   (idéalement mettre `tmux new -A -s main` en Startup Snippet du host)
3. Détacher : `Ctrl+b d` (barre d'outils Termius pour Ctrl) ; fermer l'app ne tue rien
4. Host de secours via Tailscale : 100.116.111.35, port 2222 (passe les réseaux qui bloquent les ports exotiques)

## Voir des fichiers/images depuis l'iPhone

Le terminal n'affiche pas d'images. Serveur de fichiers privé (visible uniquement via Tailscale, rien d'exposé publiquement) :

```bash
tmux new -d -s files "cd ~/Postuler && python3 -m http.server 8080 --bind 100.116.111.35"
```

Puis Safari iPhone → `http://100.116.111.35:8080`. Arrêt : `tmux kill-session -t files`. Peut rester allumé en permanence sans risque.

## Confort système (2026-07-15)

- contabo : swap 4 Go (`/swapfile`, swappiness 10), timezone Europe/Paris
- tmux (les deux serveurs) : `mouse on` (scroll tactile dans Termius), historique 50k lignes
- Mosh actif côté iPhone (gratuit dans Termius, toggle « Use Mosh », commande `mosh-server`)
- Fix PATH `.zshenv` appliqué sur les deux serveurs (`ssh <host> claude` fonctionne partout)

## Notifications push (ntfy)

Sur contabo, hooks Claude Code (`~/.claude/settings.json` + `~/.claude/hooks/ntfy.sh`) :
- `Notification` (Claude attend une permission / idle) → push priorité haute
- `Stop` (tâche terminée) → push normale
- Topic ntfy.sh : `rayan-claude-8735dc46` (nom aléatoire = seul rempart, ne pas le publier). App ntfy sur l'iPhone abonnée à ce topic.

## En attente / à savoir

- ⚠️ Clé DeepSeek : retirée des `.zshenv` mais **pas encore révoquée** sur platform.deepseek.com (elle a fuité en transcript). Les pipelines LLM_Bias / llm_bridage_modeles (ancien vps) lisent `DEEPSEEK_API_KEY` — prévoir un `.env` projet si relance.
- Ancien vps : sudo demande un mot de passe (pas de NOPASSWD) ; timezone encore en UTC
- Non répliqué sur contabo : TeXLive, Maven, .NET, bench-claude/bench-opencode
