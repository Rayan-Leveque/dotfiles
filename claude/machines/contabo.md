# Machine : VPS contabo

Tu es sur le **VPS Contabo** (Ubuntu 24.04, 6 vCPU / 12 Go RAM, SSH port 2222, hostname `vmi3441682`). IP Tailscale : `100.116.111.35` ; l'iPhone de l'utilisateur est sur le même tailnet (`iphone175`, 100.123.186.68).

- L'utilisateur se connecte le plus souvent **depuis l'iPhone via Termius/mosh over Tailscale**, dans `tmux new -A -s main`. Le terminal n'affiche pas d'images.
- **Les Artifacts claude.ai ne se chargent pas pour lui via Tailscale.** Pour montrer un fichier/page live : servir en HTTP lié à l'IP Tailscale (`python3 ~/bin/serve_utf8.py <port> 100.116.111.35` — force le charset UTF-8, sinon mojibake sur Safari), ou `SendUserFile`. **Vérifier d'abord les ports occupés** : `ps aux | grep http.server | grep -v grep` (plusieurs serveurs tournent en permanence, ex. 8080 sur ~/Postuler ; un port pris donne un 404 trompeur).
- Notifications push ntfy configurées (`~/.claude/settings.json` + `~/.claude/hooks/ntfy.sh`, événements Stop/Notification). Ne jamais publier le nom du topic.
- Sandbox bwrap de `codex exec` cassée dans ce conteneur → seule option fonctionnelle : `-s danger-full-access` (nécessite une règle de permission ajoutée par l'utilisateur). Smoke test : `bwrap --unshare-all echo test`.
- `~/Postuler` existe en double (Mac + VPS) : `git pull` en début de session, `git push` à la fin.

Doc complète (accès, sécurité, workflow iPhone, confort) : `~/dotfiles/claude/projects/Contabo/CLAUDE.md`.
