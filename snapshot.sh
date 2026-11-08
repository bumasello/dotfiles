#!/bin/bash
# Copia pra dentro do repo as configs que não dá pra versionar por symlink:
# ficam fora do $HOME (/etc, disco do Windows) ou o próprio programa reescreve
# o arquivo e quebraria o link. Chamado pelo auto-sync.sh antes do commit.
# Fonte ausente é ignorada em silêncio (outra máquina, /mnt/c desmontado).
cd ~/dotfiles || exit
WIN=/mnt/c/Users/Maze

snap() { [ -f "$1" ] && mkdir -p "$(dirname "$2")" && cp -p "$1" "$2"; }

snap /etc/wsl.conf                                   wsl/wsl.conf
snap "$WIN/.wslconfig"                               wsl/.wslconfig
snap ~/.config/systemd/user/dotfiles-sync.service    systemd/dotfiles-sync.service
snap ~/.config/systemd/user/dotfiles-sync.timer      systemd/dotfiles-sync.timer
snap ~/.gitconfig                                    git/.gitconfig
snap ~/.config/git/ignore                            git/ignore
snap "$WIN/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json" \
                                                     windows/windows-terminal-settings.json
snap "$WIN/AppData/Roaming/AltSnap/AltSnap.ini"      windows/altsnap.ini

# Editor que grava arquivo novo por cima (sed -i, write-and-rename) troca o
# symlink por arquivo comum, e o sync para de ver as mudanças sem avisar.
# Se isso acontecer, o arquivo vivo vira a versão do repo e o link volta.
relink() { [ -f "$1" ] && [ ! -L "$1" ] && cp -p "$1" "$2" && ln -sf ~/dotfiles/"$2" "$1"; }

relink ~/.zshrc                                      terminal/.zshrc
relink ~/.p10k.zsh                                   terminal/.p10k.zsh
relink ~/.tmux.conf                                  terminal/.tmux.conf

mkdir -p packages
pacman -Qqe > packages/pacman.txt 2>/dev/null
