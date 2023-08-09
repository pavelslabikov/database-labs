
USE KB301_Slabikov_lab4
GO
CREATE TABLE fees( 
	ID INT IDENTITY,
	subscription FLOAT NOT NULL,
	minutes FLOAT NOT NULL,
	per_minute_fee FLOAT NOT NULL
	CONSTRAINT fees__PK PRIMARY KEY(ID)
)
GO


CREATE OR ALTER FUNCTION get_best_fee(@minutes FLOAT)
	RETURNS INT
	AS
	BEGIN
		IF @minutes < 0 or @minutes > 43200 
			BEGIN
				return cast('Некорректный аргумент функции' as int);		
			END
		DECLARE @id INT	
		SET @id = (SELECT TOP 1 r.id
           FROM   (SELECT ( subscription + per_minute_fee * CASE WHEN
                                           @minutes - minutes < 0 THEN 0 -- не израсходовал все минуты
                                           ELSE @minutes - minutes
                                                            END ) AS cost,
                          id
                   FROM   fees) AS r
           ORDER  BY cost ASC)
		RETURN @id
	END
 GO



CREATE OR ALTER PROCEDURE OptimalTest
AS
BEGIN
	DECLARE @points table (val float)
	INSERT INTO @points VALUES (0), (43200)
	-- точки пересечения каждой прямой second (y = kx + b) с параллельными оси X прямыми first (y = first.fee)
	INSERT INTO @points 
				SELECT (first.subscription - (second.subscription - (second.per_minute_fee * second.minutes))) / second.per_minute_fee
				FROM fees as first, fees as second
				WHERE second.per_minute_fee <> 0 -- условие, что k != 0
					AND first.ID <> second.ID 
					AND (first.subscription - (second.subscription - (second.per_minute_fee * second.minutes))) / second.per_minute_fee > 0 
					AND (first.subscription - (second.subscription - (second.per_minute_fee * second.minutes))) / second.per_minute_fee <= first.minutes
	
	-- точки пересечения каждой прямой second (y = kx + b) с прямыми first (y = kx + b)
	INSERT INTO @points 
				SELECT ((second.subscription - (second.per_minute_fee * second.minutes)) - (first.subscription - (first.per_minute_fee * first.minutes))) / (first.per_minute_fee - second.per_minute_fee)
				FROM fees as first, fees as second
				WHERE first.per_minute_fee <> 0 AND second.per_minute_fee <> 0 -- условие, что k != 0
					AND first.ID <> second.ID 
					AND ((second.subscription - (second.per_minute_fee * second.minutes)) - (first.subscription - (first.per_minute_fee * first.minutes))) / (first.per_minute_fee - second.per_minute_fee) > 0 

	DECLARE @res TABLE (
			id int,
			l float,
			r float
	)
	DECLARE @left float, @right float, @cursor CURSOR
	SET @cursor = CURSOR SCROLL FOR SELECT DISTINCT * FROM @points ORDER BY val ASC -- В курсоре все точки пересечения в порядке возрастания
	
	
	OPEN @cursor
	FETCH NEXT FROM @cursor INTO @right
	SET @left = @right
	FETCH NEXT FROM @cursor INTO @right
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @last_id int, @curr_id int
		SELECT @last_id = r.id FROM @res as r where r.r = @left
		SET @curr_id = dbo.get_best_fee((@left + @right) / 2)
		IF @curr_id = @last_id -- Если предыдущий лучший тариф равен текущему лучшему тарифу (надо склеить)
		BEGIN
			UPDATE @res set r = @right where r = @left
		END
		ELSE
		BEGIN
			INSERT INTO @res VALUES (@curr_id, @left, @right)
		END
		SET @left=@right
		FETCH NEXT FROM @cursor INTO @right
	END
	CLOSE @cursor
	DEALLOCATE @cursor

	SELECT l as Левый_конец_отрезка, r as Правый_конец_отрезка, r.id as ID_тарифа, f.name as Название_тарифа
		   FROM @res as r JOIN dbo.fees as f on f.ID = r.id ORDER BY L ASC
END
GO

SELECT DBO.get_best_fee(100) AS ID;

INSERT INTO fees  (ID, subscription, minutes, per_minute_fee, name) VALUES
	(0, 6, 43200, 0, 'Безлимит 1'), -- безлимит
	(1, 2, 6, 1, 'Смешанный 1'), -- смешанный
	(2, 0, 0, 0.5, 'Поминутный 1') -- без абонентской платы
GO

EXEC dbo.OptimalTest
GO


delete from fees;
