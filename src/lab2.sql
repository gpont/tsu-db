-- 1. Создать представления по описанию.

-- 1.1. Данные о сотрудниках: имя, должность, адрес (одной строкой), телефон, срок работы в месяцах.

create or replace view Staff_View(name, pos, address, phone, experience) as
select employee_name,
       ( case
             when chief_id is null then 'chief'
             else 'courier'
         end ),
       street || ' ' || house_number,
       phone,
       extract('month' from sysdate) - extract('month' from start_date)
from Employees;

-- 1.2. Данные о заказах: номер заказа, номер заказчика, номер курьера, срок доставки общая стоимость заказа.

create or replace view Order_View( order_id,
                                   customer_id,
                                   employee_id,
                                   delivery_date,
                                   total_price )
    as with Total_Orders_Price
    as ( select Orders.order_id,
               sum(price * quantity) as total_price
         from Orders
         left join Order_Details on Orders.order_id = Order_Details.order_id
         left join Products on Products.product_id = Order_Details.product_id
         group by Orders.order_id )
select Orders.order_id,
       customer_id,
       employee_id,
       delivery_date,
       total_price
from Orders
inner join Total_Orders_Price on Orders.order_id = Total_Orders_Price.order_id;

-- 1.3. Расширенные данные о заказе: номер заказа, имя курьера, имя заказчика, обща стоимость заказа, строк доставки, отметка о том был ли заказа доставлен вовремя.

create view Order_View_Extended(order_id, employee_name, customer_name, total_price, delivery_date, delivered_in_time) as
select Orders.order_id,
       employee_name,
       customer_name,
       total_price,
       Orders.delivery_date,
       ( case
             when Orders.end_date > Orders.delivery_date then 0
             else 1
         end )
from Orders
inner join Order_view on Orders.order_id = Order_view.order_id
inner join Employees on Employees.employee_id = Orders.employee_id
inner join Customers on Customers.customer_id = Orders.customer_id;

-- 1.4. Представление, позволяющее получить маршрут курьера.

create or replace view Courier_Route(employee_id, employee_name, street, Locations.house_number, delivery_date) as
select employee_id,
       employee_name,
       street,
       Locations.house_number,
       delivery_date
from Employees
inner join Orders on Employees.employee_id = Orders.employee_id
inner join Locations on Locations.location_id = Orders.location_id;

-- 2. Создать ограничения по требованиям.

-- 2.1. Ни один заказ не может включать не известные продукты, доставляться не известным сотрудником, по не известному адресу.

alter table Orders modify ( employee_id INT not null);
alter table Orders modify ( location_id INT not null);
alter table Order_Details modify ( product_id INT not null);

-- 2.2. Начальником может быть только реально существующий сотрудник.

alter table Employees modify ( constraint chief
                               foreign key (chief_id) references Employees (employee_id));

-- 2.3. Цена товара не может быть отражательной или нулевой.

alter table Products modify ( constraint on_price check (price > 0));

-- 2.4. Наименования категории, наименования продуктов,  имена сотрудников, имена заказчиков, названия районов, названия улиц, номера домов не могут быть пустыми.

alter table Products modify ( product_name varchar2(256) not null);
alter table Categories modify ( categories_name varchar2(256) not null);
alter table Employees modify ( employee_name varchar(256) not null);
alter table Customers modify ( customer_name varchar2(256) not null);
alter table Locations modify ( street varchar2(256) not null);
alter table Areas modify ( areas_name varchar2(256) not null);
alter table Locations modify ( house_number varchar2(8) not null);

-- 2.5. Поля “острая” и “вегетарианская” могут принимать только значения 1 или 0.

alter table Products modify ( constraint on_product check ((hot = 0
                                                            or hot = 1)
                                                           and (vegetarian = 0
                                                                or vegetarian = 1)));

-- 2.6. Количество любого продукта в заказе не может быть отрицательным или превышать 100.

alter table Order_Details modify ( constraint on_quantity check ((quantity >= 0)
                                                                 and (quantity <= 100)));

-- 2.7. Срок, к которому надо доставить заказ, не может превышать дату и время заказа, заказ не может быть доставлен  до того как его сделали.

alter table Orders modify ( constraint on_order check ((delivery_date > order_date)
                                                       and (end_date > order_date)));

-- 2.8. Принимаются заказы только на 10 дней вперёд.

alter table Orders modify ( constraint to_order check (((delivery_date - order_date) * 24) <= 10));

-- 3. Модифицировать схему базы данных согласно схеме stud_2. Для каждого сотрудника может быть указано несколько адресов.

create table Contacts ( contact_id int not null,
                        location_id int not null,
                        employee_id int not null,
                        phone varchar(20),
                        apartment int constraint contact_pk primary key (contact_id);

);

-- 4. Добавить информацию о составе продуктов. Один продукт может содержать несколько компонентов, но в составе отдельно продукта каждый компонент  может быть указан только один раз. Требуется описать только состав, точные рецепт с весом не требуется.

create table Products_Ingredients add (
    product_ingredients_id int,
    product_id int,
    ingredient_id int,
    constraint product_ingredients_pk primary key (product_ingredients_id, ingredient_id),
    constraint product_fk foreign key (product_id) references Products(product_id), constraint ingredient_fk
    foreign key (ingredient_id) references Ingredient(ingredient_id) );

create table Ingredient (
    ingredient_id int,
    ingredient_name varchar2(100) not null,
    constraint ingredient_pk primary key (ingredient_id) );
