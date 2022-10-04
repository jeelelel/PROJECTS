--DROP TABLE
Drop Table staff_dim cascade constraints purge;
Drop Table pet_dim cascade constraints purge;
Drop Table season_dim cascade constraints purge;
Drop Table product_dim cascade constraints purge;
Drop Table service_dim cascade constraints purge;
Drop Table bridgetable cascade constraints purge;
Drop Table pet9_dw_fact cascade constraints purge;

--STAFF DIM
Create table staff_dim as
SELECT staff_id, expertise as staff_expertise, staff_level
FROM Pet9.Staff;

--PET DIM
Create table pet_dim as
SELECT Pet_ID, pet_type
FROM Pet9.Pet;

--SEASON DIM
Create table season_dim (
season_code Number (1) NOT NULL,
season_desc Varchar2 (10) NOT NULL
);

--INSERT VALUES TO SEASON DIM
Insert into season_dim values (1, 'Spring');
Insert into season_dim values (2, 'Summer');
Insert into season_dim values (3, 'Autumn');
Insert into season_dim values (4, 'Winter');

--PRODUCT DIM
Create table product_dim as
SELECT *
FROM Pet9.product;

--BRIDGETABLE
Create table bridgetable as
SELECT *
FROM Pet9.product_use;

--SERVICE DIM
Create table service_dim as
SELECT s.service_id, s.service_desc, 
    1.0/count(p.product_id) as weightfactor,
    listagg (p.product_id, '_') within group
    (order by p.product_id) as product_attributes
FROM Pet9.Service s, Pet9.Product p
group by s.service_id, s.service_desc;


--FACT TABLE
create table pet9_dw_fact as
select v.service_id, v.pet_id, v.staff_id, v.visit_date,
    sum(v.price) as total_income,
    count(v.pet_id) as num_visit
from Pet9.Visit v
group by v.pet_id, v.staff_id, v.service_id, v.visit_date
order by service_id;

ALTER table pet9_dw_fact
ADD(season_code number);

Update pet9_dw_fact
Set season_code = 1
Where to_char(visit_date, 'MM')>= '09' and to_char(visit_date, 'MM') <='11';

Update pet9_dw_fact
Set season_code = 2
Where to_char(visit_date, 'MM')>= '12' or to_char(visit_date, 'MM') <='02';

Update pet9_dw_fact
Set season_code = 3
Where to_char(visit_date, 'MM')>= '03' and to_char(visit_date, 'MM') <='05';

Update pet9_dw_fact
Set season_code = 4
Where to_char(visit_date, 'MM')>= '06' and to_char(visit_date, 'MM') <='08';

alter table pet9_dw_fact drop column visit_date;

select * from pet9_dw_fact; 

