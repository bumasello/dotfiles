# dotfiles

Meu setup de terminal: Arch Linux no WSL2, zsh + powerlevel10k, tmux e Neovim.
Os arquivos vivos no `$HOME` são symlinks para dentro deste repositório, e um
timer do systemd commita e dá push sozinho a cada 15 minutos. Por isso o
histórico é todo `auto-sync:`.

> Repositório público. Chave, token e senha nunca entram aqui.

## Máquina nova

1. Gere a chave SSH e cadastre no GitHub. O passo a passo está em
   [`terminal/chave-ssh-github.txt`](terminal/chave-ssh-github.txt). Se for
   restaurar uma chave antiga, ela vem do backup, não daqui.
2. Clone e rode o instalador:

   ```bash
   git clone git@github.com:bumasello/dotfiles.git ~/dotfiles
   ~/dotfiles/install.sh --pacotes
   ```

   Sem `--pacotes`, ele pula a instalação da lista do pacman.

O `install.sh` pode rodar quantas vezes quiser. Ele:

- cria os symlinks de `.zshrc`, `.p10k.zsh`, `.tmux.conf` e `~/.config/nvim`
  (o arquivo que estiver no caminho é guardado como `.bak-install`);
- copia `.gitconfig`, `git/ignore`, `/etc/wsl.conf` e o `.wslconfig` (este só
  se ainda não existir no Windows);
- instala o TPM e os plugins do tmux;
- restaura o `~/.claude` e o vault do Obsidian a partir dos repositórios
  privados, quando a chave tem acesso a eles;
- liga o timer de sincronização.

Depois disso, abra o zsh uma vez (o zinit baixa os plugins) e o nvim uma vez
(o lazy.nvim e o mason instalam o resto).

### O que o pacman não traz

| ferramenta | como instalar |
|---|---|
| pyenv | `git clone https://github.com/pyenv/pyenv ~/.pyenv` |
| uv | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| bun | `curl -fsSL https://bun.sh/install \| bash` |
| Node | `fnm install --lts` (o fnm vem do pacman) |
| Claude Code | `curl -fsSL https://claude.ai/install.sh \| bash` |
| win32yank | `win32yank.exe` em `/usr/local/bin` (clipboard do Windows no nvim) |
| EasyDotnet | `dotnet tool install -g EasyDotnet` (debug de C# no nvim) |
| Oracle Instant Client | 23.5 em `/opt/oracle/instantclient_23_5` |

Fica fora de propósito, porque tem segredo: `~/.ssh`, `~/.npmrc` e os logins
do `claude` e do `gh`.

## Como está organizado

| pasta | o quê | como chega na máquina |
|---|---|---|
| `terminal/` | `.zshrc`, `.p10k.zsh`, `.tmux.conf` | symlink |
| `nvim/` | config Lua do Neovim (lazy.nvim, LSP, DAP para C# e Java) | symlink de `~/.config/nvim` |
| `git/` | `.gitconfig` e o gitignore global | cópia |
| `wsl/` | `/etc/wsl.conf` e o `.wslconfig` do Windows | cópia |
| `windows/` | settings do Windows Terminal, AltSnap, PowerToys | à mão |
| `systemd/` | o timer `dotfiles-sync` | cópia |
| `packages/` | `pacman -Qqe`, regenerado a cada sync | lido pelo `install.sh --pacotes` |
| `arch-desktop/` | Hyprland, i3, waybar, polybar, rofi, wofi, picom, keyd, ghostty: o Arch em dual boot, sem uso no WSL | nenhum, fica de arquivo |

## Como a sincronização funciona

`dotfiles-sync.timer` roda o [`auto-sync.sh`](auto-sync.sh) 5 minutos após o
boot e depois a cada 15. O script:

1. roda o [`snapshot.sh`](snapshot.sh), que copia para o repo o que não pode
   ser symlink (arquivos fora do `$HOME`, ou reescritos pelo próprio programa)
   e regenera a lista do pacman;
2. refaz o symlink de `.zshrc`, `.p10k.zsh` e `.tmux.conf` se algum tiver
   virado arquivo comum, o que acontece quando um editor grava um arquivo novo
   por cima do link;
3. commita e dá push neste repo e nos dois privados (`~/.claude` e o vault),
   em cada um só se tiver mudança.

Para editar a config do shell, edite `~/dotfiles/terminal/.zshrc`
diretamente.
