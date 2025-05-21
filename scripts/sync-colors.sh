#!/usr/bin/env bash
WAL_CSS="${HOME}/.cache/wal/colors.css"
[[ -f "$WAL_CSS" ]] && cp "$WAL_CSS" config/waybar/colors.css && echo "✅ Colores sincronizados." || echo "⚠️ No se encontró colors.css"
