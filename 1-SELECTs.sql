USE kb301_slabikov_lab1;

/*
 * 0 - дата поступления товара
 * 1 - дата продажи товара
*/

/* Количество определенного товара во всех магазинах */
SELECT tip.t_name         AS Название_товара,
       Sum(tovari.amount) AS Количество,
       izmer.m_name       AS Единицы_Измерения
FROM   slabikov.tovar AS tovari
       INNER JOIN slabikov.tip_tovara AS tip
               ON tip.id_t = tovari.id_t
       INNER JOIN slabikov.izmer AS izmer
               ON tip.id_i = izmer.id_i
GROUP  BY tip.t_name,
          izmer.m_name


/* Определение средней цены товаров среди всех магазинов */
SELECT tip.t_name        AS Товар,
       Avg(tovari.price) AS Сред_Цена
FROM   slabikov.tovar AS tovari
       INNER JOIN slabikov.tip_tovara AS tip
               ON tip.id_t = tovari.id_t
GROUP  BY tip.t_name


/* Количество проданных порошков (с 2021-10-06 по текущую дату) по каждому магазину (с ед. измерения)*/
SELECT markets.NAME       AS Магазин,
       Sum(tovari.amount) AS Количество,
       izmer.m_name       AS Единицы_Измерения
FROM   slabikov.market AS markets
       INNER JOIN slabikov.tovar AS tovari
               ON tovari.id_m = markets.id_m
       INNER JOIN slabikov.tip_tovara AS tip
               ON tip.id_t = tovari.id_t
       INNER JOIN slabikov.izmer AS izmer
               ON tip.id_i = izmer.id_i
WHERE  tovari.priznak = 1
       AND '2021-10-06' <= tovari.post_prod
       AND tovari.post_prod <= Getdate()
       AND tip.t_name = 'порошки'
GROUP  BY markets.NAME,
          izmer.m_name


/* Определение количества товаров по группам в каждом магазине */
SELECT markets.NAME       AS Магазин,
       t_group.g_name     AS Группа_товаров,
       Sum(tovari.amount) AS Количество
FROM   slabikov.market AS markets
       INNER JOIN slabikov.tovar AS tovari
               ON tovari.id_m = markets.id_m
       INNER JOIN slabikov.tip_tovara AS tip
               ON tip.id_t = tovari.id_t
       INNER JOIN slabikov.t_group AS t_group
               ON t_group.id_g = tip.id_g
GROUP  BY markets.NAME,
          t_group.g_name


/* Общая сумма денег, вырученная за продажу товаров (на 2021-10-10) по каждому типу*/
SELECT tip.t_name        AS Тип_товара,
       Sum(tovari.price) AS Выручка
FROM   slabikov.tip_tovara AS tip
       INNER JOIN slabikov.tovar AS tovari
               ON tovari.id_t = tip.id_t
WHERE  tovari.priznak = 1
       AND tovari.post_prod <= '2021-10-10'
GROUP  BY tip.t_name;


/* Определение мин. цены товаров среди всех магазинов */
SELECT tip.t_name        AS Товар,
       Min(tovari.price) AS Мин_Цена
FROM   slabikov.tovar AS tovari
       INNER JOIN slabikov.tip_tovara AS tip
               ON tip.id_t = tovari.id_t
GROUP  BY tip.t_name


/* Кол-во товаров, которые поступят в продажу к 2021-10-9 по каждому типу */
SELECT tip.t_name         AS Тип_товара,
       Sum(tovari.amount) AS Количество_товара,
       izmer.m_name       AS Единицы_измерения
FROM   slabikov.tip_tovara AS tip
       INNER JOIN slabikov.tovar AS tovari
               ON tip.id_t = tovari.id_t
       INNER JOIN slabikov.izmer AS izmer
               ON tip.id_i = izmer.id_i
WHERE  tovari.priznak = 0
       AND tovari.post_prod = '2021-10-9'
GROUP  BY tip.t_name,
          izmer.m_name


/* Определение макс. цены товаров среди всех магазинов */
SELECT tip.t_name        AS Товар,
       Max(tovari.price) AS Макс_Цена
FROM   slabikov.tovar AS tovari
       INNER JOIN slabikov.tip_tovara AS tip
               ON tip.id_t = tovari.id_t
GROUP  BY tip.t_name


/* Количество овощей в наличии (на 2021-10-09) по каждому магазину (с ед. измерения)*/
SELECT markets.NAME       AS Магазин,
       Sum(tovari.amount) AS Количество,
       izmer.m_name       AS Единицы_Измерения
FROM   slabikov.market AS markets
       INNER JOIN slabikov.tovar AS tovari
               ON tovari.id_m = markets.id_m
       INNER JOIN slabikov.tip_tovara AS tip
               ON tip.id_t = tovari.id_t
       INNER JOIN slabikov.izmer AS izmer
               ON tip.id_i = izmer.id_i
WHERE  tovari.priznak = 0
       AND tovari.post_prod <= '2021-10-09'
       AND tip.t_name = 'овощи'
GROUP  BY markets.NAME,
          izmer.m_name


/* Определение мин. цены у напитков по каждому магазину */
SELECT markets.NAME      AS Магазин,
       Min(tovari.price) AS Цена
FROM   slabikov.market AS markets
       INNER JOIN slabikov.tovar AS tovari
               ON tovari.id_m = markets.id_m
       INNER JOIN slabikov.tip_tovara AS tip
               ON tip.id_t = tovari.id_t
WHERE  tip.t_name = 'напитки'
GROUP  BY markets.NAME;


/* Средняя цена проданных групп товаров по всем магазинам */
SELECT t_group.g_name    AS Группа_товара,
       Avg(tovari.price) AS Средняя_цена_продажи
FROM   slabikov.t_group AS t_group
       INNER JOIN slabikov.tip_tovara AS tip
               ON tip.id_g = t_group.id_g
       INNER JOIN slabikov.tovar AS tovari
               ON tip.id_t = tovari.id_t
WHERE  tovari.priznak = 1
GROUP  BY t_group.g_name 