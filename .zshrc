# =============================================================================
# 1. ENVIRONMENT & FRAMEWORK
# =============================================================================

# Add my custom functions folder to the function path
fpath=($HOME/.zsh/functions $fpath)

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set the Zsh theme
ZSH_THEME="agnoster"

# Set preferred editor
export EDITOR=nvim

# Set pager for man pages to use bat for colorization
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Oh My Zsh plugins
plugins=(
  git
  zsh-autosuggestions
  fzf-tab
  zsh-syntax-highlighting # NOTE: Must be the last plugin
)

# Load Oh My Zsh. This must be done BEFORE tool initializations.
source $ZSH/oh-my-zsh.sh

# =============================================================================
# 2. TOOL INITIALIZATIONS (fzf, pyenv, fnm, zoxide)
# =============================================================================

# Initialize fzf keybindings and completions
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# FZF global configuration for file previews
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='
  --height 60% --layout=reverse --border
  --preview "bat --color=always --style=numbers --line-range :500 {}"
  --bind "ctrl-/:toggle-preview"
'
# Initialize fnm (Node Version Manager)
FNM_PATH="/home/mark/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="/home/mark/.local/share/fnm:$PATH"
  eval "$(fnm env)"
fi

# Initialize pyenv (Python Version Manager)
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Initialize opencode
export PATH=/home/mark/.opencode/bin:$PATH

# Initialize Zoxide (smarter cd)
eval "$(zoxide init zsh)"

# =============================================================================
# 3. ALIASES & FUNCTIONS
# =============================================================================

# Aliases should only be set for interactive shells
if [[ $- == *i* ]]; then
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
fi

# --------------------------- Docker Functions --------------------------------

# Interactive Docker PS with FZF (fdps)
# Browse running docker containers and perform actions on them.
fdps() {
  # Define the command to get the formatted list of containers.
  local docker_command="docker ps --format '{{.ID}}\t{{.Names}}\t{{.Ports}}'"

  # Get the list of containers using the formatted command.
  local containers
  containers=$(eval "$docker_command")

  if [[ -z "$containers" ]]; then
    echo "No running containers."
    return
  fi

  echo "$containers" | fzf --height=50% --layout=reverse --border --no-preview \
    --header="[Ctrl-S] Stop | [Ctrl-R] Restart | [Ctrl-L] Logs | [Ctrl-E] Exec (Shell)" \
    --prompt="CONTAINERS > " \
    --preview='docker logs --tail 100 {1}' \
    --bind "ctrl-s:execute(docker stop {1})+reload($docker_command)" \
    --bind "ctrl-r:execute(docker restart {1})+reload($docker_command)" \
    --bind "ctrl-l:execute(docker logs -f {1})" \
    --bind "ctrl-e:execute-silent(docker exec -it {1} /bin/sh || docker exec -it {1} /bin/bash)+abort"
}

# --------------------------- System Functions --------------------------------

# Interactive Process Killer with FZF (fkill)
fkill() {
  local selected
  selected=$(ps -ef | fzf --height=40% --layout=reverse --border --no-preview \
    --prompt="PROCESSES > " \
    --header="Press Ctrl-K to kill the selected process" \
    --bind "ctrl-k:execute(kill -9 {2})+reload(ps -ef)")

  if [[ -n "$selected" ]]; then
    echo "$selected"
  fi
}

# --------------------------- SSH Functions -----------------------------------

# Interactive SSH Menu with FZF (fssh)
# Interactive SSH Menu with FZF (fssh)
fssh() {
  local hosts
  hosts=$(awk '/^Host / && $2 != "*" {print $2}' ~/.ssh/config)

  if [[ -z "$hosts" ]]; then
    echo "No SSH hosts found in ~/.ssh/config"
    return
  fi

  local selected_host
  # Changed the header and binding to use Ctrl-Y
  selected_host=$(echo "$hosts" | fzf --height=40% --layout=reverse --border --no-preview \
    --prompt="SSH > " \
    --header="[Enter] Connect | [Ctrl-Y] Copy SSH Key" \
    --bind "ctrl-y:execute(ssh-copy-id {})+abort")

  if [[ -n "$selected_host" ]]; then
    ssh "$selected_host"
  fi
}

# --------------------------- Zellij Functions --------------------------------

# Zellij session manager with fzf
zjf() {
  local PROJECT_DIRS=("~/Documents" "~/Downloads") # EDIT THIS
  autoload -U _zjf_previewer
  local search_paths=()
  for dir in "${PROJECT_DIRS[@]}"; do eval "search_paths+=($dir)"; done
  local sessions=$(zellij list-sessions --no-formatting)
  local projects
  projects=$(fd --type d --max-depth 2 . "${search_paths[@]}" 2>/dev/null | xargs -r -n 1 basename)
  local combined=$(printf '%s\n%s' "$sessions" "$projects" | sort -u)
  local choice
  choice=$(printf '%s' "$combined" | fzf --query="$1" \
    --height=40% --layout=reverse --border \
    --preview='_zjf_previewer {}' \
    --preview-window='right,40%,border-left')

  if [[ -n "$choice" ]]; then
    zellij attach --create "$choice"
  fi
}

# =============================================================================
# 4. HISTORY & KEYBINDINGS
# =============================================================================

# Smarter Zsh History settings
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE INC_APPEND_HISTORY SHARE_HISTORY

# FZF History Popup Widget
fzf-history-widget() {
  local history
  history=$(fc -l -n 1 | awk 'BEGIN { OFS = "\t" } {print NR, $0}' | tac | awk 'BEGIN { FS = "\t" } {print $2}')
  local selected_command
  selected_command=$(echo "$history" | fzf --height=60% --layout=reverse --border \
    --query="$LBUFFER" \
    --prompt="HISTORY > ")
  if [[ -n "$selected_command" ]]; then
    BUFFER="$selected_command"
  fi
  zle redisplay
}

# Register the function as a Zsh widget
zle -N fzf-history-widget
bindkey '^h' fzf-history-widget

# =============================================================================
# 5. AUTO-LAUNCH LOGIC (must be last)
# =============================================================================

# Auto-launch Zellij
if [[ -z "$ZELLIJ" ]]; then
  zellij attach --create main
fi
