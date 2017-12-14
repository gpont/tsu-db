-- 1. Список домов по улице Дзержинского.

select
  STREET,
  HOUSE_NUMBER
from LOCATIONS
where STREET = 'Дзержинского';

-- 2. Список домов по улице Дзержинского и  Елизаровых в формате: улица, дом.

select
  STREET,
  HOUSE_NUMBER
from LOCATIONS
where STREET = 'Дзержинского'
      or STREET = 'Елизаровых';

-- 3. Cписок всех острых вегетарианских пицц.

select PRODUCT_NAME
from PRODUCTS
where HOT = 1
      and VEGETARIAN = 1
      and CATEGORY_ID = 1;

-- 4. Список всех острых пицц стоимостью до 500.

select PRODUCT_NAME
from PRODUCTS
where PRODUCTS.CATEGORY_ID = 1
      and HOT = 1
      and PRICE < 500;

-- 5. Список всех не острых и не вегетарианских пицц стоимостью до 490.

select PRODUCT_NAME
from PRODUCTS
where PRODUCTS.CATEGORY_ID = 1
      and HOT = 0
      and VEGETARIAN = 0
      and PRICE < 490
      and CATEGORY_ID = 1;

-- 6. Список домов по улице Белинского, исключая проезд Белинского, в формате: улица, дом.

select
  STREET,
  HOUSE_NUMBER
from LOCATIONS
where STREET like 'Белинского';

-- 7. Список полных имен, в которых есть две “е” и нет “c”.

select CUSTOMER_NAME
from CUSTOMERS
where CUSTOMER_NAME like '%е%е%'
      and CUSTOMER_NAME not like '%с%';

-- 8. Список все улиц, на которых есть дома номер 1, 15, 16.

select distinct STREET
from LOCATIONS
where HOUSE_NUMBER in ('1',
                       '15',
                       '16');

-- 9. Список все улиц, на которых есть дома номер с 1 по 17.

select distinct STREET
from LOCATIONS
where HOUSE_NUMBER between '1' and '17';

-- 10. Список все улиц, на которых нет домов номер с 10 по 30, и название которых начинается с “М” или “C”.

select distinct STREET
from LOCATIONS
where HOUSE_NUMBER not between '10' and '30'
      and (STREET like 'М%'
           or STREET like 'С%');

-- 11. Список всех улиц, на которых есть дома не принадлежащие ни одному району.

select distinct STREET
from LOCATIONS
where AREA_ID is null;

-- 12. Список заказов, которые были доставлены  в сентябре 2017-го. Список должен быть отсортирован.

select
  ORDER_ID,
  DELIVERY_DATE
from ORDERS
where TRUNC(DELIVERY_DATE, 'month') = '01.09.2017'
order by 2 asc;

-- 13. Список заказов, которые были доставлены  за последние 3 месяца. Список должен быть отсортирован.

select
  ORDER_ID,
  DELIVERY_DATE
from ORDERS
where DELIVERY_DATE > add_months(current_date, -3)
order by 2 asc;

-- 14. Список заказов, которые были доставлены с 1 по 10 любого месяца. Список должен быть отсортирован.

select
  ORDER_ID,
  DELIVERY_DATE
from ORDERS
where extract(day
              from DELIVERY_DATE) between 1 and 10
order by DELIVERY_DATE asc;

-- 15. Список всех продуктов с их типами.

select
  PRODUCT_NAME,
  CATEGORIES_NAME
from PRODUCTS
  inner join CATEGORIES on PRODUCTS.CATEGORY_ID = CATEGORIES.CATEGORY_ID;

-- 16. Все дома в Кировском районе.

select
  STREET,
  HOUSE_NUMBER,
  AREAS_NAME
from LOCATIONS
  inner join AREAS on LOCATIONS.AREA_ID = AREAS.AREA_ID
where AREAS_NAME = 'Кировский';

-- 17. Все дома в Кировском районе или не принадлежащие ни одному району.

select
  AREAS_NAME,
  STREET,
  HOUSE_NUMBER
