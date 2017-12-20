-- Вариант 2 (Зарплата)

-- 1. Написать команды создания таблиц заданной схемы с указанием необходимых ключей и ограничений. Все ограничения
-- должны быть именованными (для первичных ключей имена должны начинаться с префикса `PK_`, для вторичного ключа –
-- `FK_`, проверки - `CH_`).
-- Ограничения:
--   продолжительность болезни не может быть менее 1 для и более 3 месяцев;
--   оклад и надбавка не могут быть отрицательными;
--   значение `null` допустимо только в поле адрес.

create table EMPLOYEES (
  EMPLOYEE_ID   int,
  NAME          varchar2(128) not null,
  ADDRESS       varchar2(128),
  POSITION      varchar2(32)  not null,
  SALARY        int           not null,
  FAMILY_STATUS varchar2(32)  not null,
  constraint PK_EMPLOYEE primary key (EMPLOYEE_ID),
  constraint CH_SALARY check (SALARY >= 0)
);

create table DISEASES
(
  DISEASE_ID int primary key,
  NAME       varchar2(64) not null,
  constraint PK_SICK_ID primary key (DISEASE_ID)
);

create table HOSPITAL_SHEETS
(
  HS_ID       int primary key,
  DATE_START  date not null,
  DURATION    date not null,
  DISEASE_ID  int  not null,
  EMPLOYEE_ID int  not null,
  constraint FK_DISEASE_ID foreign key (DISEASE_ID) references DISEASES (DISEASE_ID),
  constraint FK_EMPLOYEE_ID foreign key (EMPLOYEE_ID) references EMPLOYEES (EMPLOYEE_ID),
  constraint CH_DURATION check (
    DURATION > 1
    and extract(month from DATE_START) - extract(month from DATE_START + DURATION) < 3
  )
);

create table SALARY_INCREMENTS (
  INCREMENT_ID int,
  NAME         varchar2(64) not null,
  INC_VALUE    int          not null,
  constraint PK_INCREMENT_ID primary key (INCREMENT_ID)
);

create table EMPLOYEES_SALARY_INCREMENTS (
  INCREMENT_ID int,
  EMPLOYEE_ID  int,
  -- 6. Создать индекс для таблицы `Сотрудники_надбавки` содержащий 2 поля.
  constraint PK_IDS primary key (INCREMENT_ID, EMPLOYEE_ID),
  constraint FK_INCREMENT_ID foreign key (INCREMENT_ID) references SALARY_INCREMENTS (INCREMENT_ID),
  constraint FK_EMPLOYEE_ID foreign key (EMPLOYEE_ID) references EMPLOYEES (EMPLOYEE_ID)
);

-- 2. Заполнить созданные таблицы данными, 5-10 записей для каждой таблицы.

-- EMPLOYEES filling
insert into EMPLOYEES (EMPLOYEE_ID, NAME, ADDRESS, POSITION, SALARY, FAMILY_STATUS)
values (1, 'Bank Smeath', '338 Mesta Street', 'Инженер', 50021, 'not married');
insert into EMPLOYEES (EMPLOYEE_ID, NAME, ADDRESS, POSITION, SALARY, FAMILY_STATUS)
values (2, 'Tonnie Castiglione', '60 Tony Point, Tomsk', 'Бухгалтер', 65909, 'not married');
insert into EMPLOYEES (EMPLOYEE_ID, NAME, ADDRESS, POSITION, SALARY, FAMILY_STATUS)
values (3, 'Glennie Blakden', '0435 Westridge Lane', 'Начальник отдела', 39632, 'married');
insert into EMPLOYEES (EMPLOYEE_ID, NAME, ADDRESS, POSITION, SALARY, FAMILY_STATUS)
values (4, 'Madonna Parzis', '27987 Mayfield Park', 'Разнорабочий', 24977, 'not married');
insert into EMPLOYEES (EMPLOYEE_ID, NAME, ADDRESS, POSITION, SALARY, FAMILY_STATUS)
values (5, 'Marcus Chuter', '68807 Sullivan Way', 'Специалист', 68584, 'married');
insert into EMPLOYEES (EMPLOYEE_ID, NAME, ADDRESS, POSITION, SALARY, FAMILY_STATUS)
values (6, 'Flint De Ferrari', '2969 Commercial Circle', 'Инженер', 68630, 'not married');
insert into EMPLOYEES (EMPLOYEE_ID, NAME, ADDRESS, POSITION, SALARY, FAMILY_STATUS)
values (7, 'Petey Levett', '6161 Barby Park, Tomsk', 'Инженер', 88470, 'married');
insert into EMPLOYEES (EMPLOYEE_ID, NAME, ADDRESS, POSITION, SALARY, FAMILY_STATUS)
values (8, 'Jenn Rosbottom', '8247 Bonner Park', 'Специалист', 51764, 'not married');
insert into EMPLOYEES (EMPLOYEE_ID, NAME, ADDRESS, POSITION, SALARY, FAMILY_STATUS)
values (9, 'Rosalind Mc Harg', '73017 Commercial Park', 'Специалист', 98679, 'not married');
insert into EMPLOYEES (EMPLOYEE_ID, NAME, ADDRESS, POSITION, SALARY, FAMILY_STATUS)
values (10, 'Mannie Willishire', '10 1st Pass', 'Разнорабочий', 75327, 'married');

