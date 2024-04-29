#!/usr/bin/env bash

# Script para contar quantos clientes existem em costumer_list.sh

# Verifica se o arquivo costumer_list.sh existe
if [ -f "customer_list.sh" ]; then
    # Conta o número de linhas que começam com "declare -A cliente"
    count_clientes=$(grep -c "^declare -A cliente" customer_list.sh)
    echo "$count_clientes"  # Imprime o número de clientes
else
    echo "Arquivo costumer_list.sh não encontrado."
    exit 1
fi

