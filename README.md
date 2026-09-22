# dotfiles

Personal Linux environment config, managed as a symlink farm.
Targets zsh (default) and bash, with a modular layout shared by both.

## What's here

| Path | What |
|---|---|
| `.zshrc` / `.zprofile` | zsh entry points |
| `.bashrc` / `.bash_profile` | bash entry points |
| `.config/shell/` | Modular shell config (sourced by both zsh and bash): `path`, `exports`, `pyenv`, `aliases`, `functions`, `keybindings`, `prompt` |
| `.config/starship.toml` | Prompt theme |
| `.config/nvim/` | LazyVim config (+ `lazy-lock.json` for pinned plugin versions) |
| `.config/zellij/` | Zellij terminal multiplexer |
| `.config/atuin/` | Atuin (synced shell history) settings |
| `.gitconfig` | Shared git identity; machine-specific bits live in `~/.gitconfig.local` (untracked, auto-created) |

## Set up a new machine

```sh
git clone https://github.com/problemxl/dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
chsh -s "$(command -v zsh)"   # make zsh the login shell (if not already)
exec "$SHELL"
```

`install.sh` is idempotent — safe to re-run to pick up changes.
Anything it replaces is backed up to `~/.dotfiles-backup-<timestamp>/`.

## Expected tools

The config degrades gracefully if these are missing, but install them
for the full experience:

```sh
# Arch
pacman -S zsh neovim starship fzf fd ripgrep eza bat atuin zoxide zellij tmux git

# Debian/Ubuntu
apt install zsh neovim fzf ripgrep eza bat atuin zoxide git
# fd: apt package is `fd-find` (binary is `fdfind` — consider an alias)
```

- [pyenv](https://github.com/pyenv/pyenv) — Python versions (auto-detected)
- [atuin](https://atuin.sh) — run `atuin login` once to sync history

## Making changes

Edit files directly in `~/.dotfiles/` (they're symlinked into place),
then commit and push as usual.

## New machine checklist

1. Clone + run `install.sh` (above)
2. `git config --global credential.helper ...` into `~/.gitconfig.local`
3. `atuin login` + `gh auth login` as needed
4. Open nvim once to let lazy.nvim restore pinned plugins
