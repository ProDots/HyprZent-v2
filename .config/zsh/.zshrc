# Inicializa Starship
eval "$(starship init zsh)"

# Opciones de Zsh
setopt prompt_subst autocd correct share_history hist_ignore_all_dups

# Historial
HISTFILE="$HOME/.config/zsh/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

# Completado
autoload -Uz compinit && compinit

# Cargar alias y funciones personalizados
[[ -f "$ZDOTDIR/aliases.zsh" ]] && source "$ZDOTDIR/aliases.zsh"
[[ -f "$ZDOTDIR/functions.zsh" ]] && source "$ZDOTDIR/functions.zsh"
