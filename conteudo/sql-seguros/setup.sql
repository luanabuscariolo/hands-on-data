-- ============================================================
-- SQL TRAINING - SISTEMA DE SEGUROS
-- Setup do Banco de Dados para Exercícios
-- Compatível com: PostgreSQL 14+
--
-- Tabelas criadas:
--   clientes     (30 linhas) — dados dos segurados
--   corretores   ( 8 linhas) — agentes de venda
--   apolices     (50 linhas) — apólices (algumas sem sinistros)
--   coberturas   (75 linhas) — itens cobertos por apólice
--   sinistros    (100 linhas)— ocorrências de sinistro
--   pagamentos   (35 linhas) — pagamentos de sinistros aprovados
-- ============================================================

-- ============================================================
-- 0. LIMPEZA (ordem reversa de dependência)
-- ============================================================
DROP TABLE IF EXISTS pagamentos  CASCADE;
DROP TABLE IF EXISTS coberturas  CASCADE;
DROP TABLE IF EXISTS sinistros   CASCADE;
DROP TABLE IF EXISTS apolices    CASCADE;
DROP TABLE IF EXISTS corretores  CASCADE;
DROP TABLE IF EXISTS clientes    CASCADE;

-- ============================================================
-- 1. TABELAS
-- ============================================================

CREATE TABLE clientes (
    id               SERIAL PRIMARY KEY,
    nome             VARCHAR(100) NOT NULL,
    cpf              VARCHAR(14)  UNIQUE NOT NULL,
    email            VARCHAR(100),
    telefone         VARCHAR(20),
    data_nascimento  DATE,
    cidade           VARCHAR(80),
    estado           VARCHAR(2),
    regiao           VARCHAR(20),
    criado_em        TIMESTAMP DEFAULT NOW()
);

CREATE TABLE corretores (
    id                SERIAL PRIMARY KEY,
    nome              VARCHAR(100) NOT NULL,
    email             VARCHAR(100) UNIQUE,
    regiao            VARCHAR(20),
    taxa_comissao     NUMERIC(5,2),
    data_contratacao  DATE,
    ativo             BOOLEAN DEFAULT TRUE
);

CREATE TABLE apolices (
    id                SERIAL PRIMARY KEY,
    numero_apolice    VARCHAR(50) UNIQUE NOT NULL,
    cliente_id        INT REFERENCES clientes(id),
    corretor_id       INT REFERENCES corretores(id),
    tipo              VARCHAR(20) NOT NULL CHECK (tipo IN ('auto','home','health')),
    data_inicio       DATE NOT NULL,
    data_fim          DATE NOT NULL,
    premio_mensal     NUMERIC(10,2),
    limite_cobertura  NUMERIC(12,2),
    franquia          NUMERIC(10,2),
    status            VARCHAR(20) DEFAULT 'ativa'
                      CHECK (status IN ('ativa','expirada','cancelada'))
);

CREATE TABLE coberturas (
    id               SERIAL PRIMARY KEY,
    apolice_id       INT REFERENCES apolices(id),
    tipo_cobertura   VARCHAR(100) NOT NULL,
    limite           NUMERIC(12,2),
    ativo            BOOLEAN DEFAULT TRUE
);

CREATE TABLE sinistros (
    id               VARCHAR(20) PRIMARY KEY,
    nome_segurado    VARCHAR(100) NOT NULL,
    tipo             VARCHAR(20)  NOT NULL,
    valor_reclamado  NUMERIC(12,2),
    status           VARCHAR(20),
    data_sinistro    DATE,
    numero_apolice   VARCHAR(50) REFERENCES apolices(numero_apolice),
    descricao        TEXT,
    criado_em        TIMESTAMP,
    atualizado_em    TIMESTAMP,
    resolvido_em     TIMESTAMP,
    valor_aprovado   NUMERIC(12,2),
    dias_resolucao   INT,
    regiao           VARCHAR(20),
    canal            VARCHAR(30)
);

CREATE TABLE pagamentos (
    id               SERIAL PRIMARY KEY,
    sinistro_id      VARCHAR(20) REFERENCES sinistros(id),
    valor            NUMERIC(12,2) NOT NULL,
    data_pagamento   DATE,
    metodo           VARCHAR(30),
    status           VARCHAR(20) DEFAULT 'pago'
                     CHECK (status IN ('pendente','pago','cancelado')),
    observacao       TEXT
);

-- ============================================================
-- 2. CLIENTES (30 linhas)
-- Clientes 26-30 NÃO possuem apólice → úteis para OUTER JOIN
-- ============================================================
INSERT INTO clientes (nome, cpf, email, telefone, data_nascimento, cidade, estado, regiao) VALUES
('Carlos Mendes',     '123.456.789-01', 'carlos.mendes@email.com',     '11987651001', '1985-03-15', 'São Paulo',        'SP', 'Sudeste'),
('Ana Lima',          '234.567.890-12', 'ana.lima@email.com',           '21987651002', '1990-07-22', 'Rio de Janeiro',   'RJ', 'Sudeste'),
('Pedro Santos',      '345.678.901-23', 'pedro.santos@email.com',       '31987651003', '1978-11-08', 'Belo Horizonte',   'MG', 'Sudeste'),
('Maria Oliveira',    '456.789.012-34', 'maria.oliveira@email.com',     '71987651004', '1992-04-30', 'Salvador',         'BA', 'Nordeste'),
('João Costa',        '567.890.123-45', 'joao.costa@email.com',         '81987651005', '1983-09-14', 'Recife',           'PE', 'Nordeste'),
('Fernanda Rocha',    '678.901.234-56', 'fernanda.rocha@email.com',     '51987651006', '1995-01-25', 'Porto Alegre',     'RS', 'Sul'),
('Roberto Alves',     '789.012.345-67', 'roberto.alves@email.com',      '41987651007', '1975-06-18', 'Curitiba',         'PR', 'Sul'),
('Camila Ferreira',   '890.123.456-78', 'camila.ferreira@email.com',    '48987651008', '1988-12-03', 'Florianópolis',    'SC', 'Sul'),
('Lucas Souza',       '901.234.567-89', 'lucas.souza@email.com',        '92987651009', '1997-08-20', 'Manaus',           'AM', 'Norte'),
('Patricia Barbosa',  '012.345.678-90', 'patricia.barbosa@email.com',   '91987651010', '1986-02-11', 'Belém',            'PA', 'Norte'),
('Marcelo Lima',      '111.222.333-44', 'marcelo.lima@email.com',       '62987651011', '1980-05-07', 'Goiânia',          'GO', 'Centro-Oeste'),
('Juliana Carvalho',  '222.333.444-55', 'juliana.carvalho@email.com',   '65987651012', '1993-10-19', 'Cuiabá',           'MT', 'Centro-Oeste'),
('André Ribeiro',     '333.444.555-66', 'andre.ribeiro@email.com',      '61987651013', '1971-07-28', 'Brasília',         'DF', 'Centro-Oeste'),
('Bruna Martins',     '444.555.666-77', 'bruna.martins@email.com',      '85987651014', '1989-03-15', 'Fortaleza',        'CE', 'Nordeste'),
('Diego Pereira',     '555.666.777-88', 'diego.pereira@email.com',      '98987651015', '1984-11-22', 'São Luís',         'MA', 'Nordeste'),
('Viviane Castro',    '666.777.888-99', 'viviane.castro@email.com',     '27987651016', '1991-08-09', 'Vitória',          'ES', 'Sudeste'),
('Rafael Gomes',      '777.888.999-00', 'rafael.gomes@email.com',       '84987651017', '1979-04-17', 'Natal',            'RN', 'Nordeste'),
('Sandra Teixeira',   '888.999.000-11', 'sandra.teixeira@email.com',    '83987651018', '1987-12-05', 'João Pessoa',      'PB', 'Nordeste'),
('Thiago Rodrigues',  '999.000.111-22', 'thiago.rodrigues@email.com',   '82987651019', '1994-06-28', 'Maceió',           'AL', 'Nordeste'),
('Leticia Nunes',     '000.111.222-33', 'leticia.nunes@email.com',      '79987651020', '1982-01-14', 'Aracaju',          'SE', 'Nordeste'),
('Gustavo Pinto',     '111.333.555-77', 'gustavo.pinto@email.com',      '63987651021', '1996-09-03', 'Palmas',           'TO', 'Norte'),
('Mariana Lopes',     '222.444.666-88', 'mariana.lopes@email.com',      '11987651022', '1990-05-16', 'São Paulo',        'SP', 'Sudeste'),
('Felipe Araujo',     '333.555.777-99', 'felipe.araujo@email.com',      '21987651023', '1985-02-27', 'Rio de Janeiro',   'RJ', 'Sudeste'),
('Tatiane Monteiro',  '444.666.888-00', 'tatiane.monteiro@email.com',   '31987651024', '1993-07-08', 'Belo Horizonte',   'MG', 'Sudeste'),
('Bruno Vieira',      '555.777.999-11', 'bruno.vieira@email.com',       '51987651025', '1977-11-19', 'Porto Alegre',     'RS', 'Sul'),
-- clientes SEM apólice (26-30) — para exercícios de OUTER JOIN
('Cristiane Moreira', '666.888.000-22', 'cristiane.moreira@email.com',  '67987651026', '1992-03-24', 'Campo Grande',     'MS', 'Centro-Oeste'),
('Paulo Cardoso',     '777.999.111-33', 'paulo.cardoso@email.com',      '11987651027', '1981-08-31', 'São Paulo',        'SP', 'Sudeste'),
('Aline Nascimento',  '888.000.222-44', 'aline.nascimento@email.com',   '85987651028', '1998-12-12', 'Fortaleza',        'CE', 'Nordeste'),
('Eduardo Duarte',    '999.111.333-55', 'eduardo.duarte@email.com',     '41987651029', '1976-04-05', 'Curitiba',         'PR', 'Sul'),
('Simone Freitas',    '000.222.444-66', 'simone.freitas@email.com',     '71987651030', '1989-09-21', 'Salvador',         'BA', 'Nordeste');

