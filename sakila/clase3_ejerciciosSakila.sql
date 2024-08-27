use sakila;
select * from sakila.actor;
select actor_id, first_name, last_name from sakila.actor;
select distinct store_id from sakila.customer;
select distinct first_name from sakila.customer;
-- comienzo de los ejercicios --
-- 1
select actor_id, first_name, last_name from sakila.actor;
-- 2
alter table customer
change first_name Nombre varchar(45);
describe customer;
-- 3
select * from customer order by apellido desc; 
-- 4
select * from sakila.payment;
select min(amount) as Cantidad_más_baja from sakila.payment;
select max(amount) as Cantidad_más_alta from sakila.payment;
-- 5
select * from sakila.payment order by amount asc;
-- where
select * from sakila.actor;
select * from sakila.actor where first_name='ED';
select * from sakila.city;
select * from sakila.city where city ='London';
select * from sakila.city where country_id = 102;
select * from sakila.inventory where film_id >= 50;
-- 6
select * from sakila.payment;
select distinct amount from sakila.payment where amount < 3 order by amount desc;
-- 7 
select * from sakila.staff;
select * from sakila.staff where staff_id != 2;
-- 8
select * from sakila.language;
select * from sakila.language where name != 'german';
-- 9
select * from sakila.film;
select description, release_year from sakila.film where title = 'IMPACT ALADDIN'; 
-- 10
select * from sakila.payment where amount > 0.99 order by amount desc;
-- 11
select * from sakila.country where country = 'Algeria' and country_id = 2;
-- 12
select * from sakila.country where country = 'Algeria' or country_id = 12;
-- 13 
select * from sakila.language where language_id = 1 or name = 'german';
-- 14
SELECT * FROM sakila.category;
select * from sakila.category where name != 'action';
-- 15
select * from sakila.film where rating != 'PG';
-- 16
select distinct rating from sakila.film where rating != 'PG';
