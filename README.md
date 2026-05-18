# Arquitetura de Banco de Dados: Sistema de Varejo

### Objetivo do projeto

Modelagem e implementação de um banco de dados relacional em MySQL para um ambiente de supermercado. </br>
O foco desta arquitetura é garantir a integridade, possibilitar a auditoria de vendas por colaborador e fornecer dados estruturados para ações de marketing com foco na fidelização de clientes.

### **[Aqui está vídeo com a apresentação da modelagem](https://youtu.be/zW02oUcySv8?si=doddeyWNYHoHGymT)**

<hr>

##  Levantamento de Requisitos para a criação do sistema
Para a construção da arquitetura, foram mapeadas as seguintes perguntas-chave criadas por mim para simular a operação do varejo:

1. **Como você gostaria de cadastrar e identificar os clientes no banco?**
   * R: O cadastro principal deve ser feito usando o CPF como chave de busca, pois é um dado único por pessoa.
     
2. **E se o cliente não quiser informar o CPF, como o sistema lida com vendas anônimas?**  
   * R: A venda ocorre normalmente. O sistema deve permitir registrar a transação deixando o campo do cliente vazio (nulo), sem travar a operação do caixa. 

3. **Como gostaria de realizar e registrar a fidelização se o cliente for comprador recorrente?**  
   * R: O sistema deve ter um marcador na própria transação de venda. Por padrão a venda não é fidelizada, mas o caixa pode ativar essa marcação (verdadeiro/falso) no momento da compra caso os critérios sejam atingidos. 

4. **Se for realizado o cadastro completo, quais dados além do CPF o sistema deve guardar?**
   * R: O nome e a data de aniversário na tabela principal. Além disso, precisamos guardar de forma flexível (podendo haver mais de um) o contato, o e-mail e o endereço completo (logradouro, CEP, estado e país) em tabelas separadas para o marketing.
     
5. **Os produtos do supermercado são organizados por setor ou categoria?**  
   * R: Sim, são estritamente organizados por categorias. Temos açougue, frios, padaria, limpeza, etc. Todo produto deve estar vinculado a uma categoria específica. 

6. **Como deve ser o controle do armazenamento de mercadorias?**  
   * R: O sistema precisa de uma tabela para o controle de estoque geral e, principalmente, uma tabela de Lotes. A tabela de lotes vai rastrear a quantidade exata vinculada à data de validade daquele produto. 

7. **Quais dados os produtos precisam conter? Como lidar com produtos em promoção?**
   * R: O produto precisa de um código de barras, marca, nome, e valor atual. Sobre promoções: não quero tabelas separadas. O sistema deve registrar os "descontos" aplicados diretamente em uma tabela conectada à transação da venda, preservando o cadastro original do produto. 

8. **O sistema precisa rastrear os colaboradores que efetuam cada venda?**  
   * R: Sim. Toda venda tem que estar amarrada a um colaborador. O sistema precisa registrar o nome, CPF e a data de admissão de cada funcionário. 

9. **O sistema precisa conter hierarquia de cargo e acessos protegidos?** 
   * R: Sim, todo colaborador pertence a um cargo. Para segurança, a autenticação no sistema deve ser protegida por uma senha criptografada (hash) no cadastro de cada funcionário. 

10. **Uma venda pode ter múltiplos produtos diferentes? Como manter o histórico de preços?**  
   * R: Sim. Uma venda tem seu cabeçalho (data e valor total) e uma lista separada de "itens da venda". Essa lista deve salvar a quantidade comprada e "congelar" o valor cobrado no dia, para não perdermos o histórico financeiro se o produto ficar mais caro no futuro. 

11. **Quais meios de pagamento são aceitos e como o sistema deve registrá-los?**  
   * R: Ocorre por maquininhas podendo ser por Pix, Crédito ou Débito. O sistema deve permitir que uma mesma venda receba múltiplos métodos de pagamento (ex: metade no Pix, metade no dinheiro), fazendo o vínculo final para a emissão da nota fiscal. 

12. **O supermercado trabalha com fornecedores cadastrados? É necessário rastrear quais fornecedores abastecem cada produto?**
   * R: Sim. Precisamos manter o cadastro dos fornecedores com nome, CNPJ e contato. Um produto pode ser fornecido por mais de um fornecedor, então precisamos de uma tabela de vínculo entre os dois.

<hr>

## Documentação das Camadas

### 1. Modelo Conceitual

O sistema foi desenhado para espelhar a operação real do varejo, contendo as seguintes entidades principais:

- **Colaboradores:** Quem opera o sistema.
- **Clientes:** O alvo da fidelização.
- **Produtos & Estoque:** O que está sendo transacionado.
- **Vendas:** O evento que conecta o Cliente, o Produto e o Colaborador.
<div align="center">
  <img src="BRMODELO.png" width="100%">
</div>

### 2. Modelo Lógico

As regras de conexão aplicadas para garantir a integridade dos dados:

- Relacionamento **1:N** entre Colaborador e Vendas (Um colaborador faz várias vendas, garantindo a **auditoria**).
- Relacionamento **1:N** entre Cliente e Vendas e o Item da Venda (Garantindo histórico de compras).
- Tabela de **item_venda** (Relacionamento N:N entre Vendas e Produtos), contendo o "valor_venda" estático, garantindo o **congelamento de preço** histórico mesmo que o valor do produto mude na tabela principal.
<div align="center">
  <img src="ERR.png" width="100%">
</div>

### 3. Modelo Físico

- **SGBD:** MySQL
- **Arquivo:** O script completo de criação de tabelas (`CREATE TABLE`), e chaves estrangeiras (`FOREIGN KEY`) está disponível no arquivo `database_supermercado.sql` neste repositório.
<div align="center">
  <img src="FINAL.png" width="100%">
</div>

---

### Foco em Segurança e Confiabilidade do Sistema

- **Rastreabilidade:** Cada registro financeiro está inevitavelmente atrelado ao ID de um operador em uma hierarquia de acesso.
- **Prevenção de Anomalias:** O uso de chaves estrangeiras impede a exclusão acidental de produtos que já constam em vendas passadas.