from LOCATIONS
  left join AREAS on LOCATIONS.AREA_ID = AREAS.AREA_ID
where AREAS_NAME = 'Кировский'
      or LOCATIONS.AREA_ID is null;

-- 18. Все дома в Кировском районе или не принадлежащие ни одному району. Для домов, не принадлежащих ни одному району,
-- в советующем столбце должно стоять  ‘нет’.

select
  A.AREA_ID,
  L.AREA_ID,
  L.STREET,
  L.HOUSE_NUMBER,
  nvl(A.AREAS_NAME, 'нет') as AREAS_NAME
from AREAS A
  right join LOCATIONS L on L.AREA_ID = A.AREA_ID
where A.AREAS_NAME = 'Кировский'
      or L.AREA_ID is null;

-- 19. Список имён все сотрудников и с указанием имени начальника. Для начальников в соотв. Столбце выводить – ‘шеф’

select
  E.EMPLOYEE_NAME,
  NVL(C.EMPLOYEE_NAME, 'шеф') as CHIEF_NAME
from EMPLOYEES E
  left join EMPLOYEES C on E.CHIEF_ID = C.EMPLOYEE_ID;

-- 20. Список всех заказов доставленных в советский район.

select
  ORDERS.ORDER_ID,
  AREAS.AREAS_NAME
from ORDERS
  inner join LOCATIONS on LOCATIONS.LOCATION_ID = ORDERS.LOCATION_ID
  inner join AREAS on AREAS.AREA_ID = LOCATIONS.AREA_ID
where AREAS.AREAS_NAME = 'Советский';

-- 21. Список всех пицц, которые были доставлены в этом месяце.

select distinct PRODUCTS.PRODUCT_NAME
from PRODUCTS
  inner join CATEGORIES on CATEGORIES.CATEGORY_ID = PRODUCTS.CATEGORY_ID
  inner join ORDER_DETAILS on ORDER_DETAILS.PRODUCT_ID = PRODUCTS.PRODUCT_ID
  inner join ORDERS on ORDERS.ORDER_ID = ORDER_DETAILS.ORDER_ID
where CATEGORIES.CATEGORIES_NAME = 'Пицца'
      and trunc(ORDERS.ORDER_DATE, 'month') = trunc(current_date, 'month');

-- 22. Список всех заказчиков, делавших заказ в октябрьском районе по улице Алтайской.

select CUSTOMERS.CUSTOMER_NAME
from CUSTOMERS
  inner join ORDERS on ORDERS.CUSTOMER_ID = CUSTOMERS.CUSTOMER_ID
  inner join LOCATIONS on LOCATIONS.LOCATION_ID = ORDERS.LOCATION_ID
  inner join AREAS on AREAS.AREA_ID = LOCATIONS.AREA_ID
where LOCATIONS.STREET like 'Алтайская'
      and AREAS.AREAS_NAME like 'Октябрьский';

-- 23. Список всех пицц, которые были доставлены под руководствам Козлова (или им самим). В списке также должны
-- отображаться имя курьера и район (‘нет’ – если район не известен).

select distinct
  PRODUCT_NAME,
  E.EMPLOYEE_NAME,
  nvl(AREAS.AREAS_NAME, 'нет') as AREA
from PRODUCTS
  inner join ORDER_DETAILS on ORDER_DETAILS.PRODUCT_ID = PRODUCTS.PRODUCT_ID
  inner join ORDERS on ORDERS.ORDER_ID = ORDER_DETAILS.ORDER_ID
  inner join CATEGORIES on PRODUCTS.CATEGORY_ID = CATEGORIES.CATEGORY_ID
  inner join EMPLOYEES E on E.EMPLOYEE_ID = ORDERS.EMPLOYEE_ID
  left join EMPLOYEES CHIEF_E on CHIEF_E.EMPLOYEE_ID = E.CHIEF_ID
  inner join LOCATIONS on ORDERS.LOCATION_ID = LOCATIONS.LOCATION_ID
  inner join AREAS on LOCATIONS.AREA_ID = AREAS.AREA_ID
