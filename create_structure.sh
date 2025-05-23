#!/bin/bash

echo "Creando estructura de Hyprland Godmode..."

mkdir -p \
.config/{hypr,waybar/modules,zsh/plugins/{zsh-autosuggestions,zsh-syntax-highlighting},mako,wlogout,rofi/launchers,swaylock,kitty/themes,swappy,fastfetch/{modules,logos}} \
scripts/{system,waybar,zsh} \
themes/{global,hyprland,waybar,zsh} \
system/{env,cache}

touch \
.config/hypr/{hyprland.conf,keybinds.conf,monitors.conf,windowrules.conf,env.conf,styles.conf,startup.conf} \
.config/waybar/{config.jsonc,style.css} \
.config/waybar/modules/{hypr-workspaces.js,aura-pkgs.sh,cpu-temp.custom} \
.config/zsh/{.zshrc,.zshenv,aliases.zsh,functions.zsh} \
.config/mako/{config,style.css} \
.config/wlogout/{layout,style.css} \
.config/rofi/{config.rasi,custom.rasi} \
.config/rofi/launchers/{power-menu.rasi,ssh-launcher.rasi} \
.config/swaylock/{config,style.css} \
.config/kitty/{kitty.conf} \
.config/kitty/themes/{dark.conf,light.conf} \
.config/swappy/config \
.config/fastfetch/{config.json} \
.config/fastfetch/modules/{custom-hypr.conf,aura-pkgs.json} \
.config/fastfetch/logos/{main-logo.ascii,mini-logo.ascii} \
scripts/system/{apply-themes,hypr-reload,aura-pkg-sync} \
scripts/waybar/{update-modules,workspaces-manager} \
scripts/zsh/{zsh-theme-switcher,history-cleanup} \
themes/global/{colors-dark.conf,colors-light.conf} \
themes/hyprland/{animations.conf,window-styles.conf} \
themes/waybar/{dark.css,light.css} \
themes/zsh/{prompt-dark.zsh,prompt-light.zsh} \
system/env/{hypr.env,theme.env} \
system/cache/{waybar-modules.cache,zsh-history} \
nuclear-launch-codes

echo "Estructura creada con éxito."
