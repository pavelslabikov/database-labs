use KB301_Slabikov_Lab2
go

create or alter procedure show_rates
as
begin
	DECLARE @cursor CURSOR, @result varchar(100), @query varchar(MAX)
	SELECT @result = STUFF(
                    (   SELECT DISTINCT ',' + CONVERT(NVARCHAR(20), source_currency) 
                        FROM dbo.exchange_rates  
						FOR xml path('')
                    ) , 1 , 1 , '')

	set @query = 'select cu as [Курс валют], ' + @result +' 
from (select distinct source_currency as cu, target_currency as ta, rate as r from dbo.exchange_rates) as curr
pivot (sum(r) for ta in (' + @result + ') ) as t'
	exec(@query)

end
go


select cu as [Курс валют], EUR, GBP, NZD, RUB, USD 
from (select distinct source_currency as cu, target_currency as ta, rate as r from dbo.exchange_rates) as curr
pivot (sum(r) for ta in (EUR, GBP, NZD, RUB, USD) ) as t

update dbo.exchange_rates set rate = 72 where source_currency = 'USD' and target_currency = 'RUB'


exec dbo.show_rates

delete from dbo.exchange_rates where source_currency = 'USD' or target_currency = 'USD'