-- ============================================================
-- 3. CORRETORES (8 linhas)
-- ============================================================
INSERT INTO corretores (nome, email, regiao, taxa_comissao, data_contratacao, ativo) VALUES
('Ricardo Campos',   'ricardo.campos@seguro.com',   'Sul',           8.50, '2018-03-01', TRUE),
('Carla Monteiro',   'carla.monteiro@seguro.com',   'Sudeste',       9.00, '2016-07-15', TRUE),
('Fábio Souza',      'fabio.souza@seguro.com',      'Nordeste',      8.00, '2019-01-10', TRUE),
('Helena Ferreira',  'helena.ferreira@seguro.com',  'Centro-Oeste',  7.50, '2020-05-20', TRUE),
('Marcos Alves',     'marcos.alves@seguro.com',     'Norte',         8.00, '2017-11-08', TRUE),
('Denise Costa',     'denise.costa@seguro.com',     'Sudeste',       9.50, '2015-06-22', TRUE),
('Leandro Lima',     'leandro.lima@seguro.com',     'Sul',           8.50, '2021-02-14', TRUE),
('Patrícia Duarte',  'patricia.duarte@seguro.com',  'Nordeste',      7.00, '2022-09-30', FALSE);

-- ============================================================
-- 4. APÓLICES (50 linhas)
-- AUTO: 1-20 | HOME: 21-35 | HEALTH: 36-50
-- Apólices 43-50 NÃO possuem sinistros → úteis para LEFT JOIN
-- ============================================================
INSERT INTO apolices (numero_apolice, cliente_id, corretor_id, tipo, data_inicio, data_fim, premio_mensal, limite_cobertura, franquia, status) VALUES
-- AUTO (20)
('AUTO-2022-10001',  1,  1, 'auto',   '2022-01-15', '2025-01-14',  250.00,  100000.00,  2000.00, 'expirada'),
('AUTO-2022-10002',  3,  2, 'auto',   '2022-03-01', '2025-02-28',  320.00,   80000.00,  1500.00, 'expirada'),
('AUTO-2022-10003',  5,  3, 'auto',   '2022-05-10', '2025-05-09',  180.00,   50000.00,  1000.00, 'ativa'),
('AUTO-2022-10004',  6,  1, 'auto',   '2022-07-20', '2025-07-19',  290.00,   90000.00,  1800.00, 'ativa'),
('AUTO-2022-10005',  8,  4, 'auto',   '2022-09-05', '2025-09-04',  210.00,   60000.00,  1200.00, 'ativa'),
('AUTO-2022-10006',  9,  5, 'auto',   '2022-11-12', '2025-11-11',  350.00,  120000.00,  2500.00, 'ativa'),
('AUTO-2023-10007', 11,  2, 'auto',   '2023-01-08', '2026-01-07',  270.00,   85000.00,  1600.00, 'ativa'),
('AUTO-2023-10008', 13,  6, 'auto',   '2023-03-22', '2026-03-21',  195.00,   55000.00,  1100.00, 'ativa'),
('AUTO-2023-10009', 15,  3, 'auto',   '2023-05-14', '2026-05-13',  310.00,   95000.00,  2000.00, 'ativa'),
('AUTO-2023-10010', 17,  7, 'auto',   '2023-07-30', '2026-07-29',  225.00,   70000.00,  1400.00, 'ativa'),
('AUTO-2023-10011', 19,  8, 'auto',   '2023-09-18', '2026-09-17',  160.00,   45000.00,   900.00, 'ativa'),
('AUTO-2023-10012', 21,  1, 'auto',   '2023-11-25', '2026-11-24',  280.00,   88000.00,  1700.00, 'ativa'),
('AUTO-2024-10013', 22,  2, 'auto',   '2024-01-10', '2027-01-09',  340.00,  110000.00,  2200.00, 'ativa'),
('AUTO-2024-10014', 24,  3, 'auto',   '2024-03-05', '2027-03-04',  200.00,   62000.00,  1300.00, 'ativa'),
('AUTO-2024-10015',  1,  6, 'auto',   '2024-05-20', '2027-05-19',  260.00,   82000.00,  1600.00, 'ativa'),
('AUTO-2024-10016',  3,  7, 'auto',   '2024-07-15', '2027-07-14',  300.00,   92000.00,  1900.00, 'ativa'),
('AUTO-2024-10017',  6,  8, 'auto',   '2024-09-01', '2027-08-31',  185.00,   52000.00,  1050.00, 'ativa'),
('AUTO-2024-10018', 11,  1, 'auto',   '2024-11-10', '2027-11-09',  315.00,   98000.00,  2000.00, 'ativa'),
('AUTO-2025-10019', 15,  2, 'auto',   '2025-01-22', '2028-01-21',  245.00,   76000.00,  1500.00, 'ativa'),
('AUTO-2025-10020', 22,  4, 'auto',   '2025-03-08', '2028-03-07',  375.00,  130000.00,  2600.00, 'ativa'),
-- HOME (15)
('HOME-2022-20001',  2,  5, 'home',   '2022-02-10', '2025-02-09',  150.00,  200000.00,  5000.00, 'expirada'),
('HOME-2022-20002',  6,  6, 'home',   '2022-04-18', '2025-04-17',  200.00,  350000.00,  8000.00, 'expirada'),
('HOME-2022-20003',  8,  7, 'home',   '2022-06-25', '2025-06-24',  120.00,  150000.00,  3000.00, 'ativa'),
('HOME-2022-20004', 11,  8, 'home',   '2022-08-12', '2025-08-11',  175.00,  280000.00,  6500.00, 'ativa'),
('HOME-2022-20005', 14,  1, 'home',   '2022-10-28', '2025-10-27',  140.00,  220000.00,  5500.00, 'ativa'),
('HOME-2023-20006', 16,  2, 'home',   '2023-01-15', '2026-01-14',  160.00,  250000.00,  6000.00, 'ativa'),
('HOME-2023-20007', 20,  3, 'home',   '2023-03-22', '2026-03-21',  190.00,  320000.00,  7500.00, 'ativa'),
('HOME-2023-20008', 23,  4, 'home',   '2023-05-09', '2026-05-08',  130.00,  180000.00,  4000.00, 'ativa'),
('HOME-2023-20009', 25,  5, 'home',   '2023-07-17', '2026-07-16',  210.00,  380000.00,  9000.00, 'ativa'),
('HOME-2023-20010',  2,  6, 'home',   '2023-09-04', '2026-09-03',  145.00,  230000.00,  5500.00, 'ativa'),
('HOME-2024-20011',  8,  7, 'home',   '2024-01-20', '2027-01-19',  165.00,  260000.00,  6200.00, 'ativa'),
('HOME-2024-20012', 14,  8, 'home',   '2024-03-14', '2027-03-13',  185.00,  300000.00,  7000.00, 'ativa'),
('HOME-2024-20013', 16,  1, 'home',   '2024-05-28', '2027-05-27',  155.00,  240000.00,  5800.00, 'ativa'),
('HOME-2024-20014', 20,  2, 'home',   '2024-08-06', '2027-08-05',  195.00,  330000.00,  8000.00, 'ativa'),
('HOME-2024-20015', 25,  3, 'home',   '2024-10-19', '2027-10-18',  220.00,  400000.00, 10000.00, 'cancelada'),
-- HEALTH (15)
('HEALTH-2022-30001',  3,  4, 'health', '2022-01-08', '2025-01-07',  380.00,   50000.00,   500.00, 'expirada'),
('HEALTH-2022-30002',  4,  5, 'health', '2022-04-15', '2025-04-14',  420.00,   60000.00,   750.00, 'expirada'),
('HEALTH-2022-30003',  7,  6, 'health', '2022-07-22', '2025-07-21',  290.00,   40000.00,   400.00, 'ativa'),
('HEALTH-2022-30004', 10,  7, 'health', '2022-10-30', '2025-10-29',  350.00,   45000.00,   450.00, 'ativa'),
('HEALTH-2023-30005', 12,  8, 'health', '2023-02-14', '2026-02-13',  310.00,   42000.00,   420.00, 'ativa'),
('HEALTH-2023-30006', 15,  1, 'health', '2023-06-20', '2026-06-19',  460.00,   70000.00,   700.00, 'ativa'),
('HEALTH-2023-30007', 18,  2, 'health', '2023-10-08', '2026-10-07',  280.00,   38000.00,   380.00, 'ativa'),
-- Apólices 43-50: SEM sinistros → para exercícios de LEFT JOIN
('HEALTH-2024-30008', 22,  3, 'health', '2024-01-18', '2027-01-17',  395.00,   55000.00,   550.00, 'ativa'),
('HEALTH-2024-30009', 25,  4, 'health', '2024-04-25', '2027-04-24',  340.00,   48000.00,   480.00, 'ativa'),
('HEALTH-2024-30010',  3,  5, 'health', '2024-07-10', '2027-07-09',  510.00,   80000.00,   800.00, 'ativa'),
('HEALTH-2024-30011',  4,  6, 'health', '2024-10-03', '2027-10-02',  275.00,   36000.00,   360.00, 'ativa'),
('HEALTH-2025-30012',  7,  7, 'health', '2025-01-15', '2028-01-14',  320.00,   44000.00,   440.00, 'ativa'),
('HEALTH-2025-30013', 10,  8, 'health', '2025-04-22', '2028-04-21',  490.00,   75000.00,   750.00, 'ativa'),
('HEALTH-2025-30014', 12,  1, 'health', '2025-07-08', '2028-07-07',  355.00,   50000.00,   500.00, 'ativa'),
('HEALTH-2025-30015', 25,  2, 'health', '2025-10-14', '2028-10-13',  415.00,   62000.00,   620.00, 'ativa');

