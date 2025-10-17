#!/bin/bash
# install.sh

# Directory where this script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Directory to back up any existing dotfiles to
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d%H%M%S)"

# List of files/folders to symlink
files=(
    ".zshrc"
    ".config/zsh"
    # Add other files/folders here in the future
    # e.g., ".gitconfig"
    # e.g., ".config/nvim"
)

echo "Creating backup directory at $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

echo "Creating symlinks..."
for file in "${files[@]}"; do
    source_file="$DOTFILES_DIR/$file"
    dest_file="$HOME/$file"

    # If the destination already exists, back it up
    if [ -e "$dest_file" ]; then
        echo "Backing up existing $dest_file to $BACKUP_DIR"
        mv "$dest_file" "$BACKUP_DIR"
    fi

    # Create the symlink
    echo "Linking $source_file to $dest_file"
    # Ensure parent directory of dest_file exists
    mkdir -p "$(dirname "$dest_file")"
    ln -s "$source_file" "$dest_file"
done

echo "✅ Dotfiles installation complete."