where CATEGORIES.CATEGORIES_NAME = 'Пицца'
      and (CHIEF_E.EMPLOYEE_NAME like '%Козлов'
           or E.EMPLOYEE_NAME like '%Козлов');

-- 24. Список продуктов с типом, которые заказывали вмести с острыми или вегетарианскими пиццами в этом месяце.

select distinct
  P.PRODUCT_NAME,
  CATEGORIES.CATEGORIES_NAME
from ORDER_DETAILS
  left join PRODUCTS PZ on (PZ.HOT = 1
                            or PZ.VEGETARIAN = 1)
                           and PZ.PRODUCT_ID = ORDER_DETAILS.PRODUCT_ID
  right join PRODUCTS P on P.PRODUCT_ID = ORDER_DETAILS.PRODUCT_ID
  inner join ORDERS on ORDERS.ORDER_ID = ORDER_DETAILS.ORDER_ID
  inner join CATEGORIES on CATEGORIES.CATEGORY_ID = P.CATEGORY_ID
where PZ.PRODUCT_ID is null
      and trunc(ORDERS.ORDER_DATE, 'month') = trunc(current_date, 'month');

-- 25. Найти среднюю стоимость пиццы с точность до второго знака.

select round(avg(PRICE), 2) as AVG_PRICE
from PRODUCTS
where CATEGORY_ID = 1;

-- 26. Для каждого заказа посчитать общее количество товаров в заказе, и количество позиций в заказе. Столбцы: номер
-- заказа, общее количество, количество позиций.

select
  ORDER_DETAILS.ORDER_ID,
  count(ORDER_DETAILS.PRODUCT_ID),
  sum(ORDER_DETAILS.QUANTITY)
from ORDERS
  left join ORDER_DETAILS on ORDERS.ORDER_ID = ORDER_DETAILS.ORDER_ID
group by ORDER_DETAILS.ORDER_ID;

-- 27. Для каждого заказа посчитать сумму заказа.

select
  ORDERS.ORDER_ID,
  sum(PRODUCTS.PRICE * ORDER_DETAILS.QUANTITY) as TOTAL_PRICE
from ORDERS
  left join ORDER_DETAILS on ORDERS.ORDER_ID = ORDER_DETAILS.ORDER_ID
  inner join PRODUCTS on PRODUCTS.PRODUCT_ID = ORDER_DETAILS.PRODUCT_ID
group by ORDERS.ORDER_ID;

-- 28. Для каждой пиццы найти общую сумму заказов.

select
  PRODUCT_NAME,
  sum(PRICE * QUANTITY) as TOTAL_PRICE
from ORDER_DETAILS
  inner join PRODUCTS on PRODUCTS.PRODUCT_ID = ORDER_DETAILS.PRODUCT_ID
  inner join CATEGORIES on CATEGORIES.CATEGORY_ID = PRODUCTS.CATEGORY_ID
where CATEGORIES.CATEGORIES_NAME = 'Пицца'
group by PRODUCT_NAME;

-- 29. Составьте отчёт по суммам заказов за последние три  месяца

select
  ORDERS.ORDER_ID,
  sum(PRICE * QUANTITY) as TOTAL_PRICE
from ORDERS
  inner join ORDER_DETAILS on ORDERS.ORDER_ID = ORDER_DETAILS.ORDER_ID
  inner join PRODUCTS on PRODUCTS.PRODUCT_ID = ORDER_DETAILS.PRODUCT_ID
where ORDERS.ORDER_DATE > add_months(current_date, -3)
group by ORDERS.ORDER_ID;

-- 30. Найти всех заказчиков, которые сделали заказ одного товара на сумму не менее 3000. Отчёт должен содержать имя
-- заказчика, номер заказа и стоимость.

select
  ORDERS.ORDER_ID,
  CUSTOMERS.CUSTOMER_NAME,
  sum(PRICE * QUANTITY) as TOTAL_PRICE
