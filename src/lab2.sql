-- 1. Создать представления по описанию.

-- 1.1. Данные о сотрудниках: имя, должность, адрес (одной строкой), телефон, срок работы в месяцах.

create or replace view STAFF_VIEW(NAME, POS, ADDRESS, PHONE, EXPERIENCE) as
  select
    EMPLOYEE_NAME,
    (case
     when CHIEF_ID is null
       then 'chief'
     else 'courier'
     end),
    STREET || ' ' || HOUSE_NUMBER,
    PHONE,
    extract('month' from sysdate) - extract('month' from START_DATE)
  from EMPLOYEES;

-- 1.2. Данные о заказах: номер заказа, номер заказчика, номер курьера, срок доставки общая стоимость заказа.

create or replace view ORDER_VIEW(
    ORDER_ID,
    CUSTOMER_ID,
    EMPLOYEE_ID,
    DELIVERY_DATE,
    TOTAL_PRICE )
  as with TOTAL_ORDERS_PRICE
  as ( select
         ORDERS.ORDER_ID,
         sum(PRICE * QUANTITY) as TOTAL_PRICE
       from ORDERS
         left join ORDER_DETAILS on ORDERS.ORDER_ID = ORDER_DETAILS.ORDER_ID
         left join PRODUCTS on PRODUCTS.PRODUCT_ID = ORDER_DETAILS.PRODUCT_ID
       group by ORDERS.ORDER_ID )
  select
    ORDERS.ORDER_ID,
    CUSTOMER_ID,
    EMPLOYEE_ID,
    DELIVERY_DATE,
    TOTAL_PRICE
  from ORDERS
    inner join TOTAL_ORDERS_PRICE on ORDERS.ORDER_ID = TOTAL_ORDERS_PRICE.ORDER_ID;

-- 1.3. Расширенные данные о заказе: номер заказа, имя курьера, имя заказчика, обща стоимость заказа, строк доставки,
-- отметка о том был ли заказа доставлен вовремя.

create view ORDER_VIEW_EXTENDED(
    ORDER_ID,
    EMPLOYEE_NAME,
    CUSTOMER_NAME,
    TOTAL_PRICE,
    DELIVERY_DATE,
    DELIVERED_IN_TIME
) as
  select
    ORDERS.ORDER_ID,
    EMPLOYEE_NAME,
    CUSTOMER_NAME,
    TOTAL_PRICE,
    ORDERS.DELIVERY_DATE,
    (case
     when ORDERS.END_DATE > ORDERS.DELIVERY_DATE
       then 0
     else 1
     end)
  from ORDERS
    inner join ORDER_VIEW on ORDERS.ORDER_ID = ORDER_VIEW.ORDER_ID
    inner join EMPLOYEES on EMPLOYEES.EMPLOYEE_ID = ORDERS.EMPLOYEE_ID
    inner join CUSTOMERS on CUSTOMERS.CUSTOMER_ID = ORDERS.CUSTOMER_ID;

-- 1.4. Представление, позволяющее получить маршрут курьера.

create or replace view COURIER_ROUTE(EMPLOYEE_ID, EMPLOYEE_NAME, STREET, LOCATIONS.HOUSE_NUMBER, DELIVERY_DATE) as
  select
    EMPLOYEE_ID,
    EMPLOYEE_NAME,
    STREET,
    LOCATIONS.HOUSE_NUMBER,
    DELIVERY_DATE
  from EMPLOYEES
    inner join ORDERS on EMPLOYEES.EMPLOYEE_ID = ORDERS.EMPLOYEE_ID
    inner join LOCATIONS on LOCATIONS.LOCATION_ID = ORDERS.LOCATION_ID;

-- 2. Создать ограничения по требованиям.

-- 2.1. Ни один заказ не может включать не известные продукты, доставляться не известным сотрудником, по не известному
-- адресу.

alter table ORDERS
  modify ( EMPLOYEE_ID int not null);
alter table ORDERS
  modify ( LOCATION_ID int not null);
alter table ORDER_DETAILS
  modify ( PRODUCT_ID int not null);

-- 2.2. Начальником может быть только реально существующий сотрудник.

alter table EMPLOYEES
  modify ( CONSTRAINT chief
  foreign key (chief_id) references Employees (employee_id));

-- 2.3. Цена товара не может быть отражательной или нулевой.

alter table PRODUCTS
  modify ( CONSTRAINT on_price check (PRICE > 0));

-- 2.4. Наименования категории, наименования продуктов, имена сотрудников, имена заказчиков, названия районов,
-- названия улиц, номера домов не могут быть пустыми.

alter table PRODUCTS
  modify ( PRODUCT_NAME varchar2(256) not null);
alter table CATEGORIES
  modify ( CATEGORIES_NAME varchar2(256) not null);
alter table EMPLOYEES
  modify ( EMPLOYEE_NAME varchar(256) not null);
alter table CUSTOMERS
  modify ( CUSTOMER_NAME varchar2(256) not null);
alter table LOCATIONS
  modify ( STREET varchar2(256) not null);
alter table AREAS
  modify ( AREAS_NAME varchar2(256) not null);
alter table LOCATIONS
  modify ( HOUSE_NUMBER varchar2(8) not null);

-- 2.5. Поля “острая” и “вегетарианская” могут принимать только значения 1 или 0.

alter table PRODUCTS
  modify ( CONSTRAINT on_product check ((HOT = 0
                                         or HOT = 1)
                                        and (VEGETARIAN = 0
                                             or VEGETARIAN = 1)));

-- 2.6. Количество любого продукта в заказе не может быть отрицательным или превышать 100.

alter table ORDER_DETAILS
  modify ( CONSTRAINT on_quantity check ((QUANTITY >= 0)
                                         and (QUANTITY <= 100)));

-- 2.7. Срок, к которому надо доставить заказ, не может превышать дату и время заказа, заказ не может быть доставлен
-- до того как его сделали.

alter table ORDERS
  modify ( CONSTRAINT on_order check ((DELIVERY_DATE > ORDER_DATE)
                                      and (END_DATE > ORDER_DATE)));

-- 2.8. Принимаются заказы только на 10 дней вперёд.

alter table ORDERS
  modify ( CONSTRAINT to_order check (((DELIVERY_DATE - ORDER_DATE) * 24) <= 10));

-- 3. Модифицировать схему базы данных согласно схеме stud_2. Для каждого сотрудника может быть указано несколько
-- адресов.

create table CONTACTS (
  CONTACT_ID  int not null,
  LOCATION_ID int not null,
  EMPLOYEE_ID int not null,
  PHONE       varchar(20),
  APARTMENT   int constraint CONTACT_PK primary key (contact_id)
);

-- 4. Добавить информацию о составе продуктов. Один продукт может содержать несколько компонентов, но в составе
-- отдельно продукта каждый компонент  может быть указан только один раз. Требуется описать только состав, точные
-- рецепт с весом не требуется.

create table PRODUCTS_INGREDIENTS add (
  product_ingredients_id int,
  product_id int,
  ingredient_id int,
constraint product_ingredients_pk primary key (
  product_ingredients_id, ingredient_id
),
constraint product_fk foreign key (
  product_id
) references Products (product_id
),
constraint ingredient_fk foreign key (
  ingredient_id
) references Ingredient (ingredient_id
)
);

create table INGREDIENT (
  INGREDIENT_ID   int,
  INGREDIENT_NAME varchar2(100) not null,
  constraint INGREDIENT_PK primary key (INGREDIENT_ID)
);
