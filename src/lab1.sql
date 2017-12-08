-- 1. Список домов по улице Дзержинского.

select street,
       house_number
from Locations
where street = 'Дзержинского';

-- 2. Список домов по улице Дзержинского и  Елизаровых в формате: улица, дом.

select street,
       house_number
from Locations
where street = 'Дзержинского'
  or street = 'Елизаровых';

-- 3. Cписок всех острых вегетарианских пицц.

select product_name
from Products
where hot = 1
  and vegetarian = 1
  and category_id = 1;

-- 4. Список всех острых пицц стоимостью до 500.

select product_name
from Products
where Products.category_id = 1
  and hot = 1
  and price < 500;

-- 5. Список всех не острых и не вегетарианских пицц стоимостью до 490.

select product_name
from Products
where Products.category_id = 1
  and hot = 0
  and vegetarian = 0
  and price < 490
  and category_id = 1;

-- 6. Список домов по улице Белинского, исключая проезд Белинского, в формате: улица, дом.

select street,
       house_number
from Locations
where street like 'Белинского';

-- 7. Список полных имен, в которых есть две “е” и нет “c”.

select customer_name
from Customers
where customer_name like '%е%е%'
  and customer_name not like '%с%';

-- 8. Список все улиц, на которых есть дома номер 1, 15, 16.

select distinct street
from Locations
where house_number in ('1',
                       '15',
                       '16');

-- 9. Список все улиц, на которых есть дома номер с 1 по 17.

select distinct street
from Locations
where house_number between '1' and '17';

-- 10. Список все улиц, на которых нет домов номер с 10 по 30, и название которых начинается с “М” или “C”.

select distinct street
from Locations
where house_number not between '10' and '30'
  and (street like 'М%'
       or street like 'С%');

-- 11. Список всех улиц, на которых есть дома не принадлежащие ни одному району.

select distinct street
from Locations
where area_id is null;

-- 12. Список заказов, которые были доставлены  в сентябре 2017-го. Список должен быть отсортирован.

select order_id,
       delivery_date
from Orders
where TRUNC(delivery_date, 'month') = '01.09.2017'
order by 2 asc;

-- 13. Список заказов, которые были доставлены  за последние 3 месяца. Список должен быть отсортирован.

select order_id,
       delivery_date
from Orders
where delivery_date > add_months(current_date, -3)
order by 2 asc;

-- 14. Список заказов, которые были доставлены с 1 по 10 любого месяца. Список должен быть отсортирован.

select order_id,
       delivery_date
from Orders
where extract(day
              from delivery_date) between 1 and 10
order by delivery_date asc;

-- 15. Список всех продуктов с их типами.

select product_name,
       categories_name
from Products
inner join Categories on Products.category_id = Categories.category_id;

-- 16. Все дома в Кировском районе.

select street,
       house_number,
       areas_name
from Locations
inner join Areas on Locations.area_id = Areas.area_id
where areas_name = 'Кировский';

-- 17. Все дома в Кировском районе или не принадлежащие ни одному району.

select areas_name,
       street,
       house_number
from Locations
left join Areas on Locations.area_id = Areas.area_id
where areas_name = 'Кировский'
  or locations.area_id is null;

-- 18. Все дома в Кировском районе или не принадлежащие ни одному району. Для домов, не принадлежащих ни одному району, в советующем столбце должно стоять  ‘нет’.

select a.area_id,
       l.area_id,
       l.street,
       l.house_number,
       nvl(a.areas_name, 'нет') as areas_name
from Areas a
right join Locations l on l.area_id = a.area_id
where a.areas_name = 'Кировский'
  or l.area_id is null;

-- 19. Список имён все сотрудников и с указанием имени начальника. Для начальников в соотв. Столбце выводить – ‘шеф’

select e.employee_name,
       NVL(c.employee_name, 'шеф') as chief_name
from Employees e
left join Employees c on e.chief_id = c.employee_id;

-- 20. Список всех заказов доставленных в советский район.

select orders.order_id,
       areas.areas_name
from Orders
inner join Locations on Locations.location_id = Orders.location_id
inner join Areas on Areas.area_id = Locations.area_id
where Areas.areas_name = 'Советский';

-- 21. Список всех пицц, которые были доставлены в этом месяце.

select distinct Products.product_name
from Products
inner join Categories on Categories.category_id = Products.category_id
inner join Order_Details on Order_Details.product_id = Products.product_id
inner join Orders on Orders.order_id = Order_Details.order_id
where Categories.categories_name = 'Пицца'
  and trunc(Orders.order_date, 'month') = trunc(current_date, 'month');

-- 22. Список всех заказчиков, делавших заказ в октябрьском районе по улице Алтайской.

