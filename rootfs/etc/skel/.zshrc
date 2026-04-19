# History
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY

# Navigation
setopt AUTO_CD

# Completion
autoload -Uz compinit
compinit

# Prompt
eval "$(starship init zsh)"
