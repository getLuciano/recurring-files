#!/usr/bin/env bash

# Verifica se o CRONTAB conseguiu executar com o script [[$1 -eq cronfiss]]!!
if [[ $1 == "cronfish" ]]; then
    echo "$(date): Executado automaticamente pelo cron. CRONTAB_RAN_SYSLOG" >> "$(pwd)/log_crontab.txt"
    # Verifica se a entrada já existe no crontab
    if ! crontab -l | grep -q "$(pwd)/crontab_ran_syslog.sh"; then
        # Adiciona a entrada no crontab para executar o script no primeiro dia de cada mês as 14 horas
        (crontab -l ; echo "0 14 1 * * $(pwd)/crontab_ran_syslog.sh cronfish") | crontab -
    fi

    # Verifica se o arquivo de log foi atualizado nas últimas 24 horas
    if grep -q "crontab_ran_syslog.sh" /var/log/syslog; then
        echo "$(date): CRONTAB-RAN-SYSLOG: A tarefa foi executada nas últimas 24 horas." >> "$(pwd)/log_crontab.txt"

    else
        echo "$(date): CRONTAB-RAN-SYSLOG EXECUTION: A tarefa NÃO foi executada nas últimas 24 horas." >> "$(pwd)/log_crontab.txt"
        ./main.sh
    fi
fi