-- ============================================================
-- 5. COBERTURAS (75 linhas)
-- ============================================================
INSERT INTO coberturas (apolice_id, tipo_cobertura, limite, ativo) VALUES
-- AUTO coberturas
(1,  'Colisão e capotamento',         80000.00, TRUE),
(1,  'Roubo e furto',                 80000.00, TRUE),
(2,  'Colisão e capotamento',         65000.00, TRUE),
(2,  'Danos a terceiros',             30000.00, TRUE),
(3,  'Colisão e capotamento',         40000.00, TRUE),
(3,  'Roubo e furto',                 40000.00, TRUE),
(4,  'Colisão e capotamento',         72000.00, TRUE),
(4,  'Danos por fenômenos naturais',  20000.00, TRUE),
(5,  'Colisão e capotamento',         50000.00, TRUE),
(5,  'Roubo e furto',                 50000.00, TRUE),
(6,  'Colisão e capotamento',        100000.00, TRUE),
(6,  'Roubo e furto',                100000.00, TRUE),
(6,  'Danos a terceiros',             50000.00, TRUE),
(7,  'Colisão e capotamento',         70000.00, TRUE),
(7,  'Roubo e furto',                 70000.00, TRUE),
(8,  'Colisão e capotamento',         45000.00, TRUE),
(9,  'Colisão e capotamento',         80000.00, TRUE),
(9,  'Danos por fenômenos naturais',  25000.00, TRUE),
(10, 'Colisão e capotamento',         56000.00, TRUE),
(10, 'Roubo e furto',                 56000.00, TRUE),
(11, 'Colisão e capotamento',         36000.00, TRUE),
(12, 'Colisão e capotamento',         70000.00, TRUE),
(12, 'Roubo e furto',                 70000.00, TRUE),
(13, 'Colisão e capotamento',         90000.00, TRUE),
(13, 'Danos a terceiros',             40000.00, TRUE),
(14, 'Colisão e capotamento',         50000.00, TRUE),
(15, 'Colisão e capotamento',         65000.00, TRUE),
(15, 'Roubo e furto',                 65000.00, FALSE),
(16, 'Colisão e capotamento',         75000.00, TRUE),
(17, 'Colisão e capotamento',         42000.00, TRUE),
(18, 'Colisão e capotamento',         78000.00, TRUE),
(18, 'Danos a terceiros',             35000.00, TRUE),
(19, 'Colisão e capotamento',         60000.00, TRUE),
(20, 'Colisão e capotamento',        105000.00, TRUE),
(20, 'Roubo e furto',                105000.00, TRUE),
-- HOME coberturas
(21, 'Incêndio e explosão',          160000.00, TRUE),
(21, 'Roubo e arrombamento',          80000.00, TRUE),
(22, 'Incêndio e explosão',          280000.00, TRUE),
(22, 'Danos elétricos',               30000.00, TRUE),
(23, 'Incêndio e explosão',          120000.00, TRUE),
(23, 'Roubo e arrombamento',          60000.00, TRUE),
(24, 'Incêndio e explosão',          220000.00, TRUE),
(24, 'Queda de estruturas',           50000.00, TRUE),
(25, 'Incêndio e explosão',          180000.00, TRUE),
(25, 'Danos elétricos',               20000.00, FALSE),
(26, 'Incêndio e explosão',          200000.00, TRUE),
(26, 'Roubo e arrombamento',          80000.00, TRUE),
(27, 'Incêndio e explosão',          256000.00, TRUE),
(27, 'Danos causados por água',       40000.00, TRUE),
(28, 'Incêndio e explosão',          144000.00, TRUE),
(29, 'Incêndio e explosão',          304000.00, TRUE),
(29, 'Roubo e arrombamento',         100000.00, TRUE),
(29, 'Danos elétricos',               40000.00, TRUE),
(30, 'Incêndio e explosão',          184000.00, TRUE),
(31, 'Incêndio e explosão',          208000.00, TRUE),
(32, 'Incêndio e explosão',          240000.00, TRUE),
(32, 'Queda de estruturas',           60000.00, TRUE),
(33, 'Incêndio e explosão',          192000.00, TRUE),
(34, 'Incêndio e explosão',          264000.00, TRUE),
(34, 'Danos causados por água',       50000.00, TRUE),
(35, 'Incêndio e explosão',          320000.00, FALSE),
-- HEALTH coberturas
(36, 'Consultas e exames',            20000.00, TRUE),
(36, 'Internação hospitalar',         40000.00, TRUE),
(37, 'Consultas e exames',            25000.00, TRUE),
(37, 'Cirurgias',                     50000.00, TRUE),
(38, 'Consultas e exames',            16000.00, TRUE),
(38, 'Internação hospitalar',         32000.00, TRUE),
(39, 'Consultas e exames',            18000.00, TRUE),
(39, 'Internação hospitalar',         36000.00, TRUE),
(40, 'Consultas e exames',            17000.00, TRUE),
(40, 'Cirurgias',                     35000.00, TRUE),
(41, 'Consultas e exames',            28000.00, TRUE),
(41, 'Internação hospitalar',         56000.00, TRUE),
(41, 'Cirurgias',                     60000.00, TRUE),
(42, 'Consultas e exames',            15000.00, TRUE),
(42, 'Internação hospitalar',         30000.00, TRUE);