-- DISEASES filling
insert into DISEASES (DISEASE_ID, NAME) values (1, 'Ischemic heart disease');
insert into DISEASES (DISEASE_ID, NAME) values (2, 'Cerebrovascular disease');
insert into DISEASES (DISEASE_ID, NAME) values (3, 'Lower respiratory tract infections');
insert into DISEASES (DISEASE_ID, NAME) values (4, 'AIDS');
insert into DISEASES (DISEASE_ID, NAME) values (5, 'Chronic obstructive pulmonary disease');
insert into DISEASES (DISEASE_ID, NAME) values (6, 'Diarrheal diseases');
insert into DISEASES (DISEASE_ID, NAME) values (7, 'Tuberculosis');
insert into DISEASES (DISEASE_ID, NAME) values (8, 'Malaria');
insert into DISEASES (DISEASE_ID, NAME) values (9, 'Trachea cancer');
insert into DISEASES (DISEASE_ID, NAME) values (10, 'Stomach cancer');

-- HOSPITAL_SHEETS filling
insert into HOSPITAL_SHEETS (HS_ID, DATE_START, DURATION, DISEASE_ID, EMPLOYEE_ID)
values (1, '1/15/2017', '4/28/0001', 10, 10);
insert into HOSPITAL_SHEETS (HS_ID, DATE_START, DURATION, DISEASE_ID, EMPLOYEE_ID)
values (2, '2/26/2017', '11/17/0000', 1, 6);
insert into HOSPITAL_SHEETS (HS_ID, DATE_START, DURATION, DISEASE_ID, EMPLOYEE_ID)
values (3, '5/31/2017', '5/2/0000', 10, 1);
insert into HOSPITAL_SHEETS (HS_ID, DATE_START, DURATION, DISEASE_ID, EMPLOYEE_ID)
values (4, '12/12/2017', '12/25/0000', 8, 3);
insert into HOSPITAL_SHEETS (HS_ID, DATE_START, DURATION, DISEASE_ID, EMPLOYEE_ID)
values (5, '2/25/2017', '4/17/0000', 3, 8);
insert into HOSPITAL_SHEETS (HS_ID, DATE_START, DURATION, DISEASE_ID, EMPLOYEE_ID)
values (6, '10/14/2017', '9/19/0001', 9, 1);
insert into HOSPITAL_SHEETS (HS_ID, DATE_START, DURATION, DISEASE_ID, EMPLOYEE_ID)
values (7, '7/28/2017', '4/14/0000', 3, 2);
insert into HOSPITAL_SHEETS (HS_ID, DATE_START, DURATION, DISEASE_ID, EMPLOYEE_ID)
values (8, '3/29/2017', '2/14/0001', 3, 6);
insert into HOSPITAL_SHEETS (HS_ID, DATE_START, DURATION, DISEASE_ID, EMPLOYEE_ID)
values (9, '3/7/2017', '12/27/0001', 9, 4);
insert into HOSPITAL_SHEETS (HS_ID, DATE_START, DURATION, DISEASE_ID, EMPLOYEE_ID)
values (10, '3/31/2017', '3/27/0001', 10, 1);

