# ~/.bashrc — Omarchy-style
# Modular config lives in ~/.config/shell/ and is sourced below.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# ------------------------------------------------------------------
# History
# ------------------------------------------------------------------
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=100000
HISTFILESIZE=100000
HISTTIMEFORMAT='%F %T  '
shopt -s histappend
# Record history after every command (not just on shell exit)
PROMPT_COMMAND="history -a; history -n; ${PROMPT_COMMAND}"

# ------------------------------------------------------------------
# Shell options
# ------------------------------------------------------------------
shopt -s autocd        # cd by typing a directory name
shopt -s globstar      # ** recurses
shopt -s checkwinsize  # update LINES/COLUMNS after each command
shopt -s cdspell       # minor cd typos autocorrect
shopt -s dirspell
shopt -s no_empty_cmd_completion

# ------------------------------------------------------------------
# Load modular config
# ------------------------------------------------------------------
for file in ~/.config/shell/{path,exports,pyenv,aliases,functions,keybindings,prompt}; do
    [ -r "$file" ] && . "$file"
done
