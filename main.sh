#!/usr/bin/env bash
clear

# recebe a quantidade de clientes existentes em costumer_list.sh
count_clientes=$(source count_customers.sh)
# Verifica se o script count_customers.sh foi executado com sucesso
if [ $? -eq 1 ]; then
    echo "Erro ao contar clientes. O arquivo costumer_list.sh pode não existir."
    echo "inclua dados dos clientes arrays associativos em costumer_lis.sh"
    exit 1
fi


# Instalar o LibreOffice se não estiver instalado
if ! command -v libreoffice &> /dev/null; then
    echo "LibreOffice não está instalado. Instalando..."
    sudo apt-get update && sudo apt-get install -y libreoffice
fi

# Verifica se a entrada já existe no crontab
if ! crontab -l | grep -q "$(pwd)/main.sh"; then
    # Adiciona a entrada no crontab para executar o script no primeiro dia de cada mês
    (crontab -l ; echo "0 0 1 * * $(pwd)/main.sh cronfish") | crontab -
    echo "Entrada adicionada ao crontab para executar o script no primeiro dia de cada mês."
    sleep 1
    # Adiciona a entrada no crontab para executar o script no primeiro dia de cada mês as 9 horas
    (crontab -l ; echo "0 9 1 * * $(pwd)/crontab_ran.sh cronfish") | crontab -    
    sleep 1
    # Adiciona a entrada no crontab para executar o script no primeiro dia de cada mês as 14 horas
    (crontab -l ; echo "0 14 1 * * $(pwd)/crontab_ran_syslog.sh cronfish") | crontab -
fi
# se executar com [[$1 -eq cronfiss]]!!
if [[ $1 == "cronfish" ]]; then
    echo "$(date): Executado automaticamente pelo cron." >> "$(pwd)/log_crontab.txt"
fi

# Diretório de entrada (contendo arquivos .odt)
diretorio_entrada=$(pwd)"/arquivos"
# Verifica se a pasta do diretorio de entrada existe
if [ ! -d "$diretorio_entrada" ]; then
    printf "pasta : [%s] criada com sucessso." "$diretorio_entrada"
    mkdir "$diretorio_entrada"
fi

# Diretório principal do script
diretorio_principal=$(dirname "$0")

# Obtém o ano atual do sistema
ano_atual=$(date "+%Y")

# Arquivo para armazenar o ano atual
arquivo_ano_atual="$diretorio_entrada/$ano_atual"

# Verifica se a pasta do ano atual existe
if [ ! -d "$arquivo_ano_atual" ]; then
    printf "pasta Ano: [%s] criada com sucessso." "$ano_atual"
    mkdir "$arquivo_ano_atual"
fi

# Obtenha o mês atual
mes_atual_numeral=$(date "+%m")

# Obtenha o mês atual
mes_atual_texto=$(date +%B)

# Obtenha o mês atual
dia_atual=$(date +%d)

#define o nome do arquivo log
arquivo_log="log_mes.txt"

arquivo_mes_atual="$diretorio_entrada/$ano_atual/$mes_atual_numeral$mes_atual_texto"

if [ ! -d "$arquivo_mes_atual" ]; then
    printf "pasta do Mês: [%s] criada com sucessso." "$mes_atual_numeral$mes_atual_texto"
    mkdir "$arquivo_mes_atual"
fi

nome_arquivo="fantasia-Cobrança-mensal-Vencimento-dia_vencimento-ano-mes_atual.odt"
# Verifica se a pasta do diretorio de entrada existe
arquivo_modelo_odt="$diretorio_entrada/$nome_arquivo"
if [ ! -e "$arquivo_modelo_odt" ]; then
    printf "Arquivo Modelo: [%s] copiado com sucessso." "$nome_arquivo" 
    # Copia o arquivo modelo .odt para a pasta arquivos
    cp .file-model/fantasia-Cobrança-mensal-Vencimento-dia_atual-ano-mes_atual.odt arquivos/
fi

if [ ! -e "$arquivo_modelo_odt" ]; then
    printf "\narquivo %s não existe. Encerrado Sair\n" "$arquivo_modelo_odt"
    exit 1
fi

#------------------------------------------------
#Carregando a lista de clientes
source customer_list.sh
#------------------------------------------------