select Customers.customer_name
from Customers
inner join Orders on Orders.customer_id = Customers.customer_id
inner join Locations on Locations.location_id = Orders.location_id
inner join Areas on Areas.area_id = Locations.area_id
where Locations.street like 'Алтайская'
  and Areas.areas_name like 'Октябрьский';

-- 23. Список всех пицц, которые были доставлены под руководствам Козлова (или им самим). В списке также должны отображаться имя курьера и район (‘нет’ – если район не известен).

select distinct product_name,
                e.employee_name,
                nvl(Areas.areas_name, 'нет') as area
from Products
inner join Order_Details on Order_Details.product_id = Products.product_id
inner join Orders on Orders.order_id = Order_Details.order_id
inner join Categories on Products.category_id = Categories.category_id
inner join Employees e on e.employee_id = Orders.employee_id
left join Employees chief_e on chief_e.employee_id = e.chief_id
inner join Locations on Orders.location_id = Locations.location_id
inner join Areas on Locations.area_id = Areas.area_id
where Categories.categories_name = 'Пицца'
  and (chief_e.employee_name like '%Козлов'
       or e.employee_name like '%Козлов');

-- 24. Список продуктов с типом, которые заказывали вмести с острыми или вегетарианскими пиццами в этом месяце.

select distinct p.product_name,
                Categories.categories_name
from Order_Details
left join Products pz on (pz.hot = 1
                          or pz.vegetarian = 1)
and pz.product_id = Order_Details.product_id
right join Products p on p.product_id = Order_Details.product_id
inner join Orders on Orders.order_id = Order_Details.order_id
inner join Categories on Categories.category_id = p.category_id
where pz.product_id is null
  and trunc(Orders.order_date, 'month') = trunc(current_date, 'month');

-- 25. Найти среднюю стоимость пиццы с точность до второго знака.

select round(avg(price), 2) as avg_price
from Products
where category_id = 1;

-- 26. Для каждого заказа посчитать общее количество товаров в заказе, и количество позиций в заказе. Столбцы: номер заказа, общее количество, количество позиций.

select Order_Details.order_id,
       count(Order_Details.product_id),
       sum(Order_Details.quantity)
from Orders
left join Order_Details on Orders.order_id = Order_Details.order_id
group by Order_Details.order_id;

-- 27. Для каждого заказа посчитать сумму заказа.

select Orders.order_id,
       sum(Products.price * Order_Details.quantity) as total_price
from Orders
left join Order_Details on Orders.order_id = Order_Details.order_id
inner join Products on Products.product_id = Order_Details.product_id
group by Orders.order_id;

-- 28. Для каждой пиццы найти общую сумму заказов.

select product_name,
       sum(price * quantity) as total_price
from Order_Details
inner join Products on Products.product_id = Order_Details.product_id
inner join Categories on Categories.category_id = Products.category_id
where Categories.categories_name = 'Пицца'
group by product_name;

-- 29. Составьте отчёт по суммам заказов за последние три  месяца

select Orders.order_id,
       sum(price * quantity) as total_price
from Orders
inner join Order_Details on Orders.order_id = Order_Details.order_id
inner join Products on Products.product_id = Order_Details.product_id
where Orders.order_date > add_months(current_date, -3)
group by Orders.order_id;

-- 30. Найти всех заказчиков, которые сделали заказ одного  товара на сумму не менее 3000. Отчёт должен содержать имя заказчика, номер заказа и стоимость.

select Orders.order_id,
       Customers.customer_name,
       sum(price * quantity) as total_price
from Orders
left join Order_Details on Orders.order_id = Order_Details.order_id
left join Customers on Customers.customer_id = Orders.customer_id
inner join Products on Products.product_id = Order_Details.product_id
where (price * quantity) > 3000
group by Orders.order_id,
         Customers.customer_name
having count(*) = 1;

-- 31. Найти всех заказчиков, которые делали заказы во всех районах.

select customer_name
from Customers
inner join Orders on Orders.customer_id = Customers.customer_id
inner join Locations on Locations.location_id = Orders.location_id
inner join Areas on Areas.area_id = Locations.area_id
group by Customers.customer_name
having count(distinct Areas.area_id) =
  (select count(*)
   from Areas);


left join Order_Details on Order_Details.order_id = Orders.order_id
left join Products on Products.product_id = Order_Details.product_id
group by Orders.order_id
having sum(hot) = 0;

-- 34. Найти сумму всех заказов сделанных по адресам, не относящимся ни к одному району. Использовать вариант решения с подзапросом.

select sum(Products.price * Order_Details.quantity) as total_price
from Orders
inner join Order_Details on Order_Details.order_id = Orders.order_id
inner join Products on Order_Details.product_id = Products.product_id
where Orders.location_id in
    ( select Locations.location_id
     from Locations
     where Locations.area_id is null );