-- SALARY_INCREMENTS filling
insert into SALARY_INCREMENTS (INCREMENT_ID, NAME, INC_VALUE)
values (1, 'Presence of a cat', 7625);
insert into SALARY_INCREMENTS (INCREMENT_ID, NAME, INC_VALUE)
values (2, 'Disabled in the family', 8327);
insert into SALARY_INCREMENTS (INCREMENT_ID, NAME, INC_VALUE)
values (3, 'Harmful production', 9790);
insert into SALARY_INCREMENTS (INCREMENT_ID, NAME, INC_VALUE)
values (4, 'War veteran', 2301);
insert into SALARY_INCREMENTS (INCREMENT_ID, NAME, INC_VALUE)
values (5, 'Student', 5176);
insert into SALARY_INCREMENTS (INCREMENT_ID, NAME, INC_VALUE)
values (6, 'Can cook delicious coffee', 5338);
insert into SALARY_INCREMENTS (INCREMENT_ID, NAME, INC_VALUE)
values (7, 'Social activist', 9558);
insert into SALARY_INCREMENTS (INCREMENT_ID, NAME, INC_VALUE)
values (8, 'Beautiful eyes', 6461);
insert into SALARY_INCREMENTS (INCREMENT_ID, NAME, INC_VALUE)
values (9, 'Punctuality', 4614);
insert into SALARY_INCREMENTS (INCREMENT_ID, NAME, INC_VALUE)
values (10, 'Can play drums', 6947);

-- EMPLOYEES_SALARY_INCREMENTS filling
insert into EMPLOYEES_SALARY_INCREMENTS (INCREMENT_ID, EMPLOYEE_ID) values (7, 5);
insert into EMPLOYEES_SALARY_INCREMENTS (INCREMENT_ID, EMPLOYEE_ID) values (4, 10);
insert into EMPLOYEES_SALARY_INCREMENTS (INCREMENT_ID, EMPLOYEE_ID) values (6, 8);
insert into EMPLOYEES_SALARY_INCREMENTS (INCREMENT_ID, EMPLOYEE_ID) values (10, 3);
insert into EMPLOYEES_SALARY_INCREMENTS (INCREMENT_ID, EMPLOYEE_ID) values (3, 2);
insert into EMPLOYEES_SALARY_INCREMENTS (INCREMENT_ID, EMPLOYEE_ID) values (5, 7);
insert into EMPLOYEES_SALARY_INCREMENTS (INCREMENT_ID, EMPLOYEE_ID) values (6, 2);
insert into EMPLOYEES_SALARY_INCREMENTS (INCREMENT_ID, EMPLOYEE_ID) values (3, 9);
insert into EMPLOYEES_SALARY_INCREMENTS (INCREMENT_ID, EMPLOYEE_ID) values (10, 1);
insert into EMPLOYEES_SALARY_INCREMENTS (INCREMENT_ID, EMPLOYEE_ID) values (8, 6);

-- 3. Запросы

-- 3.1. Вывести список сотрудников проживающих в Томске, оклад которых больше 35 000 рублей, упорядочив их по размеру
-- оклада.

select
  NAME,
  ADDRESS
from EMPLOYEES
where SALARY > 35000
      and ADDRESS like '%Tomsk%';

-- 3.2. Вывести список сотрудников получающих надбавку за вредность.

select EMPLOYEES.NAME
from EMPLOYEES
  inner join EMPLOYEES_SALARY_INCREMENTS on EMPLOYEES_SALARY_INCREMENTS.EMPLOYEE_ID = EMPLOYEES.EMPLOYEE_ID
  inner join SALARY_INCREMENTS on EMPLOYEES_SALARY_INCREMENTS.INCREMENT_ID = SALARY_INCREMENTS.INCREMENT_ID
