#!/usr/bin/env bash
# install.sh — symlink dotfiles from this repo into $HOME.
#
# Safe to re-run: existing links are kept, real files are backed up.

set -u

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d%H%M%S)"
BACKED_UP=0

# Everything in the repo that should be linked into $HOME
FILES=(
    ".zshrc"
    ".zprofile"
    ".bashrc"
    ".bash_profile"
    ".gitconfig"
    ".config/shell"
    ".config/starship.toml"
    ".config/zellij"
    ".config/atuin"
    ".config/nvim"
)

link() {
    local rel="$1"
    local src="$DOTFILES_DIR/$rel" dst="$HOME/$rel"

    if [ ! -e "$src" ]; then
        echo "skip    $rel (missing in repo)"
        return
    fi

    mkdir -p "$(dirname "$dst")"

    # Already linked to this repo — nothing to do
    if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
        echo "ok      $rel (already linked)"
        return
    fi

    # Back up anything that would be clobbered (file, dir, or stale link)
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
        mv "$dst" "$BACKUP_DIR/$rel"
        BACKED_UP=1
        echo "backup  $rel -> $BACKUP_DIR/$rel"
    fi

    ln -s "$src" "$dst"
    echo "linked  $rel"
}

# --- main -----------------------------------------------------------

echo "Installing dotfiles from $DOTFILES_DIR\n"

for f in "${FILES[@]}"; do
    link "$f"
done

# Clean up links left over from the previous repo layout
if [ -L "$HOME/.config/zsh" ] && [[ "$(readlink "$HOME/.config/zsh")" == "$DOTFILES_DIR"* ]]; then
    rm "$HOME/.config/zsh"
    echo "removed stale link .config/zsh (old layout)"
fi

# Machine-local git config — created once, never touched again
if [ ! -e "$HOME/.gitconfig.local" ]; then
    cat > "$HOME/.gitconfig.local" <<'EOF'
# ~/.gitconfig.local — machine-specific git settings (not tracked)
# Example:
# [credential]
#     helper = /usr/bin/git-credential-manager
EOF
    echo "created ~/.gitconfig.local (put machine-specific git settings there)"
fi

echo
if [ "$BACKED_UP" -eq 1 ]; then
    echo "Backups of replaced files: $BACKUP_DIR"
fi
echo "Done. Restart your shell:  exec \$SHELL"
