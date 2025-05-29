#!/bin/bash

flag="$HOME/.config/eww/lightlock"
eww_file="$HOME/.config/eww/eww.scss"
rofi_file="$HOME/.config/rofi/config.rasi"

if [ -f "$flag" ]; then
    [ -f "$eww_file" ] && sed -i -e 's/#e2e2e2/#252525/g' "$eww_file"
    [ -f "$rofi_file" ] && sed -i -e 's/#e2e2e2/#252525/g' "$rofi_file"

    [ -f "$eww_file" ] && sed -i -e 's/#d3d3d3/#1a1a1a/g' "$eww_file"

    [ -f "$eww_file" ] && sed -i -e 's/#f5f5f5/#111111/g' "$eww_file"
    [ -f "$rofi_file" ] && sed -i -e 's/#f5f5f5/#111111/g' "$rofi_file"

    for file in "$eww_file" "$rofi_file"; do
        [ -f "$file" ] && sed -i -e 's/white/DUMMY/g' -e 's/black/white/g' -e 's/DUMMY/black/g' "$file"
    done

    [ -f "$eww_file" ] && sed -i -e 's/#c5c5c5/#1b1b1b/g' "$eww_file"
    [ -f "$rofi_file" ] && sed -i -e 's/#c5c5c5/#1b1b1b/g' "$rofi_file"

    [ -f "$eww_file" ] && sed -i -e 's/#464646/#d6d6d6/g' "$eww_file"
    [ -f "$rofi_file" ] && sed -i -e 's/#464646/#d6d6d6/g' "$rofi_file"

    rm -f "$flag"
else
    [ -f "$eww_file" ] && sed -i -e 's/#111111/#f5f5f5/g' "$eww_file"
    [ -f "$rofi_file" ] && sed -i -e 's/#111111/#f5f5f5/g' "$rofi_file"

    [ -f "$eww_file" ] && sed -i -e 's/#1a1a1a/#d3d3d3/g' "$eww_file"

    [ -f "$eww_file" ] && sed -i -e 's/#252525/#e2e2e2/g' "$eww_file"
    [ -f "$rofi_file" ] && sed -i -e 's/#252525/#e2e2e2/g' "$rofi_file"

    for file in "$eww_file" "$rofi_file"; do
        [ -f "$file" ] && sed -i -e 's/white/DUMMY/g' -e 's/black/white/g' -e 's/DUMMY/black/g' "$file"
    done

    [ -f "$eww_file" ] && sed -i -e 's/#1b1b1b/#c5c5c5/g' "$eww_file"
    [ -f "$rofi_file" ] && sed -i -e 's/#1b1b1b/#c5c5c5/g' "$rofi_file"

    [ -f "$eww_file" ] && sed -i -e 's/#d6d6d6/#464646/g' "$eww_file"
    [ -f "$rofi_file" ] && sed -i -e 's/#d6d6d6/#464646/g' "$rofi_file"

    touch "$flag"
fi

pkill rofi