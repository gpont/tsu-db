-- 1. Написать триггер, активизирующийся при изменении содержимого таблицы `Orders` и проверяющий, чтобы срок доставки был больше текущего времени не менее чем на 30 минут. Если время заказа не указано автоматически должно проставляться текущее время, если срок доставки не указан, то он автоматически должен ставиться на час позже времени заказа.

-- instead of are only for views and cannot be used with tables
create or replace view Order_View as select * from Orders;

create or replace trigger Delivery
instead of insert on Order_View
for each row
begin
    :new.order_date := nvl(:new.order_date, sysdate); -- return second arg if first is null
    :new.delivery_date := nvl(:new.delivery_date, to_date(sysdate + 1/24));
/*
    if (:new.order_date is null) then
        :new.order_date := sysdate;
    end if;
    if (:new.delivery_date is null) then
        :new.delivery_date := to_date(sysdate + 1/24);
    end if;
*/
    if (new_delivery_date - new_order_date)*24 < 0.5 then
        dbms_output.put_line('ERROR: too short delivery date');
    else
        insert into Orders (
            order_id,
            payment_method_id,
            employee_id,
            customer_id,
            ex_comment,
            location_id,
            delivery_date,
            order_date,
            end_date
        ) values (
            :new.order_id,
            :new.payment_method_id,
            :new.employee_id,
            :new.customer_id,
            :new.ex_comment,
            :new.location_id,
            new_delivery_date,
            new_order_date,
            :new.end_date
        );
    end if;
end;
/
-- Tests
-- show errors trigger Delivery;
/*
insert into Orders (
    order_id,
    payment_method_id,
    employee_id,
    customer_id,
    ex_comment,
    location_id
) values (
    731,
    1,
    1,
    1,
    ' ',
    1
);

select *
from Orders
where order_id = 731;
*/
-- 2. Написать триггер, сохраняющий статистику изменений таблицы `EMPLOYEES` в таблице (таблицу создать), в которой хранятся номер сотрудника дата изменения, тип изменения (insert, update, delete). Триггер также выводит на экран сообщение с указанием количества дней прошедших со дня последнего изменения.

-- create table Stats (
--     id int not null primary key,
--     employee_id int not null,
--     date_change date,
--     type_change varchar2(10)
-- );

-- -- iterator for increment id field
-- create sequence id_iter
-- minvalue 1
-- start with 1
-- increment by 1
-- cache 10;

-- create trigger Stats_Trigger
-- after insert or update or delete on Employees
-- for each row
-- declare
--     new_type_change varchar2(10);
--     last_change date;
-- begin
--     select last_change = date_change
--     from employees
--     order by id
--     desc;

--     id_iter.nextval; -- increment id iterator
--     case
--         when insert then
--             new_type_change := 'insert';
--         when delete then
--             new_type_change := 'delete';
--         when update then
--             new_type_change := 'update';
--     end case;

--     insert into stats (
--         id,
--         employee_id,
--         date_change,
--         type_change
--     ) values (
--         id_iter.curval,
--         :new.employee_id,
--         sysdate,
--         new_type_change
--     )

--     dbms_output.put_line('info: '||(days(sysdate)-days(last_change))||' days have passed since the last change');
-- end;
-- /

-- 3. Добавить к таблице `Orders` не обязательное поле `cipher`, которое должно заполняться автоматически согласно шаблону: `<YYYYMMDD> - <номер район> - <номер заказа в рамках месяца>`. Номера не обязательно должны соответствовать дате заказа, если район не известен, то “ номер района” равен 0.

-- alter table Orders
-- add cipher varchar2(24);

-- create trigger Orders_Trigger
-- after insert on Orders
-- for each row
-- begin
--     declare cipher_str varchar2(24);
--     declare order_number int;

--     -- getting order number within the order month
--     select order_number = count(id), order_date
--     where extract(month from order_date) = extract(month from :new.order_date);

--     cipher_str = concat(
--         concat(to_char(sysdate, '<YYYYMMDD> - '), to_char(:new.location_id)),
--         concat(' - ', order_number)
--     );

--     update Orders
--     set cipher = cipher_str
--     where id = :new.id;
-- end;
-- /