-- 35. Вывести номера и имена сотрудников ни разу не задержавших доставку более чем на полтора часа. Использовать вариант решения без групповых операций и DISTINCT

select employee_id,
       employee_name
from Employees
where employee_id in
    ( select Employees.employee_id as employee_id
     from Employees
     left join Orders on Employees.employee_id = Orders.employee_id
     where (Orders.end_date + 1/24 * 1.5) > Orders.delivery_date );

-- 36. Найти курьера выполнившего наибольшее число заказов.

select *
from
  ( select Employees.employee_id,
           Employees.employee_name,
           count(Orders.order_id) as number_of_orders
   from Orders
   inner join Employees on Employees.employee_id = Orders.employee_id
   group by Employees.employee_id,
            Employees.employee_name
   order by number_of_orders desc)
where ROWNUM <= 1;

-- 37. Найти курьера с наименьшим процентом заказов выполненных с задержкой.

select *
from
  ( select Employees.employee_id,
           Employees.employee_name,
           (bad_orders / total_orders * 100) as orders_rate
   from Orders
   inner join Employees on Employees.employee_id = Orders.employee_id
   inner join
     ( select employee_id,
              count(order_id) as bad_orders
      from Orders
      where end_date > delivery_date
      group by employee_id ) Bad_orders on Employees.employee_id = Bad_orders.employee_id
   inner join
     ( select Employees.employee_id,
              count(Orders.order_id) as total_orders
      from Employees
      inner join Orders on Orders.employee_id = Employees.employee_id
      group by Employees.employee_id ) TotalOrders on TotalOrders.employee_id = Employees.employee_id
   group by Employees.employee_id,
            Employees.employee_name,
            total_orders,
            bad_orders
   order by orders_rate asc)
where ROWNUM <= 1;

-- 38. Для каждого курьера найти число заказов, доставленных с задержкой, как процент от числа выполненных им заказов и  процент от общего числа заказов. Отчёт должен содержать имя курьера, количество заказов, количество и процент выполненных без задержки заказов

select Employees.employee_id,
       Employees.employee_name,
       (bad_orders / total_orders * 100) as orders_rate,
       (total_orders /
          (select count(*)
           from Orders) * 100) as total_orders_rate --from Orders

inner join Employees on Employees.employee_id = Orders.employee_id
inner join
  ( select employee_id,
           count(order_id) as bad_orders
   from Orders
   where end_date > delivery_date
   group by employee_id ) Bad_orders on Employees.employee_id = Bad_orders.employee_id
inner join
  ( select Employees.employee_id,
           count(Orders.order_id) as total_orders
   from Employees
   inner join Orders on Orders.employee_id = Employees.employee_id
   group by Employees.employee_id ) TotalOrders on TotalOrders.employee_id = Employees.employee_id
group by Employees.employee_id,
         Employees.employee_name,
         total_orders,
         bad_orders
order by orders_rate asc;

-- 39. Для клиента найти дату и номер самого дорогого заказа.

select Orders.order_id,
       Orders.order_date
from Customers
inner join Orders on Customers.customer_id = Orders.customer_id
inner join
  ( select o.order_id as order_id,
           sum(price * quantity) as total_price
   from Orders o
   left join order_details od on o.order_id=od.order_id
   left join products p on p.product_id=od.product_id
   group by o.order_id ) o on o.order_id = Orders.order_id
inner join
  ( select c.customer_id,
           max(total_price) as max_total_price
   from Customers c
   inner join Orders o on o.customer_id = c.customer_id
   inner join
     ( select sub_o.order_id,
              sum(price * quantity) as total_price
      from orders sub_o
      left join order_details od on sub_o.order_id = od.order_id
      left join products p on p.product_id = od.product_id
      group by sub_o.order_id ) sub_o on sub_o.order_id = o.order_id
   group by c.customer_id ) q on Customers.customer_id = q.customer_id
where total_price = max_total_price
order by Customers.customer_id asc;

-- 40. Для каждого старшего группы найти стоимость всех заказов, выполненных им самим или его подчинёнными.

select chief_id,
       chief_name,
       sum(total_order_price)
from
  ( select e.employee_id as employee_id,
           e.chief_id as chief_id,
           c.employee_name as chief_name,
           total_order_price
   from Employees e
   left join Employees c on e.chief_id = c.employee_id
   inner join Orders on Orders.employee_id = c.employee_id
   inner join
     ( select o.employee_id as employee_id,
              sum(price * quantity) as total_order_price
      from Order_Details
      inner join Orders o on o.order_id = Order_Details.order_id
      inner join Products on Products.product_id = Order_Details.product_id
      group by o.employee_id ) ord on ord.employee_id = e.employee_id )
group by chief_id,
         chief_name;
