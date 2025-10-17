# ~/.config/zsh/04_keybindings.zsh

# FZF History Popup Widget
fzf-history-widget() {
  local selected_command
  selected_command=$(fc -l -n 1 | fzf --height=60% --layout=reverse --border \
    --query="$LBUFFER" \
    --prompt="HISTORY > ")
    
  if [[ -n "$selected_command" ]]; then
    BUFFER="$selected_command"
  fi
  zle redisplay
}

# Register the function as a Zsh widget
zle -N fzf-history-widget

# Bind Ctrl+H to the history widget
bindkey '^h' fzf-history-widget
