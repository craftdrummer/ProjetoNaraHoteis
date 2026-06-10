-- Script VERSAO: v:1.07.01  - Atualisado em 10 06 2026
-- CARREGAMENTO DEPURADO DO BANCO
-- CARGA do BANCO DE DADOS NaraHoteis
-- 
-- Rede Hoteleira do Estado do Rio de Janeiro
-- 12 Unidades | 4 Regiões | 6 Bases de Dados

-- Scrip para criação do Banco de Dados e tabelas 
-- a partir de uma base de dados pre definida 
-- OBS. 1 : IMPORACAO DE DADOS:
 -- importar os dados exatamente nesta ordem para evitar erros de 
 --    dependencia de chaves estrangeiras:
 -- 1. unidades, tipos_quarto, canais_venda e clientes (tabelas base)
 -- 2. funcionarios (depende de unidades)
 -- 3. reservas (deve ser a última, pois depende de todas as outras).
 -- O banco de dados normalmente é criado pelo Mysql na pasta abaixo:
 -- 	C:\ProgramData\MySQL\MySQL Server 8.0\Data\NaraHoteis
 --     =======================================================
 -- e as tabelas para Upload por default definido pelo sistema, precisam estar na pasta :
 --		C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/
 --     C:\Users\luis.accampora\SENAC-UC2-Projeto\Projeto-NaraHoteis\ 
 --     =======================================================
 -- OBS. 2 : Eu executei cada comando individualmente para ir depurando os possiveis erros, 
 --      e gerando as tabelas
 --      e deixei alguns comandos como SELECT , TRUNCATE TABLE , DROP TABLE para manipular os dados, 
 --      para rodar o script todo de uma vez basta tirar esses comandos 
 --      e deixar os CREATE, USE e LOAD DATA.
 --      Qualquer duvida entre em contato comigo.
 --
DROP DATABASE NaraHoteis;     -- DELETA TODO BANCO DE DADOS

CREATE DATABASE NaraHoteis;     -- Usado apenas para CRIAR o banco (DATABASE) de dados vazio

USE NaraHoteis;     			-- Usado para SELECIONAR o banco para USO nos comando SCRIPT abaixo.

-- ########################################################################### 
-- Criação das tabelas de dados, definição das chave e campos
-- ########################################################################### 

CREATE TABLE unidades (           -- Se a tabela ainda nai existir Cria tabela dentro do DATABASE , se ja existir retorna erro
                                  -- com as definicoes iniciais de cada campo
id_unidade 			INT  PRIMARY KEY,
nome_unidade		VARCHAR(100) NOT NULL,
cidade				VARCHAR(50),
regiao				VARCHAR(50),
categoria_hotel  	VARCHAR(15),
num_quartos_total 	INT
);

CREATE TABLE tipos_quarto (
    id_tipo_quarto	 		INT PRIMARY KEY  NOT NULL,    
	descricao				VARCHAR(15) NOT NULL,
	capacidade_max			INT,
	valor_diaria_base 	   	DECIMAL(8,2) NOT NULL
    );

CREATE TABLE canais_venda (
    id_canal	 		INT PRIMARY KEY   NOT NULL,
	nome_canal			VARCHAR(20) NOT NULL,
	comissao_pct 	   	DECIMAL(4,2) NOT NULL
    );

CREATE TABLE clientes (
id_cliente    		INT  PRIMARY KEY,
nome          		VARCHAR(100) NOT NULL,
cidade_origem 		VARCHAR(50),
estado_origem 		CHAR(02),
faixa_etaria  		VARCHAR(07),
tipo_cliente  		VARCHAR(15)
);

CREATE TABLE funcionarios (
    id_funcionario 	INT PRIMARY KEY    NOT NULL,
    id_unidade  	INT NOT NULL,
    nome          	VARCHAR(100) NOT NULL,
    cargo          	VARCHAR(20) NOT NULL,
    departamento   	VARCHAR(20) NOT NULL,
    salario 	   	DECIMAL(10,2),
    data_admissao	DATE,
    FOREIGN KEY (id_unidade) REFERENCES unidades (id_unidade)
);

