# Buscar en el historial
histgrep() {
  history 0 | grep --color=auto "$1"
}

# Crear y entrar a un directorio
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Buscar procesos
psearch() {
  ps aux | grep -i "$1" | grep -v grep
}
