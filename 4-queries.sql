
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
				return cast('������������ �������� �������' as int);		
			END
		DECLARE @id INT	
		SET @id = (SELECT TOP 1 r.id
           FROM   (SELECT ( subscription + per_minute_fee * CASE WHEN
                                           @minutes - minutes < 0 THEN 0 -- �� ������������ ��� ������
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
	-- ����� ����������� ������ ������ second (y = kx + b) � ������������� ��� X ������� first (y = first.fee)
	INSERT INTO @points 
				SELECT (first.subscription - (second.subscription - (second.per_minute_fee * second.minutes))) / second.per_minute_fee
				FROM fees as first, fees as second
				WHERE second.per_minute_fee <> 0 -- �������, ��� k != 0
					AND first.ID <> second.ID 
					AND (first.subscription - (second.subscription - (second.per_minute_fee * second.minutes))) / second.per_minute_fee > 0 
					AND (first.subscription - (second.subscription - (second.per_minute_fee * second.minutes))) / second.per_minute_fee <= first.minutes
	
	-- ����� ����������� ������ ������ second (y = kx + b) � ������� first (y = kx + b)
	INSERT INTO @points 
				SELECT ((second.subscription - (second.per_minute_fee * second.minutes)) - (first.subscription - (first.per_minute_fee * first.minutes))) / (first.per_minute_fee - second.per_minute_fee)
				FROM fees as first, fees as second
				WHERE first.per_minute_fee <> 0 AND second.per_minute_fee <> 0 -- �������, ��� k != 0
					AND first.ID <> second.ID 
					AND ((second.subscription - (second.per_minute_fee * second.minutes)) - (first.subscription - (first.per_minute_fee * first.minutes))) / (first.per_minute_fee - second.per_minute_fee) > 0 

	DECLARE @res TABLE (
			id int,
			l float,
			r float
	)
	DECLARE @left float, @right float, @cursor CURSOR
	SET @cursor = CURSOR SCROLL FOR SELECT DISTINCT * FROM @points ORDER BY val ASC -- � ������� ��� ����� ����������� � ������� �����������
	
	
	OPEN @cursor
	FETCH NEXT FROM @cursor INTO @right
	SET @left = @right
	FETCH NEXT FROM @cursor INTO @right
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @last_id int, @curr_id int
		SELECT @last_id = r.id FROM @res as r where r.r = @left
		SET @curr_id = dbo.get_best_fee((@left + @right) / 2)
		IF @curr_id = @last_id -- ���� ���������� ������ ����� ����� �������� ������� ������ (���� �������)
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

	SELECT l as �����_�����_�������, r as ������_�����_�������, r.id as ID_������, f.name as ��������_������
		   FROM @res as r JOIN dbo.fees as f on f.ID = r.id ORDER BY L ASC
END
GO

SELECT DBO.get_best_fee(100) AS ID;

INSERT INTO fees  (ID, subscription, minutes, per_minute_fee, name) VALUES
	(0, 6, 43200, 0, '�������� 1'), -- ��������
	(1, 2, 6, 1, '��������� 1'), -- ���������
	(2, 0, 0, 0.5, '���������� 1') -- ��� ����������� �����
GO

EXEC dbo.OptimalTest
GO


delete from fees;