from ORDERS
  left join ORDER_DETAILS on ORDERS.ORDER_ID = ORDER_DETAILS.ORDER_ID
  left join CUSTOMERS on CUSTOMERS.CUSTOMER_ID = ORDERS.CUSTOMER_ID
  inner join PRODUCTS on PRODUCTS.PRODUCT_ID = ORDER_DETAILS.PRODUCT_ID
where (PRICE * QUANTITY) > 3000
group by ORDERS.ORDER_ID,
  CUSTOMERS.CUSTOMER_NAME
having count(*) = 1;

-- 31. Найти всех заказчиков, которые делали заказы во всех районах.

select CUSTOMER_NAME
from CUSTOMERS
  inner join ORDERS on ORDERS.CUSTOMER_ID = CUSTOMERS.CUSTOMER_ID
  inner join LOCATIONS on LOCATIONS.LOCATION_ID = ORDERS.LOCATION_ID
  inner join AREAS on AREAS.AREA_ID = LOCATIONS.AREA_ID
group by CUSTOMERS.CUSTOMER_NAME
having count(distinct AREAS.AREA_ID) =
       (
         select count(*)
         from AREAS);

-- 32. Вывести все “чеки” (номер заказа, курьер, заказчик, стоимость заказа) для всех заказов, сделанных в кировском
-- районе и содержащих хотя бы 1 острую пиццу.

select
  ORDERS.ORDER_ID,
  EMPLOYEE_NAME,
  CUSTOMER_NAME,
  sum(PRODUCTS.PRICE * ORDER_DETAILS.QUANTITY) as TOTAL_PRICE
from ORDERS
  inner join ORDER_DETAILS on ORDERS.ORDER_ID = ORDER_DETAILS.ORDER_ID
  inner join PRODUCTS on ORDER_DETAILS.PRODUCT_ID = PRODUCTS.PRODUCT_ID and PRODUCTS.HOT = 1
  inner join CATEGORIES on CATEGORIES.CATEGORY_ID = PRODUCTS.CATEGORY_ID
  inner join EMPLOYEES on EMPLOYEES.EMPLOYEE_ID = ORDERS.EMPLOYEE_ID
  inner join CUSTOMERS on CUSTOMERS.CUSTOMER_ID = ORDERS.CUSTOMER_ID
  inner join LOCATIONS on LOCATIONS.LOCATION_ID = ORDERS.LOCATION_ID
  inner join AREAS on AREAS.AREA_ID = LOCATIONS.AREA_ID
where CATEGORIES.CATEGORIES_NAME = 'Пицца' and AREAS_NAME = 'Кировский'
group by ORDERS.ORDER_ID, EMPLOYEES.EMPLOYEE_NAME, CUSTOMERS.CUSTOMER_NAME
having sum(HOT) > 0;

-- ✓ 33. Для каждого заказа, в котором есть хотя бы 1 острая пицца  посчитать стоимость напитков.
select
  ORDERS.ORDER_ID,
  sum(
      case when CATEGORY_ID = 2
        then
          PRICE * QUANTITY
      else
        0
      end
  ) as TOTAL_DRINKS_PRICE
from ORDERS
  left join ORDER_DETAILS on ORDER_DETAILS.ORDER_ID = ORDERS.ORDER_ID
  left join PRODUCTS on PRODUCTS.PRODUCT_ID = ORDER_DETAILS.PRODUCT_ID
group by ORDERS.ORDER_ID
having sum(HOT) = 0;

-- 34. Найти сумму всех заказов сделанных по адресам, не относящимся ни к одному району. Использовать вариант решения с
-- подзапросом.

select sum(PRODUCTS.PRICE * ORDER_DETAILS.QUANTITY) as TOTAL_PRICE
from ORDERS
  inner join ORDER_DETAILS on ORDER_DETAILS.ORDER_ID = ORDERS.ORDER_ID
  inner join PRODUCTS on ORDER_DETAILS.PRODUCT_ID = PRODUCTS.PRODUCT_ID
