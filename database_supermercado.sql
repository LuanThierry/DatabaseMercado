/*
bordas apenas dao fk 1:
cliente metodo_pagamento cargo categoria_produto fornecedor estoque

pais dao e recebem fk n:
venda, produto, colaborador

relacoes emendam multiplas fk n,n:
tbl_venda_pagamento, tbl_items_venda, tbl_fornecedor_produto, tbl_lote

dependentes apenas recebe fk 0:
cliente-{ contato endereço email } vendas-{ desconto } fornecedor-{ contato_fornecedor }
*/
drop database sistema_mercado;
create database sistema_mercado;
use sistema_mercado;

## BORDAS
create table tbl_cliente (
	id int not null primary key auto_increment,  
    cpf varchar(14) not null unique, 
    nome varchar(255) not null,
    data_aniversario date
);

create table tbl_metodo_pagamento (
	id int not null primary key auto_increment,  
	nome_metodo varchar(30) not null unique
);

create table tbl_cargo (
	id int not null primary key auto_increment,  
	hierarquia varchar(45) not null
);

create table tbl_categoria_produto (
	id int not null primary key auto_increment,  
	nome varchar(45) not null
);

create table tbl_fornecedor (
	id int not null primary key auto_increment,  
	nome varchar(45) not null,
    cnpj varchar(22) not null unique
);

create table tbl_estoque (
	id int not null primary key auto_increment,  
	quantidade int not null default 0
);



## PAIS 
create table tbl_colaborador(
	id int not null primary key auto_increment,
    id_cargo int not null,
    senha_hash varchar(64) not null,
    nome varchar(255),
    cpf varchar(15),
    data_admissao date, 
    
    constraint FK_id_cargo_colaborador
    foreign key(id_cargo) references tbl_cargo(id)
);

create table tbl_produto (
	id int not null primary key auto_increment,
    codigo varchar(50) not null unique,
    marca varchar(45), 
    nome varchar(140),
    valor decimal(10,2),
    id_categoria_produto int not null,
    
    constraint FK_id_categora_produto
    foreign key (id_categoria_produto) references tbl_categoria_produto(id)
);

create table tbl_venda (
	id int not null primary key auto_increment,
    id_cliente int, -- permite null para cliente anonimos!
    id_colaborador int not null, 
    data_venda datetime default current_timestamp, -- automatiza data!
    nota_fiscal varchar(47),
    fidelizado boolean default false, -- não fidelizado ate que se prove ao contrario 
    
    valor decimal(10,2),
    
    constraint FK_id_cliente_venda
    foreign key (id_cliente) references tbl_cliente(id),
    
    constraint FK_id_colaborador_venda
    foreign key (id_colaborador) references tbl_colaborador (id)
);


## RELAÇÕES  
create table tbl_venda_pagamento (
	id int not null primary key auto_increment,
    id_metodo int not null,
    id_venda int not null,
    
    constraint FK_id_venda_metodo
    foreign key (id_venda) references tbl_venda(id),
    
    constraint FK_id_metodo_venda
    foreign key (id_metodo) references tbl_metodo_pagamento(id)
);

create table tbl_item_venda (
	id int not null primary key auto_increment,
    id_produto int not null,
    id_venda int not null, 
    valor_venda decimal (10,2), -- congelo o preco na hora da VENDA
    quantidade_item int not null,
    
    constraint FK_item_produto
    foreign key (id_produto) references tbl_produto(id),
    
    constraint FK_item_venda
    foreign key (id_venda) references tbl_venda(id)
);

create table tbl_fornecedor_produto (
	id int not null primary key auto_increment,
    id_produto int not null,
    id_fornecedor int not null,
    
    constraint FK_fornecedor_produto 
    foreign key (id_produto) references tbl_produto(id),
    
    constraint FK_fornecedor_fornecedor
    foreign key (id_fornecedor) references tbl_fornecedor(id)
);

create table tbl_lote (
	id int not null primary key auto_increment, 
    quantidade int, 
    validade date not null, 
    id_estoque int not null, 
    id_produto int not null,
    
    constraint FK_lote_produto 
    foreign key (id_produto) references tbl_produto(id),
    
    constraint FK_lote_estoque 
    foreign key (id_estoque) references tbl_estoque(id)
);



## DEPENDENTES 
create table tbl_contato (
	id int not null primary key auto_increment,
    id_cliente int not null,
    contato varchar(45),
    
    constraint FK_id_cliente_contato
	foreign key (id_cliente) references tbl_cliente(id)
);

create table tbl_endereco (
	id int not null primary key auto_increment,
    id_cliente int not null,
	logradouro varchar(120),
    cep varchar(12),
    estado varchar(45),
    pais varchar(60),
    
    constraint FK_id_cliente_endereco
    foreign key (id_cliente) references tbl_cliente(id)
);

create table tbl_email (
	id int not null primary key auto_increment,
    id_cliente int not null,
    email varchar(254),
    
    constraint FK_id_cliente_email
	foreign key (id_cliente) references tbl_cliente(id)
);

create table tbl_desconto (
	id int not null primary key auto_increment,
    id_venda int not null, 
	desconto decimal(10,2),
	
    constraint FK_id_vendas_desconto
	foreign key (id_venda) references tbl_venda(id)
);

create table tbl_contato_fornecedor (
	id int not null primary key auto_increment,
    id_fornecedor int not null, 
	contato varchar(45),
	
    constraint FK_id_forncedor_contato
	foreign key (id_fornecedor) references tbl_fornecedor(id)
);

show tables;