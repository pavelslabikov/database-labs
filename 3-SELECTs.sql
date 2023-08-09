-- Буква без кириллицы
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, getdate(), 'A134RA66', 6); 
-- Несуществующий регион
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, getdate(), 'A134RA766', 6); 
-- Некорректный формат номера
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, getdate(), '11111166', 6); 
-- Два раза подряд въехать в пост ГИБДД с номером 4
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, getdate(), 'A123BC74', 4);
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, getdate(), 'A123BC74', 4);
DELETE FROM KB301_Slabikov_Lab3.dbo.registry
-- Два раза подряд выехать из Екатеринбурга  через разные посты
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 0, getdate(), 'A123BC66', 1);
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 0, getdate(), 'A123BC74', 3);
DELETE FROM KB301_Slabikov_Lab3.dbo.registry


DELETE FROM KB301_Slabikov_Lab3.dbo.recordings
/* Машина O777AO174 из ЧЕЛЯБ обл:
1. выезд из ЧЕЛЯБ через 4 пост
2. заезд в ЧЕЛЯБ через 6 пост
Результат: машина местная
*/
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 0, getdate(), 'O777AO174', 4);
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, DATEADD(hour, 1, getdate()), 'O777AO174', 6);

/* Машина A123BC66 из Свердловской обл:
1. выезд из ЕКБ через 0 пост
2. заезд в ЧЕЛЯБ через 4 пост
3. выезд из ЧЕЛЯБ через 7 пост
4. заезд в ЕКБ через 1 пост
Результат: машина транзитная в ЧЕЛЯБ
*/
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 0, getdate(), 'A123BC66', 0);
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, DATEADD(hour, 1, getdate()), 'A123BC66', 4);
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 0, DATEADD(hour, 2, getdate()), 'A123BC66', 7);
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, DATEADD(hour, 3, getdate()), 'A123BC66', 1);









