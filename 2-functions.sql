use KB301_Slabikov_Lab2


CREATE TABLE dbo.debet_card (
	currency nchar(3) NOT NULL,
	balance money NOT NULL,
	CONSTRAINT PK_Debet_card PRIMARY KEY (currency)
);




CREATE TABLE dbo.exchange_rates (
	id tinyint NOT NULL,
	source_currency nchar(3) NOT NULL,
	target_currency nchar(3) NOT NULL,
	rate money NOT NULL,
	CONSTRAINT PK_Exchange_rates PRIMARY KEY (id)
);


INSERT INTO dbo.Debet_card (currency,balance) VALUES
	 ('EUR',75.9900),
	 ('GBP',99.0000),
	 ('NZD',106.0000),
	 ('RUB',0.0000),
	 ('USD',974.6000);

INSERT INTO dbo.Exchange_rates (id,source_currency,target_currency,rate) VALUES
	 (1,'USD','RUB',70.8623),
	 (2,'RUB','USD',0.0140),
	 (3,'EUR','RUB',82.4979),
	 (4,'RUB','EUR',0.0121),
	 (5,'RUB','GBP',0.0102),
	 (7,'RUB','NZD',0.0196),
	 (8,'USD','EUR',0.8590),
	 (9,'USD','GBP',0.7257),
	 (10,'USD','NZD',1.3922),
	 (11,'EUR','USD',1.1642);
INSERT INTO dbo.Exchange_rates (id,source_currency,target_currency,rate) VALUES
	 (12,'EUR','GBP',0.8448),
	 (13,'EUR','NZD',1.6208),
	 (15,'GBP','RUB',97.6482),
	 (16,'GBP','EUR',1.1836),
	 (17,'GBP','USD',1.3780),
	 (18,'GBP','NZD',1.9184),
	 (19,'NZD','USD',0.7183),
	 (20,'NZD','RUB',50.9004),
	 (21,'NZD','EUR',0.6170),
	 (22,'NZD','GBP',0.5213);
INSERT INTO dbo.Exchange_rates (id,source_currency,target_currency,rate) VALUES
	 (23,'NZD','NZD',1.0000),
	 (24,'GBP','GBP',1.0000),
	 (25,'USD','USD',1.0000),
	 (26,'RUB','RUB',1.0000),
	 (27,'EUR','EUR',1.0000);

go


/* 1. Просмотр баланса карты по всем валютам где баланс > 0 */
CREATE FUNCTION dbo.getBalance()
returns TABLE
    RETURN
      SELECT card.currency AS Валюта,
             card.balance  AS Баланс
      FROM   dbo.debet_card AS card
      WHERE  card.balance >= 0

go

--drop function dbo.getBalance


/* 3. Снятие денег в определённой валюте */
CREATE OR ALTER PROCEDURE dbo.addMoney(@currency NCHAR(3), @amount   MONEY)
AS
  BEGIN
     
      DECLARE @enough INT

	  SELECT @enough = Count(*)
      FROM   dbo.debet_card AS card
      WHERE  card.currency = @currency

	  IF ( @enough = 0 )
		BEGIN
			PRINT( 'Добавляем новую валюту' )
			INSERT INTO dbo.Debet_card (currency,balance) VALUES (@currency, @amount)
			RETURN 0
		END

      SELECT @enough = Count(*)
      FROM   dbo.debet_card AS card
      WHERE  card.balance + @amount >= 0
             AND card.currency = @currency

      IF ( @enough = 0 )
        BEGIN
            PRINT( 'Недостаточно средств на счёте' )
			RETURN -1
        END

	  DECLARE @now money

	  SELECT @now = balance + @amount from dbo.debet_card where currency = @currency
	  if (@now <= 0)
		begin
			print('удаляем из карты')
			delete from dbo.debet_card where currency = @currency
			return 0
		end

      UPDATE dbo.debet_card
      SET    balance = balance + @amount
      WHERE  currency = @currency

      PRINT( 'Успешное изменение баланса' )
	  RETURN 0
  END;

go



/* 4. Перевод из одной валюты в другую */
CREATE OR ALTER PROCEDURE dbo.convertMoney(@source_curr NCHAR(3),
                              @amount      MONEY,
                              @target_curr NCHAR(3))
AS
  BEGIN
	  DECLARE @exist INT
	  SET @exist = 0

	  SELECT @exist = COUNT(*)
      FROM   dbo.debet_card AS card
      WHERE  card.currency = @source_curr OR card.currency = @target_curr

	  IF @exist < 2
	  BEGIN
		PRINT('Не найдена одна из валют на счёте')
		RETURN -1
	  END

      DECLARE @rate MONEY

      SELECT @rate = rates.rate
      FROM   dbo.exchange_rates AS rates
      WHERE  rates.source_currency = @source_curr
             AND rates.target_currency = @target_curr

	  SET @rate = @rate * @amount
	  SET @amount = @amount * -1
	  print (@rate)
	  print (@amount)
    
	  EXEC dbo.addMoney @source_curr, @amount
      EXEC dbo.addMoney @target_curr, @rate

      PRINT( 'Успешная конвертация' )
	  return 0
  END;

go

/* 5. Баланс карты в одной валюте */
CREATE FUNCTION dbo.getBalanceInCurrency(@curr NCHAR(3))
returns TABLE
    RETURN
      SELECT Sum(tabl.Баланс_карты * tabl.Курс_перевода)
             AS
             Баланс
      FROM   (SELECT card.balance AS Баланс_карты,
                     rates.rate   AS Курс_перевода
              FROM   dbo.debet_card AS card
                     INNER JOIN dbo.exchange_rates AS rates
                             ON card.currency = rates.source_currency
                                AND rates.target_currency = @curr) AS tabl;

go 

                        

/* Просмотр баланса карты по всем валютам где баланс > 0 */
use KB301_Slabikov_Lab2
select * from dbo.getBalance();

/* Пополнение денег в определённой валюте */

select * from dbo.getBalance();
exec dbo.addMoney 'RUB', 500;
select * from dbo.getBalance();


/* Перевод из одной валюты в другую */

select * from dbo.getBalance();
exec dbo.convertMoney 'USD', 2, 'RUB';
select * from dbo.getBalance();

/* Баланс карты в одной валюте */
select * from dbo.getBalanceInCurrency('RUB')
go



CREATE FUNCTION dbo.getBalanceInCurrency2(@curr NCHAR(3))
returns money
begin
	declare @result money = 0
	declare @new_currency NCHAR(3)
	declare @new_balance money
	declare @converted money
	declare exchange_curs cursor for 
	SELECT card.currency,
           card.balance
              FROM dbo.debet_card AS card     
			  
	open exchange_curs
	fetch next from exchange_curs
	into @new_currency, @new_balance
	while @@FETCH_STATUS = 0
		begin
		exec @converted = dbo.convertMoney @new_currency, @new_balance, @curr
		set @result = @result + @converted
		end
	close exchange_curs
	deallocate exchange_curs

	return @result
end;
