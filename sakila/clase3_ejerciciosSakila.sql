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
 


 