CREATE TABLE reservas (
    id_reserva	 		INT PRIMARY KEY  NOT NULL,
    id_unidade			INT  NOT NULL,
    id_tipo_quarto  	INT NOT NULL,
    id_cliente			INT NOT NULL,
    id_canal			INT,
    data_checkin		DATE,
    data_checkout		DATE,
    qtd_diarias			INT NOT NULL,
    num_hospedes		INT,
	avaliacao_hospede   INT,
	status_reserva		VARCHAR(20) NOT NULL,
	forma_pagamento     VARCHAR(20) NOT NULL,
    -- CHAVES ESTRANGEIRAS 
    FOREIGN KEY (id_unidade)      REFERENCES unidades (id_unidade),
    FOREIGN KEY (id_tipo_quarto)  REFERENCES tipos_quarto (id_tipo_quarto),
    FOREIGN KEY (id_cliente)      REFERENCES clientes (id_cliente),
    FOREIGN KEY (id_canal)        REFERENCES canais_venda (id_canal)
    );


-- ######################################################

-- chave de seguranca para poder acessar dados da maquina local
SET GLOBAL local_infile = 1;   				-- Habilitar o carregamento de dados localmente com LOAD DATA LOCAL INFILE
SHOW VARIABLES LIKE 'secure_file_priv';     -- Mostra em qual pasta do seu sistema o MySQL tem permissão para ler ou salvar arquivos.


-- ########################################################################### 
-- IMPORTACAO das tabelas de dados .csv, copiar os arquivos na pasta abaixo
 --		C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/   -- Pasta de uploads do Mysql
-- ########################################################################### 
--
-- 1. IMPORTAR PRIMEIRO as TABELAS BASE (Não que possuem dependências)
SELECT * FROM unidades LIMIT 10;
DELETE FROM unidades WHERE id_unidade > 0 ;

-- LOAD DATA INFILE  'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Unidades auditado.csv'
-- LOAD DATA INFILE  C:/Users/luis.accampora/SENAC-UC2-Projeto/Projeto-NaraHoteis/Unidades auditado.csv'

LOAD DATA INFILE  'C:/Users/luis.accampora/SENAC-UC2-Projeto/Projeto-NaraHoteis/Unidades auditado.csv'
INTO TABLE unidades
FIELDS TERMINATED BY ';'          -- Identifica a vírgula como separador de colunas
-- LINES TERMINATED BY '\n'          -- Define a quebra de linha o padrao Linux/Unix e '\n'  (se usar no Windows e falhar, mude para '\r\n')
LINES TERMINATED BY '\n'        -- Padrao quebra de linha do Windows exadecimal (0D 0A)   
IGNORE 1 LINES                    -- Pula a primeira linha de cabeçalho
(id_unidade, nome_unidade, cidade, regiao, categoria_hotel, num_quartos_total);

-- ######################################################################################
SELECT * FROM tipos_quarto LIMIT 10; 
TRUNCATE TABLE tipos_quarto;    -- deleta todos os registros
DELETE FROM tipos_quarto WHERE id_tipo_quarto > 0 ;
DROP     TABLE tipos_quarto;	 -- Exclui a tabela do banco de dados

-- LOAD DATA INFILE   'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/tipos_quarto auditado.csv'
LOAD DATA INFILE   "C:/Users/luis.accampora/SENAC-UC2-Projeto/Projeto-NaraHoteis/Tipos de Quarto auditado.csv"
INTO TABLE tipos_quarto
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- ######################################################################################
SELECT * FROM canais_venda ; 
TRUNCATE TABLE canais_venda;
DELETE FROM canais_venda WHERE id_canal > 0 ;