-- ============================================================
-- 6. SINISTROS (100 linhas)
-- IDs:  SIN-000001..045 = auto
--       SIN-000046..075 = home
--       SIN-000076..100 = health
-- Status:  45 aprovado | 30 em_analise | 15 pendente | 10 rejeitado
-- ============================================================
INSERT INTO sinistros (id, nome_segurado, tipo, valor_reclamado, status, data_sinistro, numero_apolice, descricao, criado_em, atualizado_em, resolvido_em, valor_aprovado, dias_resolucao, regiao, canal) VALUES

-- === AUTO ===
('SIN-000001','Carlos Mendes',    'auto',  15420.00,'aprovado',  '2023-02-10','AUTO-2022-10001','Colisão com outro veículo em rodovia',               '2023-02-12 08:00:00','2023-02-24 17:00:00','2023-02-24 17:00:00',  14200.00, 12,'Sudeste',      'App'),
('SIN-000002','Carlos Mendes',    'auto',   8750.00,'rejeitado', '2023-06-15','AUTO-2022-10001','Danos por negligência comprovada do segurado',        '2023-06-16 09:00:00','2023-06-27 16:00:00','2023-06-27 16:00:00',      NULL, 11,'Sudeste',      'Telefone'),
('SIN-000003','Carlos Mendes',    'auto',  22000.00,'em_analise','2024-09-20','AUTO-2024-10015','Roubo do veículo em via pública',                    '2024-09-21 10:00:00','2024-09-25 11:00:00',NULL,                       NULL,NULL,'Sudeste',      'App'),
('SIN-000004','Pedro Santos',     'auto',   5300.00,'aprovado',  '2023-03-08','AUTO-2022-10002','Arranhão e amassado em estacionamento',               '2023-03-09 08:30:00','2023-03-17 15:00:00','2023-03-17 15:00:00',   4850.00,  8,'Sudeste',      'Portal'),
('SIN-000005','Pedro Santos',     'auto',  31500.00,'aprovado',  '2023-11-22','AUTO-2022-10002','Capotamento em curva molhada',                        '2023-11-23 07:00:00','2023-12-04 14:00:00','2023-12-04 14:00:00',  28900.00, 11,'Sudeste',      'Corretor'),
('SIN-000006','Pedro Santos',     'auto',  19800.00,'aprovado',  '2025-02-05','AUTO-2024-10016','Batida traseira em semáforo',                         '2025-02-06 09:00:00','2025-02-18 16:00:00','2025-02-18 16:00:00',  18500.00, 12,'Sudeste',      'App'),
('SIN-000007','João Costa',       'auto',   3200.00,'aprovado',  '2023-07-12','AUTO-2022-10003','Dano em para-choque por manobra',                     '2023-07-13 10:00:00','2023-07-20 14:00:00','2023-07-20 14:00:00',   2900.00,  7,'Nordeste',     'App'),
('SIN-000008','João Costa',       'auto',  45000.00,'em_analise','2024-11-30','AUTO-2022-10003','Roubo total do veículo',                              '2024-12-01 08:00:00','2024-12-10 12:00:00',NULL,                       NULL,NULL,'Nordeste',     'Telefone'),
('SIN-000009','Fernanda Rocha',   'auto',  12600.00,'aprovado',  '2023-04-18','AUTO-2022-10004','Colisão em cruzamento sem sinalização',               '2023-04-19 09:00:00','2023-04-30 15:00:00','2023-04-30 15:00:00',  11800.00, 11,'Sul',          'Corretor'),
('SIN-000010','Fernanda Rocha',   'auto',   7400.00,'rejeitado', '2023-10-05','AUTO-2022-10004','Dano causado por embriaguez ao volante',               '2023-10-06 10:00:00','2023-10-14 16:00:00','2023-10-14 16:00:00',      NULL,  8,'Sul',          'App'),
('SIN-000011','Fernanda Rocha',   'auto',  28000.00,'em_analise','2025-01-14','AUTO-2024-10017','Capotamento em pista molhada',                        '2025-01-15 08:00:00','2025-01-22 10:00:00',NULL,                       NULL,NULL,'Sul',          'Portal'),
('SIN-000012','Camila Ferreira',  'auto',   9100.00,'aprovado',  '2023-05-22','AUTO-2022-10005','Colisão leve em estacionamento',                      '2023-05-23 09:00:00','2023-05-31 15:00:00','2023-05-31 15:00:00',   8500.00,  8,'Sul',          'App'),
('SIN-000013','Camila Ferreira',  'auto',  17300.00,'aprovado',  '2024-03-10','AUTO-2022-10005','Batida frontal em rodovia',                           '2024-03-11 07:00:00','2024-03-25 14:00:00','2024-03-25 14:00:00',  15800.00, 14,'Sul',          'Corretor'),
('SIN-000014','Lucas Souza',      'auto',  38500.00,'em_analise','2024-08-28','AUTO-2022-10006','Roubo do veículo com violência',                      '2024-08-29 09:00:00','2024-09-08 12:00:00',NULL,                       NULL,NULL,'Norte',        'App'),
('SIN-000015','Lucas Souza',      'auto',   6200.00,'aprovado',  '2023-09-14','AUTO-2022-10006','Danos por enchente — motor afetado',                  '2023-09-15 10:00:00','2023-09-22 16:00:00','2023-09-22 16:00:00',   5800.00,  7,'Norte',        'Telefone'),
('SIN-000016','Marcelo Lima',     'auto',  21000.00,'aprovado',  '2023-12-03','AUTO-2023-10007','Colisão traseira em rodovia',                         '2023-12-04 08:00:00','2023-12-17 14:00:00','2023-12-17 14:00:00',  19500.00, 13,'Centro-Oeste', 'App'),
('SIN-000017','Marcelo Lima',     'auto',  33000.00,'em_analise','2025-03-20','AUTO-2024-10018','Colisão frontal grave',                               '2025-03-21 07:00:00','2025-03-31 11:00:00',NULL,                       NULL,NULL,'Centro-Oeste', 'Portal'),
('SIN-000018','André Ribeiro',    'auto',   4800.00,'aprovado',  '2024-02-16','AUTO-2023-10008','Amassado lateral em via urbana',                      '2024-02-17 09:00:00','2024-02-26 15:00:00','2024-02-26 15:00:00',   4400.00,  9,'Centro-Oeste', 'App'),
('SIN-000019','André Ribeiro',    'auto',  16700.00,'pendente',  '2025-04-02','AUTO-2023-10008','Colisão com animal na pista',                         '2025-04-03 08:00:00','2025-04-05 10:00:00',NULL,                       NULL,NULL,'Centro-Oeste', 'Telefone'),
('SIN-000020','Diego Pereira',    'auto',  11200.00,'aprovado',  '2023-08-25','AUTO-2023-10009','Batida traseira em semáforo',                         '2023-08-26 09:00:00','2023-09-05 16:00:00','2023-09-05 16:00:00',  10500.00, 10,'Nordeste',     'App'),
('SIN-000021','Diego Pereira',    'auto',  26500.00,'aprovado',  '2024-06-10','AUTO-2023-10009','Capotamento em curva',                                '2024-06-11 07:00:00','2024-06-24 14:00:00','2024-06-24 14:00:00',  24200.00, 13,'Nordeste',     'Corretor'),
('SIN-000022','Diego Pereira',    'auto',  41000.00,'em_analise','2025-05-08','AUTO-2025-10019','Roubo total do veículo',                              '2025-05-09 09:00:00','2025-05-16 12:00:00',NULL,                       NULL,NULL,'Nordeste',     'App'),
('SIN-000023','Rafael Gomes',     'auto',   8300.00,'aprovado',  '2023-10-18','AUTO-2023-10010','Dano por granizo no capô e teto',                     '2023-10-19 10:00:00','2023-10-28 15:00:00','2023-10-28 15:00:00',   7800.00,  9,'Nordeste',     'Portal'),
('SIN-000024','Rafael Gomes',     'auto',  14900.00,'rejeitado', '2024-07-22','AUTO-2023-10010','Dano ocorrido fora do período de vigência',           '2024-07-23 08:00:00','2024-08-02 16:00:00','2024-08-02 16:00:00',      NULL, 10,'Nordeste',     'Telefone'),
('SIN-000025','Thiago Rodrigues', 'auto',   5500.00,'aprovado',  '2024-01-09','AUTO-2023-10011','Dano em para-lama em acidente leve',                  '2024-01-10 09:00:00','2024-01-17 15:00:00','2024-01-17 15:00:00',   5100.00,  7,'Nordeste',     'App'),
('SIN-000026','Gustavo Pinto',    'auto',  19200.00,'aprovado',  '2024-04-14','AUTO-2023-10012','Colisão com moto em cruzamento',                      '2024-04-15 08:00:00','2024-04-28 14:00:00','2024-04-28 14:00:00',  17800.00, 13,'Norte',        'App'),
('SIN-000027','Gustavo Pinto',    'auto',   7100.00,'pendente',  '2025-02-28','AUTO-2023-10012','Amassado por chuva de granizo',                       '2025-03-01 10:00:00','2025-03-04 11:00:00',NULL,                       NULL,NULL,'Norte',        'Portal'),
('SIN-000028','Mariana Lopes',    'auto',  29500.00,'aprovado',  '2024-05-30','AUTO-2024-10013','Batida frontal em rodovia federal',                   '2024-05-31 07:00:00','2024-06-14 15:00:00','2024-06-14 15:00:00',  27000.00, 14,'Sudeste',      'Corretor'),
('SIN-000029','Mariana Lopes',    'auto',  52000.00,'em_analise','2025-05-20','AUTO-2025-10020','Roubo com violência e dano total',                    '2025-05-21 09:00:00','2025-05-28 12:00:00',NULL,                       NULL,NULL,'Sudeste',      'App'),
('SIN-000030','Tatiane Monteiro', 'auto',   6800.00,'aprovado',  '2024-09-05','AUTO-2024-10014','Dano em retrovisores e porta',                        '2024-09-06 09:00:00','2024-09-14 15:00:00','2024-09-14 15:00:00',   6200.00,  8,'Sudeste',      'App'),
('SIN-000031','Tatiane Monteiro', 'auto',  18400.00,'pendente',  '2025-01-25','AUTO-2024-10014','Colisão com barreira de proteção',                    '2025-01-26 08:00:00','2025-01-29 10:00:00',NULL,                       NULL,NULL,'Sudeste',      'Telefone'),
('SIN-000032','Marcelo Lima',     'auto',  43000.00,'rejeitado', '2025-04-10','AUTO-2024-10018','Sinistro fora da cobertura contratada',               '2025-04-11 09:00:00','2025-04-21 16:00:00','2025-04-21 16:00:00',      NULL, 10,'Centro-Oeste', 'App'),
('SIN-000033','Fernanda Rocha',   'auto',  11500.00,'aprovado',  '2024-10-18','AUTO-2024-10017','Dano em faróis e para-choque traseiro',               '2024-10-19 09:00:00','2024-10-30 15:00:00','2024-10-30 15:00:00',  10800.00, 11,'Sul',          'Portal'),
('SIN-000034','Pedro Santos',     'auto',  37000.00,'em_analise','2025-03-12','AUTO-2024-10016','Colisão grave com caminhão',                          '2025-03-13 07:00:00','2025-03-22 11:00:00',NULL,                       NULL,NULL,'Sudeste',      'Corretor'),
('SIN-000035','Diego Pereira',    'auto',  14200.00,'aprovado',  '2024-12-05','AUTO-2025-10019','Dano em chassi após buraco na pista',                 '2024-12-06 09:00:00','2024-12-17 15:00:00','2024-12-17 15:00:00',  13000.00, 11,'Nordeste',     'App'),
('SIN-000036','Camila Ferreira',  'auto',   9800.00,'pendente',  '2025-05-01','AUTO-2022-10005','Amassado em coluna do veículo',                       '2025-05-02 08:00:00','2025-05-05 10:00:00',NULL,                       NULL,NULL,'Sul',          'App'),
('SIN-000037','Mariana Lopes',    'auto',  24000.00,'aprovado',  '2024-08-12','AUTO-2024-10013','Dano total por alagamento',                           '2024-08-13 07:00:00','2024-08-26 14:00:00','2024-08-26 14:00:00',  21500.00, 13,'Sudeste',      'App'),
('SIN-000038','Carlos Mendes',    'auto',  17800.00,'pendente',  '2025-04-22','AUTO-2024-10015','Furto de peças e som automotivo',                     '2025-04-23 09:00:00','2025-04-26 11:00:00',NULL,                       NULL,NULL,'Sudeste',      'Portal'),
('SIN-000039','Gustavo Pinto',    'auto',  31200.00,'em_analise','2024-11-10','AUTO-2023-10012','Colisão com poste em manobra de ré',                  '2024-11-11 08:00:00','2024-11-20 12:00:00',NULL,                       NULL,NULL,'Norte',        'Telefone'),
('SIN-000040','André Ribeiro',    'auto',  12000.00,'aprovado',  '2023-11-08','AUTO-2023-10008','Colisão em via urbana — semáforo vermelho',           '2023-11-09 09:00:00','2023-11-20 15:00:00','2023-11-20 15:00:00',  11200.00, 11,'Centro-Oeste', 'App'),
('SIN-000041','Rafael Gomes',     'auto',   3900.00,'aprovado',  '2025-02-14','AUTO-2023-10010','Dano em para-choque dianteiro',                       '2025-02-15 09:00:00','2025-02-22 15:00:00','2025-02-22 15:00:00',   3600.00,  7,'Nordeste',     'App'),
('SIN-000042','Thiago Rodrigues', 'auto',  22500.00,'em_analise','2025-03-30','AUTO-2023-10011','Colisão com veículo em fuga',                         '2025-03-31 08:00:00','2025-04-08 12:00:00',NULL,                       NULL,NULL,'Nordeste',     'Corretor'),
('SIN-000043','Lucas Souza',      'auto',  48000.00,'rejeitado', '2024-05-05','AUTO-2022-10006','Dano intencional — sinistro fraudulento',             '2024-05-06 09:00:00','2024-05-16 16:00:00','2024-05-16 16:00:00',      NULL, 10,'Norte',        'App'),
('SIN-000044','João Costa',       'auto',   7600.00,'aprovado',  '2024-02-20','AUTO-2022-10003','Dano no painel por enchente',                         '2024-02-21 08:00:00','2024-03-01 15:00:00','2024-03-01 15:00:00',   7100.00,  9,'Nordeste',     'Telefone'),
('SIN-000045','Marcelo Lima',     'auto',  13500.00,'aprovado',  '2023-07-30','AUTO-2023-10007','Batida lateral em rodovia',                           '2023-07-31 09:00:00','2023-08-11 15:00:00','2023-08-11 15:00:00',  12600.00, 11,'Centro-Oeste', 'App'),

