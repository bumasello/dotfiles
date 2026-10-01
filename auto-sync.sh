#!/bin/bash
cd ~/dotfiles || exit
./snapshot.sh
if [[ -n $(git status --porcelain) ]]; then
  git add -A
  git commit -m "auto-sync: $(date '+%Y-%m-%d %H:%M:%S')"
  git push
fi
