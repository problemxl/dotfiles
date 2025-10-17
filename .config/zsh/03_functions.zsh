# ~/.config/zsh/03_functions.zsh

# Add my custom functions folder to the function path
fpath=($HOME/.zsh/functions $fpath)

# --------------------------- Docker Functions ---------------------------
# Interactive Docker PS with FZF (fdps)
fdps() {
  local docker_command="docker ps --format '{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}'"
  local containers
  containers=$(eval "$docker_command")

  if [[ -z "$containers" ]]; then
    echo "No running containers."
    return
  fi

  echo "$containers" | fzf --height=50% --layout=reverse --border \
    --header="[Ctrl-S] Stop | [Ctrl-R] Restart | [Ctrl-L] Logs | [Ctrl-E] Exec Shell" \
    --prompt="CONTAINERS > " \
    --preview='docker logs --tail 100 {1}' \
    --bind "ctrl-s:execute(docker stop {1})+reload($docker_command)" \
    --bind "ctrl-r:execute(docker restart {1})+reload($docker_command)" \
    --bind "ctrl-l:execute(docker logs -f {1})" \
    --bind "ctrl-e:execute-silent(docker exec -it {1} /bin/sh || docker exec -it {1} /bin/bash)"
}

# --------------------------- System Functions ---------------------------
# Interactive Process Killer with FZF (fkill)
fkill() {
  ps -ef | fzf --height=40% --layout=reverse --border \
    --prompt="PROCESSES > " \
    --header="Press Ctrl-K to kill the selected process" \
    --bind "ctrl-k:execute(kill -9 {2})+reload(ps -ef)"
}

# --------------------------- SSH Functions ------------------------------
# Interactive SSH Menu with FZF (fssh)
fssh() {
  local hosts
  hosts=$(awk '/^Host / && $2 != "*" {print $2}' ~/.ssh/config)

  if [[ -z "$hosts" ]]; then
    echo "No SSH hosts found in ~/.ssh/config"
    return
  fi

  local selected_host
  selected_host=$(echo "$hosts" | fzf --height=40% --layout=reverse --border \
    --prompt="SSH > " \
    --header="[Enter] Connect | [Ctrl-Y] Copy SSH Key" \
    --bind "ctrl-y:execute(ssh-copy-id {})+abort")

  if [[ -n "$selected_host" ]]; then
    ssh "$selected_host"
  fi
}

# --------------------------- Zellij Functions ---------------------------
# Zellij session manager with fzf
zjf() {
  # EDIT THIS array with your primary project directories
  local PROJECT_DIRS=("~/Work" "~/Documents" "~/Downloads")
  autoload -U _zjf_previewer # Ensure the previewer function is available
  
  local search_paths=()
  for dir in "${PROJECT_DIRS[@]}"; do eval "search_paths+=($dir)"; done
  
  local sessions=$(zellij list-sessions --no-formatting)
  local projects
  projects=$(fd --type d --max-depth 2 . "${search_paths[@]}" 2>/dev/null)
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

# Helper previewer function for zjf. Consider placing in a separate file if it grows.
_zjf_previewer() {
  if [[ -d "$1" ]]; then
    lsd --tree --depth=2 "$1"
  else
    echo "Zellij Session: $1"
  fi
}
