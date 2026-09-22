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

## SSH access (logging in to these machines)

`~/.ssh/authorized_keys` is tracked here (public keys only — safe), linked
by `install.sh`. Add a new device's key to `.ssh/authorized_keys`, commit,
push, then re-run `install.sh` on each machine.

Per machine (as root) enable the server + harden:

```sh
ssh-keygen -A                                  # generate host keys if missing
systemctl enable --now sshd
cp ~/.dotfiles/sshd/50-hardening.conf /etc/ssh/sshd_config.d/  # key-only auth
systemctl reload sshd
```

The private key lives only on the client machine:

```sh
ssh-keygen -t ed25519 -C "you@device"
cat ~/.ssh/id_ed25519.pub   # paste into .ssh/authorized_keys
```

### Per-device keys (recommended)

One keypair per device — losing a device means revoking one line, not
re-keying everything. Store private keys in your password manager
(Bitwarden/Vaultwarden SSH agent) or `~/.ssh/`; commit each device's
**public** key as `.ssh/keys/<device>.pub` plus a matching line in
`.ssh/authorized_keys`. Host blocks in `.ssh/config` reference the pubkey
file (`IdentityFile`), and the local agent supplies the private half.
Env-to-env: use `ProxyJump` (see `.ssh/config`) so no private key ever
sits on a server.

### Secrets on envs

Machine secrets (API keys, tokens) come from Infisical — never from this
repo. The `infi` shell function (`.config/shell/functions`) wraps it:

```sh
export INFI_PROJECT=<your-project-slug>
infi dev -- python app.py     # runs with dev secrets injected
```