-- === HOME ===
('SIN-000046','Ana Lima',         'home',  34200.00,'aprovado',  '2023-04-10','HOME-2022-20001','Incêndio na cozinha causando danos estruturais',       '2023-04-12 08:00:00','2023-04-27 16:00:00','2023-04-27 16:00:00',  31500.00, 15,'Sudeste',      'Corretor'),
('SIN-000047','Ana Lima',         'home',  18700.00,'em_analise','2024-10-15','HOME-2023-20010','Infiltração em teto após chuva forte',                 '2024-10-16 09:00:00','2024-10-25 12:00:00',NULL,                       NULL,NULL,'Sudeste',      'App'),
('SIN-000048','Fernanda Rocha',   'home',  52000.00,'aprovado',  '2023-08-22','HOME-2022-20002','Incêndio destruiu sala e quarto principal',            '2023-08-23 07:00:00','2023-09-10 15:00:00','2023-09-10 15:00:00',  47500.00, 18,'Sul',          'Corretor'),
('SIN-000049','Fernanda Rocha',   'home',  11300.00,'rejeitado', '2024-03-05','HOME-2022-20002','Dano intencional sem cobertura',                       '2024-03-06 09:00:00','2024-03-18 16:00:00','2024-03-18 16:00:00',      NULL, 12,'Sul',          'Telefone'),
('SIN-000050','Camila Ferreira',  'home',  26500.00,'aprovado',  '2023-11-12','HOME-2022-20003','Roubo de eletrodomésticos e eletrônicos',              '2023-11-13 08:00:00','2023-11-25 14:00:00','2023-11-25 14:00:00',  24000.00, 12,'Sul',          'App'),
('SIN-000051','Camila Ferreira',  'home',  38000.00,'em_analise','2025-02-18','HOME-2024-20011','Danos elétricos por raio',                             '2025-02-19 09:00:00','2025-02-26 12:00:00',NULL,                       NULL,NULL,'Sul',          'Portal'),
('SIN-000052','Marcelo Lima',     'home',  61000.00,'aprovado',  '2024-01-08','HOME-2022-20004','Queda de árvore sobre o imóvel',                      '2024-01-09 07:00:00','2024-01-26 15:00:00','2024-01-26 15:00:00',  56000.00, 17,'Centro-Oeste', 'Corretor'),
('SIN-000053','Marcelo Lima',     'home',  29400.00,'pendente',  '2025-04-15','HOME-2022-20004','Inundação por chuva intensa',                          '2025-04-16 08:00:00','2025-04-19 10:00:00',NULL,                       NULL,NULL,'Centro-Oeste', 'App'),
('SIN-000054','Bruna Martins',    'home',  44700.00,'aprovado',  '2023-06-20','HOME-2022-20005','Explosão do fogão causando danos em cozinha',          '2023-06-21 09:00:00','2023-07-06 15:00:00','2023-07-06 15:00:00',  41000.00, 15,'Nordeste',     'Telefone'),
('SIN-000055','Bruna Martins',    'home',  19800.00,'aprovado',  '2024-09-28','HOME-2024-20012','Vidros quebrados por chuva de granizo',                '2024-09-29 08:00:00','2024-10-10 14:00:00','2024-10-10 14:00:00',  18200.00, 11,'Nordeste',     'App'),
('SIN-000056','Viviane Castro',   'home',  33000.00,'aprovado',  '2023-09-14','HOME-2023-20006','Incêndio elétrico no painel de energia',               '2023-09-15 07:00:00','2023-09-30 16:00:00','2023-09-30 16:00:00',  30500.00, 15,'Sudeste',      'Corretor'),
('SIN-000057','Viviane Castro',   'home',  14500.00,'em_analise','2025-03-08','HOME-2024-20013','Roubo durante viagem do segurado',                     '2025-03-09 09:00:00','2025-03-18 12:00:00',NULL,                       NULL,NULL,'Sudeste',      'App'),
('SIN-000058','Leticia Nunes',    'home',  47200.00,'aprovado',  '2024-02-14','HOME-2023-20007','Inundação por transbordamento de rio',                 '2024-02-15 08:00:00','2024-03-01 15:00:00','2024-03-01 15:00:00',  43000.00, 15,'Nordeste',     'App'),
('SIN-000059','Leticia Nunes',    'home',  21600.00,'pendente',  '2025-05-10','HOME-2024-20014','Danos elétricos por raio',                             '2025-05-11 09:00:00','2025-05-14 10:00:00',NULL,                       NULL,NULL,'Nordeste',     'Portal'),
('SIN-000060','Felipe Araujo',    'home',  28900.00,'aprovado',  '2023-12-05','HOME-2023-20008','Incêndio parcial na sala de estar',                    '2023-12-06 07:00:00','2023-12-21 15:00:00','2023-12-21 15:00:00',  26500.00, 15,'Sudeste',      'App'),
('SIN-000061','Felipe Araujo',    'home',  16200.00,'rejeitado', '2024-06-19','HOME-2023-20008','Dano por uso indevido — contrato excluído',            '2024-06-20 09:00:00','2024-07-01 16:00:00','2024-07-01 16:00:00',      NULL, 11,'Sudeste',      'Telefone'),
('SIN-000062','Bruno Vieira',     'home',  73000.00,'aprovado',  '2023-10-27','HOME-2023-20009','Incêndio de grandes proporções',                      '2023-10-28 07:00:00','2023-11-15 15:00:00','2023-11-15 15:00:00',  67000.00, 18,'Sul',          'Corretor'),
('SIN-000063','Bruno Vieira',     'home',  35500.00,'em_analise','2025-01-30','HOME-2024-20015','Dano estrutural por terremoto',                        '2025-01-31 09:00:00','2025-02-10 12:00:00',NULL,                       NULL,NULL,'Sul',          'App'),
('SIN-000064','Ana Lima',         'home',   9800.00,'aprovado',  '2024-05-08','HOME-2023-20010','Roubo de equipamento eletrônico',                     '2024-05-09 08:00:00','2024-05-18 15:00:00','2024-05-18 15:00:00',   9100.00,  9,'Sudeste',      'App'),
('SIN-000065','Camila Ferreira',  'home',  42000.00,'aprovado',  '2024-07-15','HOME-2024-20011','Queda de telhado por ventos fortes',                   '2024-07-16 07:00:00','2024-07-31 14:00:00','2024-07-31 14:00:00',  38500.00, 15,'Sul',          'Corretor'),
('SIN-000066','Bruna Martins',    'home',  31000.00,'em_analise','2024-12-18','HOME-2024-20012','Infiltração grave causando mofo estrutural',           '2024-12-19 09:00:00','2024-12-28 12:00:00',NULL,                       NULL,NULL,'Nordeste',     'App'),
('SIN-000067','Viviane Castro',   'home',  58000.00,'aprovado',  '2025-01-05','HOME-2024-20013','Incêndio total em apartamento',                       '2025-01-06 07:00:00','2025-01-23 15:00:00','2025-01-23 15:00:00',  53000.00, 17,'Sudeste',      'App'),
('SIN-000068','Leticia Nunes',    'home',  24300.00,'aprovado',  '2023-08-08','HOME-2023-20007','Roubo e arrombamento noturno',                         '2023-08-09 08:00:00','2023-08-21 15:00:00','2023-08-21 15:00:00',  22500.00, 12,'Nordeste',     'Portal'),
('SIN-000069','Marcelo Lima',     'home',  15700.00,'pendente',  '2025-05-22','HOME-2024-20014','Dano em piso por enchente',                            '2025-05-23 09:00:00','2025-05-25 10:00:00',NULL,                       NULL,NULL,'Centro-Oeste', 'Telefone'),
('SIN-000070','Felipe Araujo',    'home',  19400.00,'aprovado',  '2024-03-20','HOME-2023-20008','Dano em paredes por umidade',                          '2024-03-21 08:00:00','2024-04-03 15:00:00','2024-04-03 15:00:00',  17800.00, 13,'Sudeste',      'App'),
('SIN-000071','Bruno Vieira',     'home',  55000.00,'aprovado',  '2024-06-05','HOME-2023-20009','Queda de estrutura do telhado',                        '2024-06-06 07:00:00','2024-06-23 14:00:00','2024-06-23 14:00:00',  50500.00, 17,'Sul',          'Corretor'),
('SIN-000072','Ana Lima',         'home',  12100.00,'rejeitado', '2023-07-28','HOME-2022-20001','Dano pré-existente não declarado',                     '2023-07-29 09:00:00','2023-08-08 16:00:00','2023-08-08 16:00:00',      NULL, 10,'Sudeste',      'Telefone'),
('SIN-000073','Fernanda Rocha',   'home',  29000.00,'aprovado',  '2025-02-10','HOME-2022-20002','Danos causados por fumaça de incêndio vizinho',       '2025-02-11 08:00:00','2025-02-26 15:00:00','2025-02-26 15:00:00',  26500.00, 15,'Sul',          'App'),
('SIN-000074','Camila Ferreira',  'home',  17600.00,'em_analise','2025-04-28','HOME-2024-20011','Avaria em instalação hidráulica',                      '2025-04-29 09:00:00','2025-05-06 12:00:00',NULL,                       NULL,NULL,'Sul',          'App'),
('SIN-000075','Bruna Martins',    'home',  36800.00,'aprovado',  '2024-11-03','HOME-2024-20012','Queda de muro por chuvas intensas',                    '2024-11-04 07:00:00','2024-11-19 15:00:00','2024-11-19 15:00:00',  33800.00, 15,'Nordeste',     'Corretor'),

