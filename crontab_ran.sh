#!/usr/bin/env bash

# Verifica se o CRONTAB conseguiu executar com o script [[$1 -eq cronfiss]]!!
if [[ $1 == "cronfish" ]]; then
    echo "$(date): Executado automaticamente pelo cron. CRONTAB_RAN" >> "$(pwd)/log_crontab.txt"
    # Verifica se a entrada já existe no crontab
    if ! crontab -l | grep -q "$(pwd)/crontab_ran.sh"; then
        # Adiciona a entrada no crontab para executar o script no primeiro dia de cada mês as 9 horas
        (crontab -l ; echo "0 9 1 * * $(pwd)/crontab_ran.sh cronfish") | crontab -
    fi

    # Verifica se o arquivo de log foi atualizado nas últimas 24 horas
    if [[ $(find "$(pwd)/log_crontab.txt" -mtime -1) ]]; then
        echo "$(date): CRONTAB-RAN: O arquivo de log [ log_crontab.txt ] foi atualizado nas últimas 24 horas." >> "$(pwd)/log_crontab.txt"

    else
        echo "$(date): CRONTAB-RAN EXECUTION: O arquivo de log [ log_crontab.txt ] NÃO foi atualizado nas últimas 24 horas." >> "$(pwd)/log_crontab.txt"
        ./main.sh
    fi

fi