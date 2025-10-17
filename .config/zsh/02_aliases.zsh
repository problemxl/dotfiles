# ~/.config/zsh/02_aliases.zsh

# Aliases should only be set for interactive shells
if [[ $- != *i* ]]; then
  return
fi

# Use lsd instead of the default ls command
alias ls='lsd'
alias l='lsd -l'
alias la='lsd -a'
alias lla='lsd -la'
alias lt='lsd --tree'

# Use fdfind if fd is not available
if ! command -v fd &> /dev/null; then
  alias fd='fdfind'
fi
