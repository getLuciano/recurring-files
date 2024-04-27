#!/usr/bin/env bash

# Definindo as variáveis para cada cliente
declare -A cliente1=(
    ["fantasia"]="FANTASIA 2"
    ["dia_vencimento"]="25"
    ["valor_mes"]="500,00"
    ["multa_atraso"]="15,60"
    ["site"]="www.site.com.br"
    ["razao_social"]="RAZÃO SOCIAL DA EMPRESA LTDA"
    ["cnpj_cliente"]="10.000.000/0001-00"
    ["endereco_cliente"]="Endereço do Cliente, 0110 - *******, CEP 00000-000, BAIRRO, CIDADE, ESTADO"
    ["mes_atual"]="$mes_atual_texto"
    ["ano"]="$ano_atual"
    ["dia_atual"]="$dia_atual"
)


declare -A cliente2=(
    ["fantasia"]="FANTASIA"
    ["dia_vencimento"]="15"
    ["valor_mes"]="1000,00"
    ["multa_atraso"]="19,60"
    ["site"]="www.site.com"
    ["razao_social"]="RAZÃO SOCIAL DA EMPRESA LTDA"
    ["cnpj_cliente"]="10.000.000/0001-50"
    ["endereco_cliente"]="Endereço do Cliente, 1001 - *******, CEP 00000-000, BAIRRO, CIDADE, ESTADO"
    ["mes_atual"]="$mes_atual_texto"
    ["ano"]="$ano_atual"
    ["dia_atual"]="$dia_atual"
)

