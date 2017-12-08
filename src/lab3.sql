-- 1. Написать функцию,    возвращающую общую стоимость заказов сделанных заданным заказчиком за выбранный период.    Если заказчик не указан или    не заданы, граница периода выводить сообщение об ошибке. Параметры функции: промежуток времени и номер заказчика.

create or replace function get_total_order_price_by(cid in number, from_date in date, to_date in date)
    return number as total_price number;
begin
    if cid is null then
        dbms_output.put_line('ERROR: customer id is null, exiting');
        return(null);
    end if;

    if from_date is null then
        dbms_output.put_line('ERROR: from_date is null, exiting');
        return(null);
    end if;

    if to_date is null then
        dbms_output.put_line('ERROR: to_date is null, exiting');
        return(null);
    end if;

    select sum(Products.price) into total_price from Orders
    inner join Order_Details on Order_Details.order_id = Orders.order_id
    inner join Products on Products.product_id = Order_Details.product_id
    where customer_id = cid and Order_date > from_date and Order_date < to_date;

    return total_price;
end get_total_order_price_by;
/
select get_total_order_price_by(242, to_date('10-07-2017', 'DD-MM-YYYY'), to_date('10-08-2017', 'DD-MM-YYYY')) from Dual;

-- 2. Написать процедуру выводящую маршрут курьера в указанный день. Формат вывода: ФИО курьера и список адресов доставки в формате: “hh:MM - адрес“ через точку с запятой.

create or replace procedure get_courier_route(cid in number, delivery_day in date)
is
    courier_name Employees.employee_name%TYPE;
    courier_dd Orders.delivery_date%TYPE;
    courier_street Locations.street%TYPE;
    courier_hn Locations.house_number%TYPE;

    cursor Courier_cursor is
           select Employees.employee_name, Orders.delivery_date, Locations.street, Locations.house_number
           from Employees
                inner join Orders
                      on Orders.employee_id = Employees.employee_id
                inner join Locations
                      on Orders.location_id = Locations.location_id
           where Employees.employee_id = cid
             and trunc(delivery_day, 'day') = trunc(Orders.delivery_date, 'day')
           order by Orders.delivery_date;

     id_null exception;
     date_null exception;
begin
    if cid is null then
         raise id_null;
    end if;
    if delivery_day is null then
         raise date_null;
    end if;

    open Courier_cursor;

    fetch Courier_cursor into courier_name, courier_dd, courier_street, courier_hn;

    dbms_output.put_line(courier_name);
    dbms_output.put(to_char(courier_dd, 'hh:MM') || ' - ' || courier_street || ' ' || courier_hn || ';');

    loop
        fetch Courier_cursor into courier_name, courier_dd, courier_street, courier_hn;

        exit when Courier_cursor%NOTFOUND;

        dbms_output.put(to_char(courier_dd, 'hh:MM') || ' - ' || courier_street || ' ' || courier_hn || ';');
    end loop;

    dbms_output.new_line;

    close Courier_cursor;
exception
    when id_null then dbms_output.put_line('id_null is undefined');
    when date_null then dbms_output.put_line ('date_null is undefined');
    when others then dbms_output.put_line ('undefined exception');
end;
/
execute get_courier_route(8, to_date('20-04-2017', 'DD-MM-YYYY'))

-- 3. Написать процедуру формирующую список скидок по итогам заданного месяца (месяц считает от введенной даты). Условия:    скидка 10%    на самую часто заказываемую пиццу , скидка 5% на пиццу, которую заказали на самые большую сумму, 15% на пиццу, которые заказывали с    наибольшим числом напитков. Формат вывода: наименование – новая цена, процент скидки.

create or replace procedure get_sale_products(g_month in date)
is
    cursor Popular_Pizzas is
           select product_name, price from Products
           where product_id in ( select product_id from Order_Details
                                 inner join Orders on Orders.order_id = Order_Details.order_id
                                 where trunc(Orders.order_date, 'month') = trunc(g_month, 'month')
                                 group by product_id
                                 having count(*) = ( select max(count(*)) from Order_Details
                                                     inner join Orders on Orders.order_id = Order_Details.order_id
                                                     where trunc(Orders.order_date, 'month') = trunc(g_month, 'month')
                                                     group by product_id
                                                   ) );

    cursor Most_Expensive_Pizzas is
            with Pizza_Aggr as (
                select Order_Details.order_id, Products.product_id, sum(Products.price * Order_Details.quantity) as total_pizza_price from Order_Details
                            inner join Products on Order_Details.product_id = Products.product_id
                            inner join Orders on Order_Details.order_id = Orders.order_id
                where Products.category_id = 1
                    and trunc(Orders.order_date, 'month') = trunc(g_month, 'month')
                group by Products.product_id, Order_Details.order_id
                order by total_pizza_price
            )
            select distinct product_name, price from Pizza_Aggr
                         inner join Products on Products.product_id = Pizza_Aggr.product_id
            where total_pizza_price = (
                        select max(total_pizza_price) from Pizza_Aggr
            );

     cursor Pizzas_With_Most_Drinks is
            with Drinks_Aggr as (
                select Order_Details.order_id, sum(Order_Details.quantity) as total_drinks from Order_Details
                inner join Products on Products.product_id = Order_Details.product_id
                inner join Orders on Orders.order_id = Order_Details.order_id
                where Products.category_id = 2 and Order_Details.order_id in (
                    select order_id from Order_Details
                    inner join Products on Products.product_id = Order_Details.product_id
                    where Products.category_id = 1 and trunc(Orders.order_date, 'month') = trunc(g_month, 'month')
                ) and trunc(Orders.order_date, 'month') = trunc(g_month, 'month')
                group by Order_Details.order_id
            )
            select distinct q.product_name, q.price from Drinks_Aggr
            inner join ( select Products.product_id, order_id, product_name, price from Products
                          inner join Order_Details on Order_Details.product_id = Products.product_id
                          where Products.category_id = 1
                        ) q on Drinks_Aggr.order_id = q.order_id
            where total_drinks in (select max(total_drinks) from Drinks_Aggr) and Drinks_Aggr.order_id in (select order_id from Drinks_Aggr);

    l_product_name Products.product_name%TYPE;
    l_price Products.price%TYPE;

    g_month_null exception;
begin
    if g_month is null then
         raise g_month_null;
    end if;

    open Popular_Pizzas;
    dbms_output.put_line('popular');
    loop
        fetch Popular_Pizzas into l_product_name, l_price;

        exit when Popular_Pizzas%NOTFOUND;

        dbms_output.put_line(l_product_name || ' - ' || l_price * 0.9 || ', 10%');
    end loop;
    close Popular_Pizzas;

    open Most_Expensive_Pizzas;
    dbms_output.put_line('most expensive');
    loop
        fetch Most_Expensive_Pizzas into l_product_name, l_price;

        exit when Most_Expensive_Pizzas%NOTFOUND;

        dbms_output.put_line(l_product_name || ' - ' || l_price * 0.95 || ', 5%');
    end loop;
    close Most_Expensive_Pizzas;

    open Pizzas_With_Most_Drinks;
    dbms_output.put_line('with most drinks');
    loop
        fetch Pizzas_With_Most_Drinks into l_product_name, l_price;

        exit when Pizzas_With_Most_Drinks%NOTFOUND;

        dbms_output.put_line(l_product_name || ' - ' || l_price * 0.85 || ', 15%');
    end loop;
    close Pizzas_With_Most_Drinks;

exception
    when g_month_null then dbms_output.put_line('g_month is null');
end;
/
execute get_sale_products(to_date('20-04-2017', 'DD-MM-YYYY'));
