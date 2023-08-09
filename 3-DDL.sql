CREATE TABLE KB301_Slabikov_Lab3.dbo.recordings (
	id int NOT NULL,
	car_number varchar(16) NOT NULL,
	in_time datetime NULL,
	out_time datetime NULL,
	in_post int NULL,
	out_post int NULL,
	city varchar(50) NOT NULL,
	CONSTRAINT PK_recordings PRIMARY KEY (id)
);

CREATE TABLE KB301_Slabikov_Lab3.dbo.regions (
	[number] tinyint NOT NULL,
	name varchar(50) NOT NULL,
	CONSTRAINT PK_regions PRIMARY KEY ([number])
);


CREATE TABLE KB301_Slabikov_Lab3.dbo.cities (
	name varchar(50) NOT NULL,
	region tinyint NOT NULL,
	CONSTRAINT PK_cities PRIMARY KEY (name),
	CONSTRAINT FK_city_region FOREIGN KEY (region) REFERENCES KB301_Slabikov_Lab3.dbo.regions([number]) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE KB301_Slabikov_Lab3.dbo.police_posts (
	id int NOT NULL,
	city varchar(50) NOT NULL,
	CONSTRAINT PK_police_posts PRIMARY KEY (id),
	CONSTRAINT FK_post_city FOREIGN KEY (city) REFERENCES KB301_Slabikov_Lab3.dbo.cities(name) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE KB301_Slabikov_Lab3.dbo.region_numbers (
	region_number tinyint NOT NULL,
	alternative_number tinyint NOT NULL,
	CONSTRAINT PK_region_numbers PRIMARY KEY (alternative_number),
	CONSTRAINT FK__region_numbers FOREIGN KEY (region_number) REFERENCES KB301_Slabikov_Lab3.dbo.regions([number]) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE KB301_Slabikov_Lab3.dbo.registry (
	id int DEFAULT NEXT VALUE FOR [dbo].[registry_seq] NOT NULL,
	in_city bit NOT NULL,
	[time] datetime NOT NULL,
	car_number varchar(16) NOT NULL,
	post int NOT NULL,
	CONSTRAINT PK_registry PRIMARY KEY (id),
	CONSTRAINT FK_registry_posts FOREIGN KEY (post) REFERENCES KB301_Slabikov_Lab3.dbo.police_posts(id) ON DELETE CASCADE ON UPDATE CASCADE
);


-- Правильность номера
alter table dbo.registry
add constraint CHK_car_number 
check(
	car_number like '[ETYOPAHKXCBM][0-9][0-9][0-9][ETYOPAHKXCBM][ETYOPAHKXCBM][0-9][0-9]' 
	or car_number like '[ETYOPAHKXCBM][0-9][0-9][0-9][ETYOPAHKXCBM][ETYOPAHKXCBM][127][0-9][0-9]'
)
go


-- Триггер для ограничений
use KB301_Slabikov_Lab3
go
create or alter trigger validating_trigger 
on dbo.registry instead of insert
as

declare @existing_car table
(
in_city bit,
last_time datetime,
post int,
city_name varchar(50)
)
insert into @existing_car (in_city, last_time, post, city_name) -- Свежая машина из реестра с номером как у inserted
select top 1 r.in_city, r.time, r.post, posts.city 
from inserted as i, dbo.registry as r 
join dbo.police_posts as posts on posts.id = r.post
where r.car_number = i.car_number
order by r.time desc

if exists (
	select 1 from @existing_car as existing, inserted as new
	where existing.in_city = new.in_city or existing.last_time = new.time
)
begin
	print('Нельзя два раза подряд въехать / выехать в населённый пункт')
	return;
end

declare @city_name varchar(50) = null -- Город из inserted
select @city_name = posts.city 
from inserted as i 
join dbo.police_posts as posts on posts.id = i.post

if exists (
	select 1 from @existing_car as existing, inserted as new
	where new.in_city = 0 and existing.city_name != @city_name
)
begin
	print('Нельзя выехать из города, в который до этого не въехали')
	return;
end

insert into dbo.registry
select * from inserted
go


-- Триггер для заполнения вспомогательной таблицы
create or alter trigger after_trigger 
on dbo.registry after insert
as

declare @inserted_city varchar(50) -- Город из inserted
select @inserted_city = posts.city from inserted as i
join dbo.police_posts as posts on i.post = posts.id

declare @existing_car table
(
in_city bit,
last_time datetime,
post int,
city_name varchar(50)
)
insert into @existing_car (in_city, last_time, post, city_name) -- Находит последнюю по времени машину с тем же номером и с тем же городом в реестре
select top 1 r.in_city, r.time, r.post, posts.city 
from inserted as i, dbo.registry as r 
join dbo.police_posts as posts on posts.id = r.post
where r.car_number = i.car_number and posts.city = @inserted_city and r.time < i.time
order by r.time desc

if exists (
	select 1 from inserted
	where inserted.in_city = 1
)
begin 
	insert into dbo.recordings (id, car_number, in_time, out_time, in_post, out_post, city)
	select NEXT VALUE FOR dbo.registry_seq, i.car_number, i.time, existing.last_time, i.post, existing.post, @inserted_city  
	from inserted as i, @existing_car as existing
end
else 
begin 
	insert into dbo.recordings (id, car_number, in_time, out_time, in_post, out_post, city)
	select NEXT VALUE FOR dbo.registry_seq, i.car_number, existing.last_time, i.time, existing.post, i.post, @inserted_city   
	from inserted as i, @existing_car as existing
end
go


-- Местные машины
create or alter view domestic_cars
as
select r.car_number as Номер_машины, r.in_time as Время_въезда, r.out_time as Время_выезда, r.city as Город, reg.name as Регион 
from dbo.recordings as r 
join dbo.police_posts as ins on r.in_post = ins.id
join dbo.police_posts as outs on r.out_post = outs.id
join dbo.region_numbers as dict on SUBSTRING(r.car_number, 7, 3) = cast(dict.alternative_number as varchar)
join dbo.regions as reg on reg.number = dict.region_number 
where r.in_time > r.out_time and ins.city = outs.city 
and SUBSTRING(r.car_number, 7, 3) = cast(dict.alternative_number as varchar)  
go

-- Транзитные машины
create or alter view tranzit_cars
as
select r.car_number as Номер_машины, r.in_time as Время_въезда, r.out_time as Время_выезда, r.city as Город, dict.name as Регион 
from dbo.recordings as r 
join dbo.police_posts as ins on r.in_post = ins.id
join dbo.police_posts as outs on r.out_post = outs.id
join dbo.cities as cit on outs.city = cit.name
join dbo.regions as dict on cit.region = dict.number 
where r.in_time < r.out_time and r.in_post != r.out_post and ins.city = outs.city 
and SUBSTRING(r.car_number, 7, 3) != cast(dict.number as varchar)  
go

-- Иногородние машины
create or alter view nonresident_cars
as
select r.car_number as Номер_машины, r.in_time as Время_въезда, r.out_time as Время_выезда, ins.city as Город, reg.name as Регион 
from dbo.recordings as r 
join dbo.police_posts as ins on r.in_post = ins.id
join dbo.police_posts as outs on r.out_post = outs.id
join dbo.region_numbers as dict on SUBSTRING(r.car_number, 7, 3) = cast(dict.alternative_number as varchar)
join dbo.regions as reg on reg.number = dict.region_number 
where r.in_time < r.out_time and r.in_post = r.out_post 
go

-- Буква без кириллицы
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, getdate(), 'A134RA66', 6); 

-- Несуществующий регион
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, getdate(), 'A134BA766', 6); 

-- Номер с 01
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, getdate(), 'A134BA01', 20); 