-- === HEALTH ===
('SIN-000076','Pedro Santos',     'health',  5274.00,'aprovado',  '2023-05-03','HEALTH-2022-30001','Exames de imagem de alta complexidade',               '2023-05-04 08:00:00','2023-05-11 15:00:00','2023-05-11 15:00:00',  5055.00,  7,'Sudeste',      'App'),
('SIN-000077','Pedro Santos',     'health', 18900.00,'aprovado',  '2023-10-20','HEALTH-2022-30001','Cirurgia de emergência — hérnia de disco',             '2023-10-21 07:00:00','2023-11-05 14:00:00','2023-11-05 14:00:00', 17500.00, 15,'Sudeste',      'Corretor'),
('SIN-000078','Maria Oliveira',   'health',  9200.00,'aprovado',  '2023-07-15','HEALTH-2022-30002','Internação por pneumonia severa',                      '2023-07-16 09:00:00','2023-07-26 15:00:00','2023-07-26 15:00:00',  8800.00, 10,'Nordeste',     'Telefone'),
('SIN-000079','Maria Oliveira',   'health', 32000.00,'aprovado',  '2024-03-22','HEALTH-2022-30002','Cirurgia cardíaca eletiva',                            '2024-03-23 07:00:00','2024-04-10 15:00:00','2024-04-10 15:00:00', 29500.00, 18,'Nordeste',     'Corretor'),
('SIN-000080','Roberto Alves',    'health',  7600.00,'aprovado',  '2023-09-05','HEALTH-2022-30003','Internação por dengue grave',                          '2023-09-06 08:00:00','2023-09-14 15:00:00','2023-09-14 15:00:00',  7200.00,  8,'Sul',          'App'),
('SIN-000081','Roberto Alves',    'health', 14300.00,'em_analise','2024-11-18','HEALTH-2022-30003','Cirurgia de joelho — ligamentos',                      '2024-11-19 09:00:00','2024-11-28 12:00:00',NULL,                      NULL, NULL,'Sul',          'Portal'),
('SIN-000082','Patricia Barbosa', 'health',  4500.00,'aprovado',  '2023-11-30','HEALTH-2022-30004','Consultas e exames cardiológicos',                     '2023-12-01 09:00:00','2023-12-09 15:00:00','2023-12-09 15:00:00',  4200.00,  8,'Norte',        'App'),
('SIN-000083','Patricia Barbosa', 'health', 23700.00,'aprovado',  '2024-07-08','HEALTH-2022-30004','Internação por fratura com cirurgia',                  '2024-07-09 07:00:00','2024-07-25 14:00:00','2024-07-25 14:00:00', 21900.00, 16,'Norte',        'Corretor'),
('SIN-000084','Juliana Carvalho', 'health',  6800.00,'aprovado',  '2024-02-25','HEALTH-2023-30005','Internação por apendicite',                            '2024-02-26 08:00:00','2024-03-05 15:00:00','2024-03-05 15:00:00',  6500.00,  8,'Centro-Oeste', 'App'),
('SIN-000085','Juliana Carvalho', 'health', 11400.00,'pendente',  '2025-05-15','HEALTH-2023-30005','Tratamento oncológico — requisição em análise',        '2025-05-16 09:00:00','2025-05-19 10:00:00',NULL,                      NULL, NULL,'Centro-Oeste', 'Telefone'),
('SIN-000086','Diego Pereira',    'health',  8100.00,'aprovado',  '2024-05-20','HEALTH-2023-30006','Exames laboratoriais e consulta especializada',        '2024-05-21 09:00:00','2024-05-29 15:00:00','2024-05-29 15:00:00',  7700.00,  8,'Nordeste',     'App'),
('SIN-000087','Diego Pereira',    'health', 38000.00,'aprovado',  '2024-10-10','HEALTH-2023-30006','Cirurgia de urgência — perfuração intestinal',         '2024-10-11 07:00:00','2024-10-28 15:00:00','2024-10-28 15:00:00', 35000.00, 17,'Nordeste',     'Corretor'),
('SIN-000088','Sandra Teixeira',  'health',  5300.00,'aprovado',  '2023-06-12','HEALTH-2023-30007','Internação curta por infecção viral',                  '2023-06-13 08:00:00','2023-06-20 15:00:00','2023-06-20 15:00:00',  5000.00,  7,'Nordeste',     'App'),
('SIN-000089','Sandra Teixeira',  'health', 19600.00,'em_analise','2025-04-05','HEALTH-2023-30007','Cirurgia de coluna programada',                        '2025-04-06 09:00:00','2025-04-15 12:00:00',NULL,                      NULL, NULL,'Nordeste',     'Portal'),
('SIN-000090','Pedro Santos',     'health', 12800.00,'aprovado',  '2024-08-14','HEALTH-2022-30001','Tratamento neurológico e exames de imagem',             '2024-08-15 08:00:00','2024-08-25 15:00:00','2024-08-25 15:00:00', 12000.00, 10,'Sudeste',      'App'),
('SIN-000091','Maria Oliveira',   'health',  3900.00,'rejeitado', '2023-03-20','HEALTH-2022-30002','Procedimento estético não coberto',                    '2023-03-21 09:00:00','2023-03-30 16:00:00','2023-03-30 16:00:00',     NULL,  9,'Nordeste',     'Telefone'),
('SIN-000092','Roberto Alves',    'health',  9700.00,'aprovado',  '2025-01-22','HEALTH-2022-30003','Internação por hipertensão severa',                    '2025-01-23 08:00:00','2025-01-31 15:00:00','2025-01-31 15:00:00',  9200.00,  8,'Sul',          'App'),
('SIN-000093','Patricia Barbosa', 'health', 15200.00,'pendente',  '2025-05-28','HEALTH-2022-30004','Solicitação de cobertura para tratamento de longa duração','2025-05-29 09:00:00','2025-05-30 10:00:00',NULL,                  NULL, NULL,'Norte',        'App'),
('SIN-000094','Juliana Carvalho', 'health', 27500.00,'aprovado',  '2024-09-18','HEALTH-2023-30005','Cirurgia bariátrica pós-aprovação médica',             '2024-09-19 07:00:00','2024-10-06 15:00:00','2024-10-06 15:00:00', 25000.00, 17,'Centro-Oeste', 'Corretor'),
('SIN-000095','Diego Pereira',    'health',  6400.00,'aprovado',  '2023-12-14','HEALTH-2023-30006','Consulta e exames de rotina anuais',                   '2023-12-15 09:00:00','2023-12-22 15:00:00','2023-12-22 15:00:00',  6100.00,  7,'Nordeste',     'App'),
('SIN-000096','Sandra Teixeira',  'health', 33000.00,'aprovado',  '2024-04-02','HEALTH-2023-30007','Cirurgia de emergência — vesícula',                    '2024-04-03 07:00:00','2024-04-20 15:00:00','2024-04-20 15:00:00', 30500.00, 17,'Nordeste',     'Corretor'),
('SIN-000097','Pedro Santos',     'health',  7100.00,'em_analise','2025-05-25','HEALTH-2022-30001','Internação para investigação diagnóstica',              '2025-05-26 09:00:00','2025-05-30 12:00:00',NULL,                      NULL, NULL,'Sudeste',      'App'),
('SIN-000098','Maria Oliveira',   'health', 41000.00,'aprovado',  '2025-01-12','HEALTH-2022-30002','Transplante de órgão — procedimento coberto',          '2025-01-13 07:00:00','2025-02-02 15:00:00','2025-02-02 15:00:00', 38000.00, 20,'Nordeste',     'Corretor'),
('SIN-000099','Patricia Barbosa', 'health', 11800.00,'aprovado',  '2024-11-25','HEALTH-2022-30004','Internação por acidente doméstico',                    '2024-11-26 08:00:00','2024-12-06 15:00:00','2024-12-06 15:00:00', 11000.00, 10,'Norte',        'App'),
('SIN-000100','Juliana Carvalho', 'health', 18200.00,'em_analise','2025-04-20','HEALTH-2023-30005','Tratamento quimioterápico — segunda solicitação',       '2025-04-21 09:00:00','2025-04-30 12:00:00',NULL,                      NULL, NULL,'Centro-Oeste', 'Portal');

