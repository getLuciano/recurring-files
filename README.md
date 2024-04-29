# Arquivos recorrentes, odt para pdf.

Automação de arquivos mensais recorrentes. Gere arquivos .pdf em grande escala  a partir de um arquivo modelo.odt.

Use o arquivo modelo que será gerado em arquivos/ para você personalizá-lo como precisar. Assim você irá conseguir um, ou varios .pdf(s). 

# Personalização 
O local para inserir o arquivo modelo é na pasta arquivos/, o nome padrão do arquivo deve ser: "fantasia-Cobrança-mensal-Vencimento-dia_vencimento-ano-mes_atual.odt". Assim o script irá alterar o nome do arquivo .pdf para "SEU CLIENTE-Cobrança-mensal-Vencimento-10-2024-04.pdf"
Edite o arquivo arquivos/modelo.odt, inserindo sua logo, endereço, dados importante do seu negócio no cabeçalho. No Corpo do arquivo insira as tags para ser gerados os dados variáveis de cobrança de acordo a lista de cliente, as tags são: fantasia, dia_vencimento, valor_mes, descricao_servico, multa_atraso, site, razao_social, cnpj_cliente, endereco_cliente, mes_atual, ano, dia_atual. Esses dados estão em um array associativo que irá identificar a tag e vai retornar o valor. Para adicionar e editar os clientes edite o arquivo costumer_list.sh (atualmente existe apenas dois arrays associativos nesta lista, não esqueça de chamar o array associativo no final do arquivo main.sh)

# Instalação 
Aonde você executar o git-clone será a pasta principal do projeto ""
~ chmod +x main.sh count_customers.sh

# Execução
~ ./main.sh
