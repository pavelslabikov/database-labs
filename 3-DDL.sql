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


-- ������������ ������
alter table dbo.registry
add constraint CHK_car_number 
check(
	car_number like '[ETYOPAHKXCBM][0-9][0-9][0-9][ETYOPAHKXCBM][ETYOPAHKXCBM][0-9][0-9]' 
	or car_number like '[ETYOPAHKXCBM][0-9][0-9][0-9][ETYOPAHKXCBM][ETYOPAHKXCBM][127][0-9][0-9]'
)
go


-- ������� ��� �����������
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
insert into @existing_car (in_city, last_time, post, city_name) -- ������ ������ �� ������� � ������� ��� � inserted
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
	print('������ ��� ���� ������ ������� / ������� � ��������� �����')
	return;
end

declare @city_name varchar(50) = null -- ����� �� inserted
select @city_name = posts.city 
from inserted as i 
join dbo.police_posts as posts on posts.id = i.post

if exists (
	select 1 from @existing_car as existing, inserted as new
	where new.in_city = 0 and existing.city_name != @city_name
)
begin
	print('������ ������� �� ������, � ������� �� ����� �� �������')
	return;
end

insert into dbo.registry
select * from inserted
go


-- ������� ��� ���������� ��������������� �������
create or alter trigger after_trigger 
on dbo.registry after insert
as

declare @inserted_city varchar(50) -- ����� �� inserted
select @inserted_city = posts.city from inserted as i
join dbo.police_posts as posts on i.post = posts.id

declare @existing_car table
(
in_city bit,
last_time datetime,
post int,
city_name varchar(50)
)
insert into @existing_car (in_city, last_time, post, city_name) -- ������� ��������� �� ������� ������ � ��� �� ������� � � ��� �� ������� � �������
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


-- ������� ������
create or alter view domestic_cars
as
select r.car_number as �����_������, r.in_time as �����_������, r.out_time as �����_������, r.city as �����, reg.name as ������ 
from dbo.recordings as r 
join dbo.police_posts as ins on r.in_post = ins.id
join dbo.police_posts as outs on r.out_post = outs.id
join dbo.region_numbers as dict on SUBSTRING(r.car_number, 7, 3) = cast(dict.alternative_number as varchar)
join dbo.regions as reg on reg.number = dict.region_number 
where r.in_time > r.out_time and ins.city = outs.city 
and SUBSTRING(r.car_number, 7, 3) = cast(dict.alternative_number as varchar)  
go

-- ���������� ������
create or alter view tranzit_cars
as
select r.car_number as �����_������, r.in_time as �����_������, r.out_time as �����_������, r.city as �����, dict.name as ������ 
from dbo.recordings as r 
join dbo.police_posts as ins on r.in_post = ins.id
join dbo.police_posts as outs on r.out_post = outs.id
join dbo.cities as cit on outs.city = cit.name
join dbo.regions as dict on cit.region = dict.number 
where r.in_time < r.out_time and r.in_post != r.out_post and ins.city = outs.city 
and SUBSTRING(r.car_number, 7, 3) != cast(dict.number as varchar)  
go

-- ����������� ������
create or alter view nonresident_cars
as
select r.car_number as �����_������, r.in_time as �����_������, r.out_time as �����_������, ins.city as �����, reg.name as ������ 
from dbo.recordings as r 
join dbo.police_posts as ins on r.in_post = ins.id
join dbo.police_posts as outs on r.out_post = outs.id
join dbo.region_numbers as dict on SUBSTRING(r.car_number, 7, 3) = cast(dict.alternative_number as varchar)
join dbo.regions as reg on reg.number = dict.region_number 
where r.in_time < r.out_time and r.in_post = r.out_post 
go

-- ����� ��� ���������
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, getdate(), 'A134RA66', 6); 

-- �������������� ������
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, getdate(), 'A134BA766', 6); 

-- ����� � 01
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, getdate(), 'A134BA01', 20); 

delete from dbo.registry

-- ������������ ������ ������
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, getdate(), '11111166', 6); 
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, getdate(), '55', 6); 

-- ��� ���� ������ ������� � ���� ����� � ������� 4
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 0, getdate(), 'A123BC74', 4);
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 0, getdate(), 'A123BC74', 4);
DELETE FROM KB301_Slabikov_Lab3.dbo.registry

-- ������� � ������� ��� ��������
declare @t datetime = getdate()
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 0, getdate(), 'B123BC74', 4);
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, getdate(), 'B123BC74', 4);
DELETE FROM KB301_Slabikov_Lab3.dbo.registry

-- ��� ���� ������ ������� �� �������������  ����� ������ �����
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 0, getdate(), 'A143BC66', 1);
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 0, getdate(), 'A143BC66', 3);
DELETE FROM KB301_Slabikov_Lab3.dbo.registry


DELETE FROM KB301_Slabikov_Lab3.dbo.recordings
/* ������ O777AO174 �� ����� ���:
1. ����� �� ����� ����� 4 ����
2. ����� � ����� ����� 6 ����
���������: ������ �������
*/
select * from dbo.domestic_cars
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 0, getdate(), 'O777AO01', 4);
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, DATEADD(hour, 1, getdate()), 'O777AO01', 6);
select * from dbo.domestic_cars

/* ������ C456EF77 �� ��� ���:
1. ����� �  ��� ����� 12 ����
2. ����� �� ��� ����� 12 ����
���������: ������ �����������
*/
select * from dbo.nonresident_cars
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, getdate(), 'C456EH77', 12);
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 0, DATEADD(hour, 1, getdate()), 'C456EH77', 12);
select * from dbo.nonresident_cars

/* ������ A123BC66 �� ������������ ���:
2. ����� � ����� ����� 4 ����
3. ����� �� ����� ����� 7 ����
���������: ������ ���������� � �����
*/
select * from dbo.tranzit_cars
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, DATEADD(hour, 1, getdate()), 'A123BC66', 4);
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 0, DATEADD(hour, 2, getdate()), 'A123BC66', 7);
select * from dbo.tranzit_cars