delete from dbo.registry

-- Некорректный формат номера
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, getdate(), '11111166', 6); 
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, getdate(), '55', 6); 

-- Два раза подряд въехать в пост ГИБДД с номером 4
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 0, getdate(), 'A123BC74', 4);
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 0, getdate(), 'A123BC74', 4);
DELETE FROM KB301_Slabikov_Lab3.dbo.registry

-- Въехать и выехать без таймаута
declare @t datetime = getdate()
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 0, getdate(), 'B123BC74', 4);
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, getdate(), 'B123BC74', 4);
DELETE FROM KB301_Slabikov_Lab3.dbo.registry

-- Два раза подряд выехать из Екатеринбурга  через разные посты
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 0, getdate(), 'A143BC66', 1);
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 0, getdate(), 'A143BC66', 3);
DELETE FROM KB301_Slabikov_Lab3.dbo.registry


DELETE FROM KB301_Slabikov_Lab3.dbo.recordings
/* Машина O777AO174 из ЧЕЛЯБ обл:
1. выезд из ЧЕЛЯБ через 4 пост
2. заезд в ЧЕЛЯБ через 6 пост
Результат: машина местная
*/
select * from dbo.domestic_cars
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 0, getdate(), 'O777AO01', 4);
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, DATEADD(hour, 1, getdate()), 'O777AO01', 6);
select * from dbo.domestic_cars

/* Машина C456EF77 из МСК обл:
1. заезд в  МСК через 12 пост
2. выезд из МСК через 12 пост
Результат: машина иногородняя
*/
select * from dbo.nonresident_cars
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, getdate(), 'C456EH77', 12);
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 0, DATEADD(hour, 1, getdate()), 'C456EH77', 12);
select * from dbo.nonresident_cars

/* Машина A123BC66 из Свердловской обл:
2. заезд в ЧЕЛЯБ через 4 пост
3. выезд из ЧЕЛЯБ через 7 пост
Результат: машина транзитная в ЧЕЛЯБ
*/
select * from dbo.tranzit_cars
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, DATEADD(hour, 1, getdate()), 'A123BC66', 4);
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 0, DATEADD(hour, 2, getdate()), 'A123BC66', 7);
select * from dbo.tranzit_cars










