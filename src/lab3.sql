-- 1. Написать функцию, возвращающую общую стоимость заказов сделанных заданным заказчиком за выбранный период. Если
-- заказчик не указан или не заданы, граница периода выводить сообщение об ошибке. Параметры функции: промежуток
-- времени и номер заказчика.

create or replace function get_total_order_price_by(CID in number, FROM_DATE in date, TO_DATE in date)
  return number as TOTAL_PRICE number;
  begin
    if CID is null then
      RAISE_APPLICATION_ERROR(
          -20002,
          'ERROR: customer id is null'
      );
    end if;

    if FROM_DATE is null then
      RAISE_APPLICATION_ERROR(
          -20003,
          'ERROR: from_date is null'
      );
    end if;

    if TO_DATE is null then
      RAISE_APPLICATION_ERROR(
          -20004,
          'ERROR: to_date is null'
      );
    end if;

    select sum(PRODUCTS.PRICE)
    into TOTAL_PRICE
    from ORDERS
      inner join ORDER_DETAILS on ORDER_DETAILS.ORDER_ID = ORDERS.ORDER_ID
      inner join PRODUCTS on PRODUCTS.PRODUCT_ID = ORDER_DETAILS.PRODUCT_ID
    where CUSTOMER_ID = CID and ORDER_DATE > FROM_DATE and ORDER_DATE < TO_DATE;

    return TOTAL_PRICE;
  end GET_TOTAL_ORDER_PRICE_BY;
/
select get_total_order_price_by(242, to_date('10-07-2017', 'DD-MM-YYYY'), to_date('10-08-2017', 'DD-MM-YYYY'))
from DUAL;

-- 2. Написать процедуру выводящую маршрут курьера в указанный день. Формат вывода: ФИО курьера и список адресов
-- доставки в формате: “hh:MM - адрес“ через точку с запятой.

create or replace procedure GET_COURIER_ROUTE(CID in number, DELIVERY_DAY in date)
is
  COURIER_NAME   EMPLOYEES.EMPLOYEE_NAME%type;
  COURIER_DD     ORDERS.DELIVERY_DATE%type;
  COURIER_STREET LOCATIONS.STREET%type;
  COURIER_HN     LOCATIONS.HOUSE_NUMBER%type;

  cursor COURIER_CURSOR is
    select
      EMPLOYEES.EMPLOYEE_NAME,
      ORDERS.DELIVERY_DATE,
      LOCATIONS.STREET,
      LOCATIONS.HOUSE_NUMBER
    from EMPLOYEES
      inner join ORDERS
        on ORDERS.EMPLOYEE_ID = EMPLOYEES.EMPLOYEE_ID
      inner join LOCATIONS
        on ORDERS.LOCATION_ID = LOCATIONS.LOCATION_ID
    where EMPLOYEES.EMPLOYEE_ID = CID
          and trunc(DELIVERY_DAY, 'day') = trunc(ORDERS.DELIVERY_DATE, 'day')
    order by ORDERS.DELIVERY_DATE;

    ID_NULL exception;
    DATE_NULL exception;
  begin
    if CID is null then
      raise ID_NULL;
    end if;
    if DELIVERY_DAY is null then
      raise DATE_NULL;
    end if;

    open COURIER_CURSOR;

    fetch COURIER_CURSOR into COURIER_NAME, COURIER_DD, COURIER_STREET, COURIER_HN;

    DBMS_OUTPUT.put_line(COURIER_NAME);
    DBMS_OUTPUT.put(to_char(COURIER_DD, 'hh:MM') || ' - ' || COURIER_STREET || ' ' || COURIER_HN || ';');

    loop
      fetch COURIER_CURSOR into COURIER_NAME, COURIER_DD, COURIER_STREET, COURIER_HN;

      exit when COURIER_CURSOR%notfound;

      DBMS_OUTPUT.put(to_char(COURIER_DD, 'hh:MM') || ' - ' || COURIER_STREET || ' ' || COURIER_HN || ';');
    end loop;

    DBMS_OUTPUT.NEW_LINE;

    close COURIER_CURSOR;
    exception
    when ID_NULL then DBMS_OUTPUT.put_line('ERROR: id_null is undefined');
    when DATE_NULL then DBMS_OUTPUT.put_line('ERROR: date_null is undefined');
    when others then DBMS_OUTPUT.put_line('ERROR: undefined exception');
  end;
/
execute get_courier_route(8, to_date('20-04-2017', 'DD-MM-YYYY'))

-- 3. Написать процедуру формирующую список скидок по итогам заданного месяца (месяц считает от введенной даты).
-- Условия: скидка 10% на самую часто заказываемую пиццу, скидка 5% на пиццу, которую заказали на самые
-- большую сумму, 15% на пиццу, которые заказывали с наибольшим числом напитков. Формат вывода: наименование – новая
-- цена, процент скидки.