where ORDERS.LOCATION_ID in
      (
        select LOCATIONS.LOCATION_ID
        from LOCATIONS
        where LOCATIONS.AREA_ID is null);

-- 35. Вывести номера и имена сотрудников ни разу не задержавших доставку более чем на полтора часа. Использовать
-- вариант решения без групповых операций и DISTINCT

select
  EMPLOYEE_ID,
  EMPLOYEE_NAME
from EMPLOYEES
where EMPLOYEE_ID in
      (
        select EMPLOYEES.EMPLOYEE_ID as EMPLOYEE_ID
        from EMPLOYEES
          left join ORDERS on EMPLOYEES.EMPLOYEE_ID = ORDERS.EMPLOYEE_ID
        where (ORDERS.END_DATE + 1 / 24 * 1.5) > ORDERS.DELIVERY_DATE);

-- 36. Найти курьера выполнившего наибольшее число заказов.

select *
from
  (
    select
      EMPLOYEES.EMPLOYEE_ID,
      EMPLOYEES.EMPLOYEE_NAME,
      count(ORDERS.ORDER_ID) as NUMBER_OF_ORDERS
    from ORDERS
      inner join EMPLOYEES on EMPLOYEES.EMPLOYEE_ID = ORDERS.EMPLOYEE_ID
    group by EMPLOYEES.EMPLOYEE_ID,
      EMPLOYEES.EMPLOYEE_NAME
    order by NUMBER_OF_ORDERS desc)
where ROWNUM <= 1;

-- 37. Найти курьера с наименьшим процентом заказов выполненных с задержкой.

select *
from
  (
    select
      EMPLOYEES.EMPLOYEE_ID,
      EMPLOYEES.EMPLOYEE_NAME,
      (BAD_ORDERS / TOTAL_ORDERS * 100) as ORDERS_RATE
    from ORDERS
      inner join EMPLOYEES on EMPLOYEES.EMPLOYEE_ID = ORDERS.EMPLOYEE_ID
      inner join
      (
        select
          EMPLOYEE_ID,
          count(ORDER_ID) as BAD_ORDERS
        from ORDERS
        where END_DATE > DELIVERY_DATE
        group by EMPLOYEE_ID) BAD_ORDERS on EMPLOYEES.EMPLOYEE_ID = BAD_ORDERS.EMPLOYEE_ID
      inner join
      (
        select
          EMPLOYEES.EMPLOYEE_ID,
          count(ORDERS.ORDER_ID) as TOTAL_ORDERS
        from EMPLOYEES
          inner join ORDERS on ORDERS.EMPLOYEE_ID = EMPLOYEES.EMPLOYEE_ID
        group by EMPLOYEES.EMPLOYEE_ID) TOTALORDERS on TOTALORDERS.EMPLOYEE_ID = EMPLOYEES.EMPLOYEE_ID
    group by EMPLOYEES.EMPLOYEE_ID,
      EMPLOYEES.EMPLOYEE_NAME,
      TOTAL_ORDERS,
      BAD_ORDERS
    order by ORDERS_RATE asc)
where ROWNUM <= 1;

-- 38. Для каждого курьера найти число заказов, доставленных с задержкой, как процент от числа выполненных им заказов и
-- процент от общего числа заказов. Отчёт должен содержать имя курьера, количество заказов, количество и процент
-- выполненных без задержки заказов

select
  EMPLOYEES.EMPLOYEE_ID,
  EMPLOYEES.EMPLOYEE_NAME,
  (BAD_ORDERS / TOTAL_ORDERS * 100) as ORDERS_RATE,
  (TOTAL_ORDERS / (
    select count(*)
    from ORDERS) * 100)             as TOTAL_ORDERS_RATE -- from Orders
