# ~/.zshrc — Omarchy-style
# Modular config lives in ~/.config/shell/ and is sourced below.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# ------------------------------------------------------------------
# History
# ------------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
HISTTIMEFORMAT='%F %T  '
setopt APPEND_HISTORY          # append (don't overwrite) the history file
setopt INC_APPEND_HISTORY      # write each line as it's entered
setopt SHARE_HISTORY           # share history between live sessions
setopt HIST_IGNORE_DUPS        # ignore consecutive duplicates
setopt HIST_IGNORE_ALL_DUPS    # purge older duplicate lines
setopt HIST_IGNORE_SPACE       # ignore lines that start with a space
setopt HIST_REDUCE_BLANKS      # trim superfluous whitespace
setopt HIST_VERIFY             # expand !-hist then edit, don't run blind

# ------------------------------------------------------------------
# Shell options
# ------------------------------------------------------------------
setopt AUTO_CD                 # cd by typing a directory name
setopt AUTO_PUSHD              # cd also pushes onto the dir stack
setopt PUSHD_IGNORE_DUPS       #   ...without dupes
setopt EXTENDED_GLOB           # powerful patterns (^, ~, (#c...), etc.)
setopt INTERACTIVE_COMMENTS    # allow '#' comments at the prompt
setopt NO_BEEP
setopt NO_FLOW_CONTROL         # free up Ctrl-S / Ctrl-Q

# ------------------------------------------------------------------
# Completion
# ------------------------------------------------------------------
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select                          # arrow-key menu
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # case-insensitive
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
setopt AUTO_MENU ALWAYS_TO_END

# ------------------------------------------------------------------
# Load modular config (shared with bash)
# ------------------------------------------------------------------
for file in ~/.config/shell/{path,exports,pyenv,aliases,functions,keybindings,prompt}; do
    [ -r "$file" ] && . "$file"
done
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