where SALARY_INCREMENTS.NAME like '%Harmful production%';

-- 3.3. Сформировать статистику сотрудников по семейному положению.

select
  FAMILY_STATUS,
  count(EMPLOYEE_ID)
from EMPLOYEES
group by FAMILY_STATUS;

-- 3.4. Вывести список сотрудников, у которых оклад меньше среднего по должности.

select
  NAME,
  SALARY,
  EMPLOYEES.POSITION
from EMPLOYEES
  inner join (
               select
                 POSITION,
                 avg(SALARY) as AVG_SALARY
               from EMPLOYEES
               group by POSITION
             ) AVG_SAL on AVG_SAL.POSITION = EMPLOYEES.POSITION and AVG_SAL.AVG_SALARY < EMPLOYEES.SALARY;

-- 3.5. Вывести список болезней которыми болели суммарно не более 2-х сотрудников

select
  NAME,
  count(DIS_STATS.EMP_COUNT)
from DISEASES
  inner join (
               select
                 DISEASE_ID,
                 count(EMPLOYEE_ID) as EMP_COUNT
               from HOSPITAL_SHEETS
               group by DISEASE_ID
             ) DIS_STATS on DIS_STATS.EMP_COUNT <= 2
group by DISEASES.NAME;

-- 4. Изменений данных.

-- 4.1. Провести увеличение оклада на 10% всем сотрудникам, которые не болели в течение всего прошлого года.

update EMPLOYEES
set SALARY = SALARY * 1.01
where not exists(
    select
      DATE_START,
      DURATION,
      EMPLOYEE_ID
    from HOSPITAL_SHEETS
    where HOSPITAL_SHEETS.EMPLOYEE_ID = EMPLOYEES.EMPLOYEE_ID
          and DATE_START > add_months(sysdate, -12)
);

-- 4.2. Удалить не используемые надбавки.

delete
from SALARY_INCREMENTS
where not exists(
    select INCREMENT_ID
    from EMPLOYEES_SALARY_INCREMENTS
    where EMPLOYEES_SALARY_INCREMENTS.INCREMENT_ID = SALARY_INCREMENTS.INCREMENT_ID
);

-- 5. Представления

-- 5.1. Сформировать список сотрудников, у которых общая продолжительность болезней в текущем году превышает три месяца.
-- Результат оформить в виде представления, содержащего фамилию сотрудника и общее число дней по всем болезням.

create or replace view DISEASES_EMPLOYEES(NAME, ALL_DAYS)
  as
    select
      NAME,
      extract(day from sum(HS.DURATION)) as ALL_DAYS
    from EMPLOYEES
      inner join HOSPITAL_SHEETS HS on EMPLOYEES.EMPLOYEE_ID = HS.EMPLOYEE_ID
    group by NAME
    having sum(HS.DURATION) > to_date('3', 'mm');

-- 5.2. Сформировать зарплатную ведомость, просуммировав оклад и все надбавки + 30% районный коэффициент, минус
-- подоходный налог 13% и профсоюзный взнос 1%. Ведомость оформить в виде представления, содержащего табельный номер,
-- ФИО, зарплата без вычетов, зарплата с вычетами.

create or replace view SALARY_REPORT(EMPLOYEE_ID, NAME, SALARY_FULL, SALARY_AFTER_TAXES)
  as
    select
      EMPLOYEES.EMPLOYEE_ID,
      EMPLOYEES.NAME,
      (EMPLOYEES.SALARY + sum(S.INC_VALUE)) * 1.3 as SALARY_FULL,
      (EMPLOYEES.SALARY + sum(S.INC_VALUE)) * 1.3 * 0.86  as SALARY_AFTER_TAXES
    from EMPLOYEES
      inner join EMPLOYEES_SALARY_INCREMENTS ESI on EMPLOYEES.EMPLOYEE_ID = E.EMPLOYEE_ID
      inner join SALARY_INCREMENTS S on ESI.INCREMENT_ID = S.INCREMENT_ID;

