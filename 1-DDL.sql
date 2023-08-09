use master
go
USE KB301_Slabikov_Lab1
go
create schema Slabikov
go

create table KB301_Slabikov_Lab1.Slabikov.izmer (
    id_i tinyint primary key,
    m_name nchar(10),
);

create table KB301_Slabikov_Lab1.Slabikov.market (
    id_m tinyint primary key,
    name varchar(20),
    address varchar(20)
);

create table KB301_Slabikov_Lab1.Slabikov.t_group (
    id_g tinyint primary key,
    g_name varchar(50),
);

create table KB301_Slabikov_Lab1.Slabikov.tip_tovara (
    id_t tinyint primary key,
    t_name varchar(50),
    description varchar(50),
    id_g tinyint,
    id_i tinyint
);

create table KB301_Slabikov_Lab1.Slabikov.tovar (
    id tinyint primary key,
    id_m tinyint,
    id_t tinyint,
    amount decimal(14,3),
    post_prod date,
    priznak bit,
    price decimal(10,2)
);

ALTER TABLE KB301_Slabikov_Lab1.Slabikov.tip_tovara
ADD  CONSTRAINT FK_type_izmer FOREIGN KEY([id_i])
REFERENCES KB301_Slabikov_Lab1.Slabikov.izmer ([id_i]);
ALTER TABLE KB301_Slabikov_Lab1.Slabikov.tip_tovara
ADD  CONSTRAINT FK_type_group FOREIGN KEY([id_g])
REFERENCES KB301_Slabikov_Lab1.Slabikov.t_group ([id_g]);
ALTER TABLE KB301_Slabikov_Lab1.Slabikov.tovar
ADD  CONSTRAINT FK_tip_tovara FOREIGN KEY([id_t])
REFERENCES KB301_Slabikov_Lab1.Slabikov.tip_tovara ([id_t]);
ALTER TABLE KB301_Slabikov_Lab1.Slabikov.tovar
ADD  CONSTRAINT FK_tovar_market FOREIGN KEY([id_m])
REFERENCES KB301_Slabikov_Lab1.Slabikov.market ([id_m]);


INSERT INTO KB301_Slabikov_Lab1.Slabikov.market
(id_m, name, address)
VALUES
(0, 'megamart', 'Serova, 10'),
(1, 'perekrestok', 'Lenina, 51'),
(2, 'monetka', 'Turgeneva, 4');


INSERT INTO KB301_Slabikov_Lab1.Slabikov.izmer
(id_i, m_name)
VALUES
(0, 'кг'),
(1, 'л'),
(2, 'шт');


INSERT INTO KB301_Slabikov_Lab1.Slabikov.t_group
(id_g, g_name)
VALUES
(0, 'бытовые'),
(1, 'косметика'),
(2, 'продукты'),
(3, 'канцтовары');


INSERT INTO KB301_Slabikov_Lab1.Slabikov.tip_tovara
(id_t, t_name, description, id_g, id_i)
VALUES
(0, 'овощи', 'полезные', 2, 0),
(1, 'порошки', 'отстирывают', 0, 2),
(2, 'ручки', 'пишут', 3, 2),
(3, 'напитки', 'жидкие', 2, 1),
(4, 'лак для ногтей', 'красит', 1, 2);


INSERT INTO KB301_Slabikov_Lab1.Slabikov.tovar
(id, id_m, id_t, amount, post_prod, priznak, price)
VALUES
(0, 0, 0, 100, '2021-10-09', 0, 10),
(1, 1, 0, 50, '2021-10-09', 1, 120),
(2, 1, 1, 0, '2021-10-08', 0, 5),
(3, 2, 2, 10, '2021-10-06', 1, 500),
(4, 2, 3, 15, '2021-10-05', 1, 80),
(5, 0, 1, 37.000, '2021-10-05', 1, 59.99),
(6, 1, 4, 20.000, '2021-10-10', 1, 35.50);