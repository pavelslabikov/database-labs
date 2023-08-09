-- Ѕуква без кириллицы
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, getdate(), 'A134RA66', 6); 
-- Ќесуществующий регион
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, getdate(), 'A134RA766', 6); 
-- Ќекорректный формат номера
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, getdate(), '11111166', 6); 
-- ƒва раза подр€д въехать в пост √»Ѕƒƒ с номером 4
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, getdate(), 'A123BC74', 4);
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, getdate(), 'A123BC74', 4);
DELETE FROM KB301_Slabikov_Lab3.dbo.registry
-- ƒва раза подр€д выехать из ≈катеринбурга  через разные посты
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 0, getdate(), 'A123BC66', 1);
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 0, getdate(), 'A123BC74', 3);
DELETE FROM KB301_Slabikov_Lab3.dbo.registry


DELETE FROM KB301_Slabikov_Lab3.dbo.recordings
/* ћашина O777AO174 из „≈ЋяЅ обл:
1. выезд из „≈ЋяЅ через 4 пост
2. заезд в „≈ЋяЅ через 6 пост
–езультат: машина местна€
*/
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 0, getdate(), 'O777AO174', 4);
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, DATEADD(hour, 1, getdate()), 'O777AO174', 6);

/* ћашина A123BC66 из —вердловской обл:
1. выезд из ≈ Ѕ через 0 пост
2. заезд в „≈ЋяЅ через 4 пост
3. выезд из „≈ЋяЅ через 7 пост
4. заезд в ≈ Ѕ через 1 пост
–езультат: машина транзитна€ в „≈ЋяЅ
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









