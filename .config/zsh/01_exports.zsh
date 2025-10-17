# ~/.config/zsh/01_exports.zsh

# Set preferred editor
export EDITOR=nvim

# Use bat as the man page pager for colorization
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# FZF global configuration for file previews
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='
  --height 60% --layout=reverse --border
  --preview "bat --color=always --style=numbers --line-range :500 {}"
  --bind "ctrl-/:toggle-preview"
'

# Set path for fnm (Node Version Manager)
export PATH="/home/mark/.local/share/fnm:$PATH"

# Set path for Pyenv (Python Version Manager)
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# Set path for opencode
export PATH="/home/mark/.opencode/bin:$PATH"

# Zsh History settings
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE INC_APPEND_HISTORY SHARE_HISTORY