from ORDERS
  inner join EMPLOYEES on EMPLOYEES.EMPLOYEE_ID = ORDERS.EMPLOYEE_ID
  inner join
  (
    select
      EMPLOYEE_ID,
      count(ORDER_ID) as BAD_ORDERS
    from EMPLOYEES
    where END_DATE > DELIVERY_DATE
    group by EMPLOYEE_ID) BAD_ORDERS on EMPLOYEES.EMPLOYEE_ID = BAD_ORDERS.EMPLOYEE_ID
  inner join
  (
    select
      EMPLOYEES.EMPLOYEE_ID,
      count(ORDERS.ORDER_ID) as TOTAL_ORDERS
    from EMPLOYEES
      inner join ORDERS on ORDERS.EMPLOYEE_ID = EMPLOYEES.EMPLOYEE_ID
    group by EMPLOYEES.EMPLOYEE_ID) TOTALORDERS on TOTALORDERS.EMPLOYEE_ID = EMPLOYEES.EMPLOYEE_ID
group by EMPLOYEES.EMPLOYEE_ID,
  EMPLOYEES.EMPLOYEE_NAME,
  TOTAL_ORDERS,
  BAD_ORDERS
order by ORDERS_RATE asc;

-- 39. Для клиента найти дату и номер самого дорогого заказа.

select
  ORDERS.ORDER_ID,
  ORDERS.ORDER_DATE
from CUSTOMERS
  inner join ORDERS on CUSTOMERS.CUSTOMER_ID = ORDERS.CUSTOMER_ID
  inner join
  (
    select
      O.ORDER_ID            as ORDER_ID,
      sum(PRICE * QUANTITY) as TOTAL_PRICE
    from ORDERS O
      left join ORDER_DETAILS OD on O.ORDER_ID = OD.ORDER_ID
      left join PRODUCTS P on P.PRODUCT_ID = OD.PRODUCT_ID
    group by O.ORDER_ID) O on O.ORDER_ID = ORDERS.ORDER_ID
  inner join
  (
    select
      C.CUSTOMER_ID,
      max(TOTAL_PRICE) as MAX_TOTAL_PRICE
    from CUSTOMERS C
      inner join ORDERS O on O.CUSTOMER_ID = C.CUSTOMER_ID
      inner join
      (
        select
          SUB_O.ORDER_ID,
          sum(PRICE * QUANTITY) as TOTAL_PRICE
        from ORDERS SUB_O
          left join ORDER_DETAILS OD on SUB_O.ORDER_ID = OD.ORDER_ID
          left join PRODUCTS P on P.PRODUCT_ID = OD.PRODUCT_ID
        group by SUB_O.ORDER_ID) SUB_O on SUB_O.ORDER_ID = O.ORDER_ID
    group by C.CUSTOMER_ID) Q on CUSTOMERS.CUSTOMER_ID = Q.CUSTOMER_ID
where TOTAL_PRICE = MAX_TOTAL_PRICE
order by CUSTOMERS.CUSTOMER_ID asc;

-- 40. Для каждого старшего группы найти стоимость всех заказов, выполненных им самим или его подчинёнными.

select
  CHIEF_ID,
  CHIEF_NAME,
  sum(TOTAL_ORDER_PRICE)
from
  (
    select
      E.EMPLOYEE_ID   as EMPLOYEE_ID,
      E.CHIEF_ID      as CHIEF_ID,
      C.EMPLOYEE_NAME as CHIEF_NAME,
      TOTAL_ORDER_PRICE
    from EMPLOYEES E
      left join EMPLOYEES C on E.CHIEF_ID = C.EMPLOYEE_ID
      inner join ORDERS on ORDERS.EMPLOYEE_ID = C.EMPLOYEE_ID
      inner join
      (
        select
          O.EMPLOYEE_ID         as EMPLOYEE_ID,
          sum(PRICE * QUANTITY) as TOTAL_ORDER_PRICE
        from ORDER_DETAILS
          inner join ORDERS O on O.ORDER_ID = ORDER_DETAILS.ORDER_ID
          inner join PRODUCTS on PRODUCTS.PRODUCT_ID = ORDER_DETAILS.PRODUCT_ID
        group by O.EMPLOYEE_ID) ORD on ORD.EMPLOYEE_ID = E.EMPLOYEE_ID)
group by CHIEF_ID,
  CHIEF_NAME;
