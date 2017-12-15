-- 1. Написать триггер, активизирующийся при изменении содержимого таблицы `Orders` и проверяющий, чтобы срок доставки
-- был больше текущего времени не менее чем на 30 минут. Если время заказа не указано автоматически должно проставляться
-- текущее время, если срок доставки не указан, то он автоматически должен ставиться на час позже времени заказа.

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
drop table EMPLOYEES_STATS;

create table EMPLOYEES_STATS (
  EMPLOYEE_ID int not null,
  DATE_CHANGE date,
  TYPE_CHANGE varchar2(10)
);

create or replace trigger EMPLOYEES_STATS_TRIGGER
  after insert or update or delete
  on EMPLOYEES
  for each row
  declare
    NEW_TYPE_CHANGE varchar2(10);
    LAST_CHANGE     date;
    CURRENT_ID      number;
  begin
    -- get last change date
    select (
      select DATE_CHANGE
      from (
        select DATE_CHANGE
        from EMPLOYEES_STATS
        order by DATE_CHANGE desc
      )
      where ROWNUM = 1
    )
    into LAST_CHANGE
    from DUAL;

    if inserting
    then
      NEW_TYPE_CHANGE := 'insert';
      CURRENT_ID := :NEW.EMPLOYEE_ID;
    elsif updating
    then
      NEW_TYPE_CHANGE := 'update';
      CURRENT_ID := :OLD.EMPLOYEE_ID;
    elsif deleting
    then
      NEW_TYPE_CHANGE := 'delete';
      CURRENT_ID := :OLD.EMPLOYEE_ID;
    end if;

    insert into EMPLOYEES_STATS (
      EMPLOYEE_ID,
      DATE_CHANGE,
      TYPE_CHANGE
    ) values (
      CURRENT_ID,
      sysdate,
      NEW_TYPE_CHANGE
    );

    if LAST_CHANGE is not null then
      DBMS_OUTPUT.put_line('INFO: ' || trunc(sysdate - LAST_CHANGE) || ' days have passed since the last change');
    end if;
  end;

-- 3. Добавить к таблице `Orders` не обязательное поле `cipher`, которое должно заполняться автоматически согласно шаблону: `<YYYYMMDD> - <номер район> - <номер заказа в рамках месяца>`. Номера не обязательно должны соответствовать дате заказа, если район не известен, то “ номер района” равен 0.

-- dropping old objects for tests
alter table ORDERS
  drop column CIPHER;

alter table ORDERS
  add CIPHER varchar2(32);

create or replace trigger ORDERS_TRIGGER
  after insert
  on ORDERS
  for each row
  declare
    CIPHER_STR   varchar2(32);
    ORDER_NUMBER int;
  begin
    -- getting order number within the order month
    select
      ORDER_NUMBER = count(:NEW.ORDER_ID),
      ORDER_DATE
    from ORDERS
    where extract(month from ORDER_DATE) = extract(month from :NEW.ORDER_DATE);

    CIPHER_STR = concat(
        concat(to_char(sysdate, '<YYYYMMDD> - '), to_char(:NEW.LOCATION_ID)),
        concat(' - ', ORDER_NUMBER)
    );

    update ORDERS
    set CIPHER = CIPHER_STR
    where ORDER_ID = :NEW.ORDER_ID;
  end;
/