-- 6. Создать индекс для таблицы `Сотрудники_надбавки` содержащий 2 поля.
-- Go to creating table EMPLOYEES_SALARY_INCREMENTS

-- 7. Создать пакет, состоящий из процедуры и функций, включить обработчики исключительных ситуаций.

create or replace package EMPLOYEES_FUNCTIONS as
  function COUNT_HOSPITAL_SHEETS(EMPLOYEE_ID int, DATE_START date, DATE_END date) return int;
end EMPLOYEES_FUNCTIONS;

create or replace package body EMPLOYEES_FUNCTIONS as

  -- 7.1. Функция возвращает число больничных листов, выписанных сотруднику за заданный период (Табельный номер и
  -- промежуток времени – параметры функции).

  function COUNT_HOSPITAL_SHEETS(EMPLOYEE_ID int, DATE_START date, DATE_END date)
    return int
  as
    HS_COUNTER int;
    begin
      select (
        select HS_COUNT
        from (
          select count(HS_ID) as HS_COUNT
          from HOSPITAL_SHEETS
          where HOSPITAL_SHEETS.EMPLOYEE_ID = EMPLOYEE_ID
                and HOSPITAL_SHEETS.DATE_START >= DATE_START
                and (HOSPITAL_SHEETS.DATE_START + HOSPITAL_SHEETS.DURATION) <= DATE_END
        )
        where ROWNUM = 1
      )
      into HS_COUNTER
      from DUAL;

      return HS_COUNTER;
    end;

  -- 7.2. Функция формирует список сотрудников болевших в течение года (Табельный номер и год – аргументы функции).
  -- Формат вывода: `Табельный номер и ФИО сотрудника: список болезней.`

  procedure EMPLOYEES_HS_REPORT(ARG_EMPLOYEE_ID int, ARG_YEAR date)
  as
    cursor EMPLOYEES_CURSOR is
      select
        EMPLOYEES.EMPLOYEE_ID,
        EMPLOYEES.NAME,
        DISEASES.NAME as DISEASE_NAME
      from EMPLOYEES
        inner join HOSPITAL_SHEETS HS on EMPLOYEES.EMPLOYEE_ID = HS.EMPLOYEE_ID
        inner join DISEASES D on HS.DISEASE_ID = D.DISEASE_ID
      where extract(month from HS.DATE_START) >= ARG_YEAR
            and EMPLOYEES.EMPLOYEE_ID = ARG_EMPLOYEE_ID
      order by EMPLOYEES.EMPLOYEE_ID;
    OLD_ID int;
      ARG_EMPLOYEE_ID_NULL exception;
      ARG_YEAR_NULL exception;
    begin
      if ARG_EMPLOYEE_ID is null
      then
        raise ARG_EMPLOYEE_ID_NULL;
      end if;

      if ARG_YEAR is null
      then
        raise ARG_YEAR_NULL;
      end if;

      for RECORD in EMPLOYEES_CURSOR
      loop
        if RECORD.EMPLOYEE_ID != OLD_ID
        then
          DBMS_OUTPUT.put_line(RECORD.EMPLOYEE_ID || ' ' || RECORD.NAME || ': ');
        end if;
        DBMS_OUTPUT.put_line(RECORD.DISEASE_NAME || ', ');

        OLD_ID := RECORD.EMPLOYEE_ID;
      end loop;
      exception
      when ARG_EMPLOYEE_ID_NULL
      then
      DBMS_OUTPUT.put_line('ERROR: employee id is null');
      when ARG_YEAR_NULL
      then
      DBMS_OUTPUT.put_line('ERROR: year is null');
    end;

  -- 7.3. Процедура выдает информацию по всем болезням, которыми болели сотрудники более 2. Формат вывода: ФИО
  -- сотрудника и список болезней.

end EMPLOYEES_FUNCTIONS;

-- 8. Создать пакет, состоящий из триггеров, включить обработчики исключительных ситуаций.

create or replace package EMPLOYEES_TRIGGERS as
  procedure CHECK_TRIGGER_PROC(POSITION varchar2(32), SALARY int);
  procedure EMPLOYEES_STATS_TRIGGER_PROC(NEW_TYPE_CHANGE varchar2(10), CURRENT_ID number);