create or replace procedure GET_SALE_PRODUCTS(G_MONTH in date)
is
  cursor POPULAR_PIZZAS is
    select
      PRODUCT_NAME,
      PRICE
    from PRODUCTS
    where PRODUCT_ID in (
      select PRODUCT_ID
      from ORDER_DETAILS
        inner join ORDERS on ORDERS.ORDER_ID = ORDER_DETAILS.ORDER_ID
      where trunc(ORDERS.ORDER_DATE, 'month') = trunc(G_MONTH, 'month')
      group by PRODUCT_ID
      having count(*) = (
        select max(count(*))
        from ORDER_DETAILS
          inner join ORDERS on ORDERS.ORDER_ID = ORDER_DETAILS.ORDER_ID
        where trunc(ORDERS.ORDER_DATE, 'month') = trunc(G_MONTH, 'month')
        group by PRODUCT_ID
      ));

  cursor MOST_EXPENSIVE_PIZZAS is
    with PIZZA_AGGR as (
        select
          ORDER_DETAILS.ORDER_ID,
          PRODUCTS.PRODUCT_ID,
          sum(PRODUCTS.PRICE * ORDER_DETAILS.QUANTITY) as TOTAL_PIZZA_PRICE
        from ORDER_DETAILS
          inner join PRODUCTS on ORDER_DETAILS.PRODUCT_ID = PRODUCTS.PRODUCT_ID
          inner join ORDERS on ORDER_DETAILS.ORDER_ID = ORDERS.ORDER_ID
        where PRODUCTS.CATEGORY_ID = 1
              and trunc(ORDERS.ORDER_DATE, 'month') = trunc(G_MONTH, 'month')
        group by PRODUCTS.PRODUCT_ID, ORDER_DETAILS.ORDER_ID
        order by TOTAL_PIZZA_PRICE
    )
    select distinct
      PRODUCT_NAME,
      PRICE
    from PIZZA_AGGR
      inner join PRODUCTS on PRODUCTS.PRODUCT_ID = PIZZA_AGGR.PRODUCT_ID
    where TOTAL_PIZZA_PRICE = (
      select max(TOTAL_PIZZA_PRICE)
      from PIZZA_AGGR
    );

  cursor PIZZAS_WITH_MOST_DRINKS is
    with DRINKS_AGGR as (
        select
          ORDER_DETAILS.ORDER_ID,
          sum(ORDER_DETAILS.QUANTITY) as TOTAL_DRINKS
        from ORDER_DETAILS
          inner join PRODUCTS on PRODUCTS.PRODUCT_ID = ORDER_DETAILS.PRODUCT_ID
          inner join ORDERS on ORDERS.ORDER_ID = ORDER_DETAILS.ORDER_ID
        where PRODUCTS.CATEGORY_ID = 2 and ORDER_DETAILS.ORDER_ID in (
          select ORDER_ID
          from ORDER_DETAILS
            inner join PRODUCTS on PRODUCTS.PRODUCT_ID = ORDER_DETAILS.PRODUCT_ID
          where PRODUCTS.CATEGORY_ID = 1 and trunc(ORDERS.ORDER_DATE, 'month') = trunc(G_MONTH, 'month')
        ) and trunc(ORDERS.ORDER_DATE, 'month') = trunc(G_MONTH, 'month')
        group by ORDER_DETAILS.ORDER_ID
    )
    select distinct
      Q.PRODUCT_NAME,
      Q.PRICE
    from DRINKS_AGGR
      inner join (
                   select
                     PRODUCTS.PRODUCT_ID,
                     ORDER_ID,
                     PRODUCT_NAME,
                     PRICE
                   from PRODUCTS
                     inner join ORDER_DETAILS on ORDER_DETAILS.PRODUCT_ID = PRODUCTS.PRODUCT_ID
                   where PRODUCTS.CATEGORY_ID = 1
                 ) Q on DRINKS_AGGR.ORDER_ID = Q.ORDER_ID
    where TOTAL_DRINKS in (
      select max(TOTAL_DRINKS)
      from DRINKS_AGGR) and DRINKS_AGGR.ORDER_ID in (
      select ORDER_ID
      from DRINKS_AGGR);

  L_PRODUCT_NAME PRODUCTS.PRODUCT_NAME%type;
  L_PRICE        PRODUCTS.PRICE%type;

    G_MONTH_NULL exception;
  begin
    if G_MONTH is null then
      raise G_MONTH_NULL;
    end if;

    open POPULAR_PIZZAS;
    DBMS_OUTPUT.put_line('popular');
    loop
      fetch POPULAR_PIZZAS into L_PRODUCT_NAME, L_PRICE;

      exit when POPULAR_PIZZAS%notfound;

      DBMS_OUTPUT.put_line(L_PRODUCT_NAME || ' - ' || L_PRICE * 0.9 || ', 10%');
    end loop;
    close POPULAR_PIZZAS;

    open MOST_EXPENSIVE_PIZZAS;
    DBMS_OUTPUT.put_line('most expensive');
    loop
      fetch MOST_EXPENSIVE_PIZZAS into L_PRODUCT_NAME, L_PRICE;

      exit when MOST_EXPENSIVE_PIZZAS%notfound;

      DBMS_OUTPUT.put_line(L_PRODUCT_NAME || ' - ' || L_PRICE * 0.95 || ', 5%');
    end loop;
    close MOST_EXPENSIVE_PIZZAS;

    open PIZZAS_WITH_MOST_DRINKS;
    DBMS_OUTPUT.put_line('with most drinks');
    loop
      fetch PIZZAS_WITH_MOST_DRINKS into L_PRODUCT_NAME, L_PRICE;

      exit when PIZZAS_WITH_MOST_DRINKS%notfound;

      DBMS_OUTPUT.put_line(L_PRODUCT_NAME || ' - ' || L_PRICE * 0.85 || ', 15%');
    end loop;
    close PIZZAS_WITH_MOST_DRINKS;

    exception
    when G_MONTH_NULL then DBMS_OUTPUT.put_line('g_month is null');
  end;
/
execute get_sale_products(to_date('20-04-2017', 'DD-MM-YYYY'));
