#!/bin/bash

# Calcular correctamente la cantidad de días del mes actual
monthlength=$(date -d "$(date +%Y-%m-01) +1 month -1 day" +%d)

# Arrays para los días inválidos al inicio según el día de la semana
endpadding=("1\" :class \\\"invalidday\\\"" "2\" :class \\\"invalidday\\\"" "3\" :class \\\"invalidday\\\"" "4\" :class \\\"invalidday\\\"" "5\" :class \\\"invalidday\\\"" "6\" :class \\\"invalidday\\\"" "7\" :class \\\"invalidday\\\"" "8\" :class \\\"invalidday\\\"" "9\" :class \\\"invalidday\\\"" "10\" :class \\\"invalidday\\\"" "11\" :class \\\"invalidday\\\"")
su=()
mo=("31\" :class \\\"invalidday\\\"")
tu=("30\" :class \\\"invalidday\\\"" "31\" :class \\\"invalidday\\\"")
we=("29\" :class \\\"invalidday\\\"" "30\" :class \\\"invalidday\\\"" "31\" :class \\\"invalidday\\\"")
th=("28\" :class \\\"invalidday\\\"" "29\" :class \\\"invalidday\\\"" "30\" :class \\\"invalidday\\\"" "31\" :class \\\"invalidday\\\"")
fr=("27\" :class \\\"invalidday\\\"" "28\" :class \\\"invalidday\\\"" "29\" :class \\\"invalidday\\\"" "30\" :class \\\"invalidday\\\"" "31\" :class \\\"invalidday\\\"")
sa=("26\" :class \\\"invalidday\\\"" "27\" :class \\\"invalidday\\\"" "28\" :class \\\"invalidday\\\"" "29\" :class \\\"invalidday\\\"" "30\" :class \\\"invalidday\\\"" "31\" :class \\\"invalidday\\\"")

# Obtener la fecha y datos actuales
current_date=$(date +%A)
day_number=$(date +%-d)
month_name=$(date +%B)
first_date=$(date +%Y-%m-01)
day_name=$(date --date="$first_date" +%A | cut -c1-2)

# Generar días del mes
declare -a days
for (( i=1; i<=monthlength; i++ )); do
    if [ "$i" -eq "$day_number" ]; then
        days+=("${i}\" :class \\\"currentday\\\"")
    else
        days+=("${i}\"")
    fi
done

# Añadir días inválidos iniciales según el día en que empieza el mes
case "$day_name" in
    "Fr") days=("${fr[@]}" "${days[@]}") ;;
    "Su") days=("${su[@]}" "${days[@]}") ;;
    "Mo") days=("${mo[@]}" "${days[@]}") ;;
    "Tu") days=("${tu[@]}" "${days[@]}") ;;
    "We") days=("${we[@]}" "${days[@]}") ;;
    "Th") days=("${th[@]}" "${days[@]}") ;;
    "Sa") days=("${sa[@]}" "${days[@]}") ;;
esac

# Añadir padding al final
days=("${days[@]}" "${endpadding[@]}")

# Enviar a Eww
eww update calendarliteral="(box :orientation \"v\" :space-evenly \"false\" :spacing 20 \
    (box :class \"daynames\" :orientation \"h\" :space-evenly \"false\" :spacing 35 :halign \"center\" \
        (label :text \"Su\")(label :text \"Mo\")(label :text \"Tu\")(label :text \"We\")(label :text \"Th\")(label :text \"Fr\")(label :text \"Sa\") \
    ) \
    (box :class \"calendardays\" :orientation \"v\" :spacing 40 :halign \"center\" \
        (box :space-evenly \"true\" :orientation \"h\" :halign \"center\" :spacing 36 \
            (label :text \"${days[0]}\")(label :text \"${days[1]}\")(label :text \"${days[2]}\")(label :text \"${days[3]}\")(label :text \"${days[4]}\")(label :text \"${days[5]}\")(label :text \"${days[6]}\") \
        ) \
        (box :space-evenly \"true\" :orientation \"h\" :halign \"center\" :spacing 36 \
            (label :text \"${days[7]}\")(label :text \"${days[8]}\")(label :text \"${days[9]}\")(label :text \"${days[10]}\")(label :text \"${days[11]}\")(label :text \"${days[12]}\")(label :text \"${days[13]}\") \
        ) \
        (box :space-evenly \"true\" :orientation \"h\" :halign \"center\" :spacing 36 \
            (label :text \"${days[14]}\")(label :text \"${days[15]}\")(label :text \"${days[16]}\")(label :text \"${days[17]}\")(label :text \"${days[18]}\")(label :text \"${days[19]}\")(label :text \"${days[20]}\") \
        ) \
        (box :space-evenly \"true\" :orientation \"h\" :halign \"center\" :spacing 36 \
            (label :text \"${days[21]}\")(label :text \"${days[22]}\")(label :text \"${days[23]}\")(label :text \"${days[24]}\")(label :text \"${days[25]}\")(label :text \"${days[26]}\")(label :text \"${days[27]}\") \
        ) \
        (box :space-evenly \"true\" :orientation \"h\" :halign \"center\" :spacing 36 \
            (label :text \"${days[28]}\")(label :text \"${days[29]}\")(label :text \"${days[30]}\")(label :text \"${days[31]}\")(label :text \"${days[32]}\")(label :text \"${days[33]}\")(label :text \"${days[34]}\") \
        ) \
        (box :space-evenly \"true\" :orientation \"h\" :halign \"center\" :spacing 36 \
            (label :text \"${days[35]}\")(label :text \"${days[36]}\")(label :text \"${days[37]}\")(label :text \"${days[38]}\")(label :text \"${days[39]}\")(label :text \"${days[40]}\")(label :text \"${days[41]}\") \
        ) \
    ) \
)"