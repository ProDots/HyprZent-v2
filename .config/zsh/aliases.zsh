# Navegación
alias ..='cd ..'
alias ...='cd ../..'

# Listado
alias ls='ls --color=auto'
alias ll='ls -lh'
alias la='ls -lha'

# Zsh & configuración
alias config='cd ~/.config'
alias zshconfig='nvim ~/.config/zsh/.zshrc'
alias reload='exec zsh'

# Sistema
alias update='sudo pacman -Syu'
alias ports='ss -tuln'
