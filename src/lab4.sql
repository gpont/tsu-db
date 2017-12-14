-- 1. Написать триггер, активизирующийся при изменении содержимого таблицы `Orders` и проверяющий, чтобы срок доставки
-- был больше текущего времени не менее чем на 30 минут. Если время заказа не указано автоматически должно проставляться
-- текущее время, если срок доставки не указан, то он автоматически должен ставиться на час позже времени заказа.

-- drop old objects for tests
drop trigger ORDERS_TRIGGER;

-- "instead of" are only for views and cannot be used with tables
create or replace view ORDERS_VIEW as
  select *
  from ORDERS;

create or replace trigger DELIVERY_TRIGGER
  before insert
  on ORDERS
  for each row
  begin
    :NEW.ORDER_DATE := nvl(:NEW.ORDER_DATE, sysdate); -- return second arg if first is null
    :NEW.DELIVERY_DATE := nvl(:NEW.DELIVERY_DATE, to_date(sysdate + 1 / 24));
    if (:NEW.DELIVERY_DATE - :NEW.ORDER_DATE) * 24 < 0.5
    then
      RAISE_APPLICATION_ERROR(
        -20001,
        'ERROR: too short delivery date'
      );
    end if;
  end;

-- 2. Написать триггер, сохраняющий статистику изменений таблицы `EMPLOYEES` в таблице (таблицу создать), в которой
-- хранятся номер сотрудника дата изменения, тип изменения (insert, update, delete). Триггер также выводит на экран
-- сообщение с указанием количества дней прошедших со дня последнего изменения.

-- dropping old objects for tests
drop sequence ID_ITER;
drop table EMPLOYEES_STATS;

create table EMPLOYEES_STATS (
  ID          int not null primary key,
  EMPLOYEE_ID int not null,
  DATE_CHANGE date,
  TYPE_CHANGE varchar2(10)
);

-- iterator for increment id field
create sequence ID_ITER
  minvalue 1
  start with 1
  increment by 1
  cache 10;

create or replace trigger EMPLOYEES_STATS_TRIGGER
  after insert or update or delete
  on EMPLOYEES
  for each row
  declare
    NEW_TYPE_CHANGE varchar2(6);
    LAST_CHANGE     date;
  begin
    select LAST_CHANGE = DATE_CHANGE
    from EMPLOYEES
    order by EMPLOYEES_PK
    desc;

    ID_ITER.NEXTVAL; -- increment id iterator
    if inserting
    then
      NEW_TYPE_CHANGE := 'insert';
    elsif updating
    then
      NEW_TYPE_CHANGE := 'update';
    elsif deleting
    then
      NEW_TYPE_CHANGE := 'delete';
    end if;

    insert into STATS (
      ID,
      EMPLOYEE_ID,
      DATE_CHANGE,
      TYPE_CHANGE
    ) values (
      ID_ITER.CURVAL,
      :NEW.EMPLOYEE_ID,
      sysdate,
      NEW_TYPE_CHANGE
    );

    DBMS_OUTPUT.put_line('INFO: ' || (days(sysdate) - days(LAST_CHANGE)) || ' days have passed since the last change');
  end;

-- 3. Добавить к таблице `Orders` не обязательное поле `cipher`, которое должно заполняться автоматически согласно шаблону: `<YYYYMMDD> - <номер район> - <номер заказа в рамках месяца>`. Номера не обязательно должны соответствовать дате заказа, если район не известен, то “ номер района” равен 0.

dropping old objects for tests
alter table ORDERS
  drop column CIPHER;

alter table ORDERS
  add CIPHER varchar2(24);

create or replace trigger ORDERS_TRIGGER
  after insert
  on ORDERS
  for each row
  declare
    CIPHER_STR   varchar2(24);
    ORDER_NUMBER int;
  begin
    -- getting order number within the order month
    select
      ORDER_NUMBER = count(:NEW.ORDER_ID),
      ORDER_DATE
    from ORDERS
    where extract( month from order_date) = extract( month from :new.order_date);

    CIPHER_STR = concat(
        concat(to_char(sysdate, '<YYYYMMDD> - '), to_char(:NEW.LOCATION_ID)),
        concat(' - ', ORDER_NUMBER)
    );

    update ORDERS
    set CIPHER = CIPHER_STR
    where ORDER_ID = :NEW.ORDER_ID;
  end;