# Loop pelos arquivos .odt no diretório de entrada que altera o mês e gera o arquivo final .pdf
echo " $(date): Inicio. Substituir Dados de Clientes." >> "$arquivo_mes_atual/$arquivo_log"
substituir_dados_cliente() {
    local -n dados_cliente=$1
        # Verifica se o arquivo é um arquivo .odt
        [ -e "$arquivo_modelo_odt" ] || continue

        # Salva o nome do arquivo sem extensão
        nome_arquivo=$(basename "$arquivo_modelo_odt" .odt)

        # Cria um diretório temporário
        temp_dir=$(mktemp -d)

        # Extrai o conteúdo do arquivo .odt para o diretório temporário
        unzip -q "$arquivo_modelo_odt" -d "$temp_dir" >> "$arquivo_mes_atual/$arquivo_log"

        for chave in "${!dados_cliente[@]}"; do
            local valor="${dados_cliente[$chave]}"
            # Substitui a palavra antiga pela nova palavra em todos os arquivos de texto dentro do diretório temporário
            (temp_dir=$(sed "s|$chave|$valor|g" <<< "$temp_dir") && \
            find "$temp_dir" -type f -exec sed -i "s|$chave|$valor|g" {} +)
        done

        # Recria o arquivo .odt com o diretório temporário modificado
        arquivo_saida_odt="${arquivo_mes_atual}/${nome_arquivo}_modificado.odt"
        cd "$temp_dir" && zip -r "$arquivo_saida_odt" . >> "$arquivo_mes_atual/$arquivo_log"

        #Salva o nome do arquivo_saida_odt apenas para excluir ele após ser usado
        var_temp_name_arquivo="${arquivo_mes_atual}/${nome_arquivo}_modificado.odt"

        # Exporta o novo arquivo .odt para um arquivo .pdf
        soffice --headless --convert-to pdf --outdir "$arquivo_mes_atual" "$arquivo_saida_odt" >> "$arquivo_mes_atual/$arquivo_log"

        # Nome do arquivo PDF gerado
        arquivo_pdf_gerado="${arquivo_mes_atual}/${nome_arquivo}_modificado.pdf"

        # Cria um variavel temporário
        novo_nome_seed="$nome_arquivo"
        
        for chave in "${!dados_cliente[@]}"; do
            local valor="${dados_cliente[$chave]}"
            # Substitui a palavra antiga pela nova palavra no nome do arquivo PDF gerado, se necessário
            novo_nome_seed=$(echo "$novo_nome_seed" | sed "s|$chave|$valor|g")
        done

        novo_nome_pdf="${arquivo_mes_atual}/${novo_nome_seed}.pdf"

        mv "$arquivo_pdf_gerado" "$novo_nome_pdf"

        echo "Arquivo PDF gerado: $novo_nome_pdf" >> "$arquivo_mes_atual/$arquivo_log"

        # Limpa o diretório temporário
        rm -rf "$temp_dir"
        # Apaga o arquivo .odt cópia do original
        rm "$var_temp_name_arquivo"
}
porcentagem=$(echo 90/$count_clientes | bc)
valor_porcentagem=8
printf "\n [%s] Verificação dos dados e arquivos do sistema para inicio do sistema \n" "2.5%"  >> "$arquivo_mes_atual/$arquivo_log"
printf "\n [%s] aguarde \n" "2.5%"
for ((i=1; i<=$count_clientes; i++)); do
    printf "\n [%s] Convertendo arquivos em .pdf\n" "$valor_porcentagem%" >> "$arquivo_mes_atual/$arquivo_log"
    clear
    printf "\n [%s] aguarde \n" "$valor_porcentagem%"
    substituir_dados_cliente cliente$i
    valor_porcentagem=$(echo "$valor_porcentagem + $porcentagem" | bc)

done
printf "\n [%s] Convertendo arquivos em .pdf\n" "$valor_porcentagem%" >> "$arquivo_mes_atual/$arquivo_log"
clear
printf "\n [%s] aguarde \n" "$valor_porcentagem"
valor_porcentagem=$(echo "$valor_porcentagem + 2" | bc) 
printf "\n\n [%s] Limpando arquivos temporários\n" "$valor_porcentagem%" >> "$arquivo_mes_atual/$arquivo_log"
printf "\n $(date): [%s] Programa finalizado! \n\n" "ok." >> "$arquivo_mes_atual/$arquivo_log"
clear
printf "\n [%s] Programa finalizado! \n\n" "100%"