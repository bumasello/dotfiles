#!/bin/bash
# Commita e dá push no que mudou. Roda pelo dotfiles-sync.timer a cada 15 min.
# ~/.claude (claude-config) e o vault (segundo-cerebro) são repos privados à
# parte; cada um só entra se existir nesta máquina.
sync_repo() {
  cd "$1" 2>/dev/null || return
  [ -d .git ] || return
  if [[ -n $(git status --porcelain) ]]; then
    git add -A
    git commit -m "auto-sync: $(date '+%Y-%m-%d %H:%M:%S')"
    git push
  fi
}

~/dotfiles/snapshot.sh
sync_repo ~/dotfiles
sync_repo ~/.claude
sync_repo /mnt/c/Users/Maze/SegundoCerebro
