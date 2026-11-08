#!/bin/bash
# Monta o setup numa máquina nova (Arch no WSL). Pode rodar de novo sem estragar:
# o que já está no lugar é pulado, e arquivo comum que seria trocado por link
# vira <arquivo>.bak-install antes.
#
# Antes de rodar, à mão (fica fora do repo porque é segredo):
#   1. ~/.ssh com a chave do GitHub   →  ssh -T git@github.com responde
#   2. git clone git@github.com:bumasello/dotfiles.git ~/dotfiles
#
# Uso: ~/dotfiles/install.sh [--pacotes]
#   --pacotes  instala antes a lista do packages/pacman.txt (pede sudo)
set -uo pipefail

D=~/dotfiles
WIN=/mnt/c/Users/Maze
CLAUDE_REPO=git@github.com:bumasello/claude-config.git

passo() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
aviso() { printf '\033[1;33m  ! %s\033[0m\n' "$*"; }
ok()    { printf '  ✓ %s\n' "$*"; }

# link <destino no $HOME> <origem dentro do repo>
link() {
  local alvo=$1 origem=$D/$2
  if [ "$(readlink "$alvo")" = "$origem" ]; then ok "$alvo"; return; fi
  mkdir -p "$(dirname "$alvo")"
  if [ -e "$alvo" ] && [ ! -L "$alvo" ]; then
    mv "$alvo" "$alvo.bak-install"
    aviso "$alvo existia; guardado como $alvo.bak-install"
  fi
  ln -sfn "$origem" "$alvo" && ok "$alvo → $origem"
}

# copia <origem dentro do repo> <destino>; só escreve se for diferente
copia() {
  local origem=$D/$1 alvo=$2
  if cmp -s "$origem" "$alvo"; then ok "$alvo"; return; fi
  mkdir -p "$(dirname "$alvo")"
  [ -e "$alvo" ] && cp -p "$alvo" "$alvo.bak-install"
  cp "$origem" "$alvo" && ok "$alvo (copiado)"
}

if [[ ${1:-} == --pacotes ]]; then
  passo "Pacotes do pacman"
  # o que sumiu dos repositórios oficiais não derruba o resto
  disponiveis=$(comm -12 <(sort "$D/packages/pacman.txt") <(pacman -Slq | sort -u))
  # shellcheck disable=SC2086
  sudo pacman -S --needed $disponiveis
  faltando=$(comm -23 <(sort "$D/packages/pacman.txt") <(pacman -Slq | sort -u))
  [ -n "$faltando" ] && aviso "fora dos repositórios (instalar à mão): $(echo $faltando)"
fi

passo "Symlinks"
link ~/.zshrc            terminal/.zshrc
link ~/.p10k.zsh         terminal/.p10k.zsh
link ~/.tmux.conf        terminal/.tmux.conf
link ~/.config/nvim      nvim

passo "Git"
# cópia, não link: o git config --global reescreve o arquivo e quebraria o link
copia git/.gitconfig ~/.gitconfig
copia git/ignore     ~/.config/git/ignore

passo "Plugins do tmux (TPM)"
if [ -d ~/.tmux/plugins/tpm ]; then
  ok "TPM já instalado"
else
  git clone -q https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && ok "TPM clonado"
fi
~/.tmux/plugins/tpm/bin/install_plugins >/dev/null && ok "plugins do .tmux.conf instalados"

passo "Claude Code (~/.claude, repo privado)"
if [ -d ~/.claude/.git ]; then
  ok "~/.claude já é o repo claude-config"
elif git ls-remote "$CLAUDE_REPO" >/dev/null 2>&1; then
  # ~/.claude pode já existir (login feito antes): o repo entra por cima,
  # sem apagar credencial nem histórico, que ficam fora do .gitignore
  tmp=$(mktemp -d)
  git clone -q --no-checkout "$CLAUDE_REPO" "$tmp/c"
  mkdir -p ~/.claude
  mv "$tmp/c/.git" ~/.claude/.git && rm -rf "$tmp"
  git -C ~/.claude checkout -q -f master && ok "~/.claude restaurado"
else
  aviso "sem acesso a $CLAUDE_REPO (chave SSH no GitHub?) — pulei"
fi

passo "Segundo Cérebro (vault, repo privado)"
VAULT=$WIN/SegundoCerebro
if [ ! -d /mnt/c ]; then
  ok "não é WSL, pulei"
elif [ -d "$VAULT/.git" ]; then
  ok "$VAULT já é o repo segundo-cerebro"
elif [ -e "$VAULT" ]; then
  aviso "$VAULT existe sem git; não mexi (junte à mão com o repo segundo-cerebro)"
elif git clone -q git@github.com:bumasello/segundo-cerebro.git "$VAULT"; then
  # NTFS mostra tudo como 777; sem isso o git acusa todo arquivo como alterado
  git -C "$VAULT" config core.fileMode false
  git -C "$VAULT" config core.autocrlf false
  ok "$VAULT clonado (abra a pasta como vault no Obsidian)"
else
  aviso "sem acesso ao repo segundo-cerebro (chave SSH no GitHub?) — pulei"
fi

passo "WSL"
if [ -d /mnt/c ]; then
  if cmp -s "$D/wsl/wsl.conf" /etc/wsl.conf; then
    ok "/etc/wsl.conf"
  else
    sudo cp "$D/wsl/wsl.conf" /etc/wsl.conf && ok "/etc/wsl.conf (vale depois de wsl --shutdown)"
  fi
  # no lado do Windows só cria o que não existe; nunca sobrescreve
  if [ -e "$WIN/.wslconfig" ]; then
    cmp -s "$D/wsl/.wslconfig" "$WIN/.wslconfig" && ok "$WIN/.wslconfig" \
      || aviso "$WIN/.wslconfig difere do repo; confira à mão"
  else
    cp "$D/wsl/.wslconfig" "$WIN/.wslconfig" && ok "$WIN/.wslconfig"
  fi
  aviso "Windows Terminal: copie windows/windows-terminal-settings.json à mão (o caminho muda por instalação)"
else
  ok "não é WSL, pulei"
fi

passo "Timer de sincronização"
copia systemd/dotfiles-sync.service ~/.config/systemd/user/dotfiles-sync.service
copia systemd/dotfiles-sync.timer   ~/.config/systemd/user/dotfiles-sync.timer
systemctl --user daemon-reload && systemctl --user enable --now dotfiles-sync.timer 2>/dev/null \
  && ok "dotfiles-sync.timer ativo" \
  || aviso "systemd de usuário indisponível; ligue systemd=true no wsl.conf e rode de novo"

passo "Fica por sua conta"
cat <<'EOF'
  - ~/.ssh/config, chaves e ~/.npmrc: vêm do backup cifrado, nunca do repo
  - tópico do ntfy do mazetick (~/.mazetick_ntfy_topic)
  - login do Claude Code (claude) e do gh (gh auth login)
  - abrir o zsh uma vez: o zinit baixa os plugins sozinho
  - abrir o nvim uma vez: o lazy.nvim e o mason instalam o resto
EOF
