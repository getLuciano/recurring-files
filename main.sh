#!/usr/bin/env bash
clear
# Instalar o LibreOffice se não estiver instalado
if ! command -v libreoffice &> /dev/null; then
    echo "LibreOffice não está instalado. Instalando..."
    sudo apt-get update && sudo apt-get install -y libreoffice
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

nome_arquivo="fantasia-Cobrança-mensal-Vencimento-dia_atual-ano-mes_atual.odt"
# Verifica se a pasta do diretorio de entrada existe
arquivo_modelo_odt="$diretorio_entrada/$nome_arquivo"
if [ ! -e "$arquivo_modelo_odt" ]; then
    printf "Arquivo Modelo: [%s] criado com sucessso." "$nome_arquivo" 
    # Cria um arquivo .odt usando o LibreOffice
    libreoffice --headless --convert-to odt --outdir "$diretorio_entrada" "$nome_arquivo"

    echo "Fantasia: fantasia" > "$arquivo_modelo_odt"
    echo "Dia de Vencimento:dia_vencimento" >> "$arquivo_modelo_odt"
    echo "
    Valor Total R$ valor_mes
    " >> "$arquivo_modelo_odt"
    echo "Razão Social: razao_social" >> "$arquivo_modelo_odt"
    echo "CNPJ: cnpj_cliente" >> "$arquivo_modelo_odt"
    echo "
    Endereço: endereco_cliente
    " >> "$arquivo_modelo_odt"
    echo "Mês: mes_atual" >> "$arquivo_modelo_odt"
    echo "Ano: ano" >> "$arquivo_modelo_odt"
    echo "Dia: dia_atual" >> "$arquivo_modelo_odt"

fi

if [ ! -e "$arquivo_modelo_odt" ]; then
    printf "\narquivo %s não existe. Encerrado Sair\n" "$arquivo_modelo_odt"
    exit 1
fi

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


printf "\nAguarde a conclusão do das edições em todos arquivos\n\n Leia o [ %s ] no diretório de saída dos pdfs\n\n" "$arquivo_log"
# Loop pelos arquivos .odt no diretório de entrada que altera o mês e gera o arquivo final .pdf
substituir_dados_cliente() {
    local -n dados_cliente=$1
        # Verifica se o arquivo é um arquivo .odt
        [ -e "$arquivo_modelo_odt" ] || continue

        # Salva o nome do arquivo sem extensão
        nome_arquivo=$(basename "$arquivo_modelo_odt" .odt)

        # Cria um diretório temporário
        temp_dir=$(mktemp -d)

        # Extrai o conteúdo do arquivo .odt para o diretório temporário
        unzip -q "$arquivo_modelo_odt" -d "$temp_dir"
        # >> "$arquivo_mes_atual/$arquivo_log"

        for chave in "${!dados_cliente[@]}"; do
            local valor="${dados_cliente[$chave]}"
            # Substitui a palavra antiga pela nova palavra em todos os arquivos de texto dentro do diretório temporário
            (temp_dir=$(sed "s|$chave|$valor|g" <<< "$temp_dir") && \
            find "$temp_dir" -type f -exec sed -i "s|$chave|$valor|g" {} +)
        done

        # Recria o arquivo .odt com o diretório temporário modificado
        arquivo_saida_odt="${arquivo_mes_atual}/${nome_arquivo}_modificado.odt"
        cd "$temp_dir" && zip -r "$arquivo_saida_odt" . 
        # >> "$arquivo_mes_atual/$arquivo_log"

        #Salva o nome do arquivo_saida_odt apenas para excluir ele após ser usado
        var_temp_name_arquivo="${arquivo_mes_atual}/${nome_arquivo}_modificado.odt"

        # Exporta o novo arquivo .odt para um arquivo .pdf
        soffice --headless --convert-to pdf --outdir "$arquivo_mes_atual" "$arquivo_saida_odt"
        # >> "$arquivo_mes_atual/$arquivo_log"

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

substituir_dados_cliente cliente1

substituir_dados_cliente cliente2

#clear
printf "Programa finalizado! \nSaiba mais sobre no history.log\n"