-- ============================================================
-- 7. PAGAMENTOS (35 linhas)
-- Apenas sinistros com status='aprovado' recebem pagamento
-- 10 sinistros aprovados ficam SEM pagamento (para exercícios)
-- ============================================================
INSERT INTO pagamentos (sinistro_id, valor, data_pagamento, metodo, status, observacao) VALUES
('SIN-000001',  14200.00, '2023-03-02', 'PIX',    'pago', NULL),
('SIN-000004',   4850.00, '2023-03-25', 'PIX',    'pago', NULL),
('SIN-000005',  28900.00, '2023-12-15', 'TED',    'pago', NULL),
('SIN-000006',  18500.00, '2025-02-25', 'PIX',    'pago', NULL),
('SIN-000007',   2900.00, '2023-07-28', 'PIX',    'pago', NULL),
('SIN-000009',  11800.00, '2023-05-10', 'TED',    'pago', NULL),
('SIN-000012',   8500.00, '2023-06-10', 'PIX',    'pago', NULL),
('SIN-000013',  15800.00, '2024-04-05', 'TED',    'pago', NULL),
('SIN-000015',   5800.00, '2023-10-01', 'PIX',    'pago', NULL),
('SIN-000016',  19500.00, '2023-12-28', 'TED',    'pago', NULL),
('SIN-000018',   4400.00, '2024-03-06', 'PIX',    'pago', NULL),
('SIN-000020',  10500.00, '2023-09-15', 'PIX',    'pago', NULL),
('SIN-000021',  24200.00, '2024-07-04', 'TED',    'pago', NULL),
('SIN-000023',   7800.00, '2023-11-07', 'Boleto', 'pago', 'Pagamento parcelado em 2x'),
('SIN-000025',   5100.00, '2024-01-26', 'PIX',    'pago', NULL),
('SIN-000026',  17800.00, '2024-05-08', 'TED',    'pago', NULL),
('SIN-000028',  27000.00, '2024-06-25', 'TED',    'pago', NULL),
('SIN-000030',   6200.00, '2024-09-22', 'PIX',    'pago', NULL),
('SIN-000033',  10800.00, '2024-11-09', 'PIX',    'pago', NULL),
('SIN-000035',  13000.00, '2024-12-28', 'PIX',    'pago', NULL),
-- home
('SIN-000046',  31500.00, '2023-05-08', 'TED',    'pago', NULL),
('SIN-000048',  47500.00, '2023-09-22', 'TED',    'pago', 'Transferência em 2 parcelas'),
('SIN-000050',  24000.00, '2023-12-06', 'Boleto', 'pago', NULL),
('SIN-000052',  56000.00, '2024-02-06', 'TED',    'pago', NULL),
('SIN-000054',  41000.00, '2023-07-18', 'TED',    'pago', NULL),
('SIN-000055',  18200.00, '2024-10-22', 'PIX',    'pago', NULL),
('SIN-000056',  30500.00, '2023-10-12', 'TED',    'pago', NULL),
('SIN-000060',  26500.00, '2023-12-31', 'TED',    'pago', NULL),
('SIN-000062',  67000.00, '2023-11-28', 'TED',    'pago', 'Maior sinistro do ano'),
-- health
('SIN-000076',   5055.00, '2023-05-20', 'PIX',    'pago', NULL),
('SIN-000077',  17500.00, '2023-11-18', 'TED',    'pago', NULL),
('SIN-000078',   8800.00, '2023-08-05', 'PIX',    'pago', NULL),
('SIN-000079',  29500.00, '2024-04-22', 'TED',    'pago', NULL),
('SIN-000080',   7200.00, '2023-09-24', 'PIX',    'pago', NULL),
('SIN-000082',   4200.00, '2023-12-18', 'PIX',    'pago', NULL);

-- ============================================================
-- VERIFICAÇÃO RÁPIDA
-- ============================================================
-- SELECT 'clientes'   AS tabela, COUNT(*) AS linhas FROM clientes
-- UNION ALL
-- SELECT 'corretores',           COUNT(*) FROM corretores
-- UNION ALL
-- SELECT 'apolices',             COUNT(*) FROM apolices
-- UNION ALL
-- SELECT 'coberturas',           COUNT(*) FROM coberturas
-- UNION ALL
-- SELECT 'sinistros',            COUNT(*) FROM sinistros
-- UNION ALL
-- SELECT 'pagamentos',           COUNT(*) FROM pagamentos;