end EMPLOYEES_TRIGGERS;

create package body EMPLOYEES_TRIGGERS as

  -- 8.1. Триггер, активизирующийся при изменении содержимого таблицы `Сотрудники` и проверяющий, чтобы должность
  -- была из допустимого списка должностей и поле оклад заполнялось автоматически в зависимости от должности, в
  -- соответствии с таблицей:
  -- Инженер          - 5000
  -- Бухгалтер        - 5000
  -- Начальник отдела - 10000
  -- Разнорабочий     - 2000
  -- Специалист       - 4000

  procedure CHECK_TRIGGER_PROC(NEW_POSITION varchar2(32), NEW_SALARY int)
  as
    POSITION_SALARY_EXIST number;
      BAD_SALARY exception;
    begin
      select 1
      into POSITION_SALARY_EXIST
      from POSITIONS_SALARY
      where POSITION = NEW_POSITION
            and SALARY = NEW_SALARY;

      if POSITION_SALARY_EXIST
      then
        raise BAD_SALARY;
      end if;
      exception
      when BAD_SALARY
      then
      DBMS_OUTPUT.put_line('ERROR: bad salary');
    end;

  -- 8.2. Триггер, сохраняющий статистику изменений таблицы `Сотрудники` в таблице `Сотрудники_Статистика`, в которой
  -- хранится дата изменения, тип изменения (`insert`, `update`, `delete`). Триггер также выводит на экран сообщение с
  -- указанием количества дней прошедших со дня последнего изменения.

  procedure EMPLOYEES_STATS_TRIGGER_PROC(NEW_TYPE_CHANGE varchar2(10), CURRENT_ID number)
  as
    LAST_CHANGE date;
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

end EMPLOYEES_TRIGGERS;

-- create and fill table for salary check
create table POSITIONS_SALARY (
  POSITION varchar2(24),
  SALARY   int not null
);
insert into POSITIONS_SALARY (POSITION, SALARY) values ('Инженер', 5000);
insert into POSITIONS_SALARY (POSITION, SALARY) values ('Бухгалтер', 5000);
insert into POSITIONS_SALARY (POSITION, SALARY) values ('Начальник отдела', 10000);
insert into POSITIONS_SALARY (POSITION, SALARY) values ('Разнорабочий', 2000);
insert into POSITIONS_SALARY (POSITION, SALARY) values ('Специалист', 4000);

create or replace trigger CHECK_TRIGGER
  before update
  on EMPLOYEES
  for each row
  begin
    -- check
    EMPLOYEES_TRIGGERS.CHECK_TRIGGER_PROC(:NEW.POSITION, :NEW.SALARY);

    -- insert
    insert into EMPLOYEES (EMPLOYEE_ID, NAME, ADDRESS, POSITION, SALARY, FAMILY_STATUS)
    values (:NEW.EMPLOYEE_ID, :NEW.NAME, :NEW.ADDRESS, :NEW.POSITION, :NEW.SALARY, :NEW.FAMILY_STATUS);
  end;

-- table for employees statistics
create table EMPLOYEES_STATS (
  EMPLOYEE_ID int not null,
  DATE_CHANGE date,
  TYPE_CHANGE varchar2(10)
);

create or replace trigger EMPLOYEES_STATS_TRIGGER
  after insert or update or delete
  on EMPLOYEES
  for each row
  begin
    if inserting
    then
      EMPLOYEES_TRIGGERS.EMPLOYEES_STATS_TRIGGER_PROC('insert', :NEW.EMPLOYEE_ID);
    elsif updating
      then
        EMPLOYEES_TRIGGERS.EMPLOYEES_STATS_TRIGGER_PROC('update', :OLD.EMPLOYEE_ID);
    elsif deleting
      then
        EMPLOYEES_TRIGGERS.EMPLOYEES_STATS_TRIGGER_PROC('delete', :OLD.EMPLOYEE_ID);
    end if;
  end;
