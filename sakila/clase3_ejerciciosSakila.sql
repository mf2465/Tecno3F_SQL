use sakila;
select * from sakila.actor;
select actor_id, first_name, last_name from sakila.actor;
select distinct store_id from sakila.customer;
select distinct first_name from sakila.customer;
-- comienzo de los ejercicios --
-- 1
select actor_id, first_name, last_name from sakila.actor;
-- 2 no se entiende la consigna
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
-- 17 no se entiende la consigna. La primer query da nula
select * from sakila.payment;
select * from sakila.payment where customer_id = 36 and amount > 0.99 and staff_id = 1 order by amount asc;
select * from sakila.payment where customer_id = 36 or amount > 0.99 or staff_id = 1 order by amount asc;
-- 18
select * from sakila.customer;
select first_name from sakila.customer where first_name IN ('Mary','Patricia');
-- 19 el query con rental_duration > 50 arroja vacío
select * from sakila.film;
select * from sakila.film where special_features IN ('Trailers','Trailers,Deleted Scenes') and rating IN ('G','R') order by length asc;
-- select * from sakila.film where special_features IN ('Trailers','Trailers,Deleted Scenes') and rating IN ('G','R') and rental_duration > 50 order by length asc;
-- 20
select * from sakila.category;
select * from sakila.category where name NOT IN ('Action','Children','Animation');
-- 21 film_text no posee contenido en sus registros
select * from sakila.film_text;
select * from sakila.film where title IN ('zorro ark','virgin daisy','united pilot');
-- 22
select * from sakila.city;
SELECT * FROM sakila.city where city IN ('chiayi','dongying','fukuyama','kilis');
-- 23
select * from sakila.rental;
select * from sakila.rental where customer_id between 300 and 500;
select * from sakila.rental where customer_id between 300 and 500 and staff_id = 1 order by customer_id asc;
-- 24
select * from sakila.payment;
select * from sakila.payment where amount between 3 and 5 order by amount desc;
-- 25 idem 24
-- 26
select * from sakila.payment;
select * from sakila.payment where amount between 2.99 and 4.99 and staff_id = 2 ;
select * from sakila.payment where amount between 2.99 and 4.99 and staff_id = 2 and customer_id IN (1,2); -- arroja nula
-- 27 
select * from sakila.address;
select * from sakila.address where city_id between 300 and 350;
-- 28
select * from sakila.film;
select * from sakila.film where rental_rate between 0.99 and 2.99 and length <= 50 and replacement_cost < 20;
-- 29 
select * from sakila.actor;
select * from sakila.actor where first_name like 'A%' and last_name like 'B%';
-- 30
select * from sakila.actor;
select * from sakila.actor where first_name like'%a';
select * from sakila.actor where first_name like'%a' and last_name like '%n';
-- 31
select * from sakila.actor;
select * from sakila.actor where first_name like'%ne%' and last_name like '%ro%';
-- 32
select * from sakila.actor where first_name like 'a%e';
-- 33
select * from sakila.actor where first_name like'c%n' and last_name like 'g%';
-- miguelflores.devops@gmail.com 20240827 --
