# ~/.config/zsh/05_init.zsh

# Initialize fzf keybindings and completions
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Initialize fnm (Node Version Manager)
eval "$(fnm env)"

# Initialize pyenv (Python Version Manager)
eval "$(pyenv init -)"

# Initialize Zoxide (smarter cd)
eval "$(zoxide init zsh)"