LOAD DATA INFILE   'C:/Users/luis.accampora/SENAC-UC2-Projeto/Projeto-NaraHoteis/canais de venda auditado.csv'
INTO TABLE canais_venda
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- ######################################################################################
SELECT * FROM clientes LIMIT 10;    -- ler os 10 primeiros registro de uma tabela cliente

SELECT id_cliente, nome, cidade_origem FROM clientes   LIMIT 10;
TRUNCATE TABLE  clientes;
DELETE FROM clientes WHERE id_cliente > 0 ;


LOAD DATA INFILE   'C:/Users/luis.accampora/SENAC-UC2-Projeto/Projeto-NaraHoteis/clientes auditado.csv'
INTO TABLE clientes
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;


-- 2. IMPORTAR TABELAS DEPENDENTES (Possuem chaves estrangeiras)

-- ######################################################################################
-- Erros acusadod ao ler .csv de funcionarios
-- arquivo: funcionarios auditado.csv  -Deu erro de importacao nas chaves:
-- chave 9   do arquivo : campo salario em branco  --> coloquei 9999.0 para seguir teste 
-- chave 14  do arquivo : campo salario em branco  --> coloquei 9999.0 para seguir teste
-- chave 37  do arquivo : campo salario em branco  --> coloquei 9999.0 para seguir teste
-- chave 43  do arquivo : campo salario em branco  --> coloquei 9999.0 para seguir teste
-- chave 92  do arquivo : campo salario em branco  --> coloquei 9999.0 para seguir teste
-- chave 104 do arquivo : campo salario em branco  --> coloquei 9999.0 para seguir teste
-- 1 linha em branco ao final do arquivo

-- ##########################
SELECT * FROM funcionarios LIMIT 10;
TRUNCATE TABLE funcionarios;
DELETE FROM funcionarios WHERE id_funcionario > 0 ;

LOAD DATA INFILE   'C:/Users/luis.accampora/SENAC-UC2-Projeto/Projeto-NaraHoteis/Funcionarios auditado.csv'
INTO TABLE funcionarios
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id_funcionario, id_unidade, nome, cargo, departamento, @v_salario, data_admissao)
 SET salario = IF(@v_salario = '', NULL, REPLACE(@v_salario, ',', '.'));

-- ######################################################################################
SELECT * FROM reservas  LIMIT 10;      -- ler todos os registros
SELECT * FROM narahoteis.reservas 
		ORDER BY id_reserva DESC 
		LIMIT 10;
TRUNCATE TABLE reservas;     -- limpa registros da tabela
DELETE FROM reservas WHERE id_reserva > 0 ;
DROP     TABLE reservas;	 -- Exclui a tabela do banco de dados

-- Erros acusadod ao ler .csv de reservas
-- a linha 8 do arquivo reservas auditado.csv possui o campo: avaliação em branco '' substitui por NULL  para testes
-- a linha 11 do arquivo reservas auditado.csv possui o campo: id_canal em branco '' substitui por NULL

LOAD DATA INFILE   'C:/Users/luis.accampora/SENAC-UC2-Projeto/Projeto-NaraHoteis/reservas auditado.csv'
INTO TABLE reservas
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
--
-- Corrigindo possiveis erros na carga de importacao:
-- MAPEAMENTO: Substituímos as colunas 5 e 10 por variáveis temporárias (@v_canal e @v_avaliacao)
(id_reserva, id_unidade, id_tipo_quarto, id_cliente, @v_canal, data_checkin, data_checkout, qtd_diarias, num_hospedes, @v_avaliacao, status_reserva, forma_pagamento)
-- ATRIBUIÇÃO: Tratamos os valores das variáveis antes de gravar na tabela
-- Colocar NULL se o campo avaliacao_hospede ou id_canal estiver em branco na base de dados, para nao gerar erro na importacao. 
SET avaliacao_hospede = IF(@v_avaliacao = '', NULL, @v_avaliacao),
    id_canal = IF(@v_canal = '', NULL, @v_canal)
;

-- ######################################################################################
