## Предметная область

При приеме на работу в организации для каждого сотрудника заводится учетная карточка, в которой сотруднику присваивается табельный номер, хранятся анкетные данные (дата рождения, пол, паспортные данные, адрес, телефон). Сотрудника принимают на определенную должность в определенное подразделение. В одном подразделении может быть несколько сотрудников с одинаковыми и /или различными должностями. Для каждой должности определён оклад. В подразделении имеется штат, т.е. перечень должностей с указанием их количества. Новый сотрудник может приниматься на работу на должность в определенное подразделение только в том случае, когда должность вакантна (т.е. не занята другим сотрудником).
Сотрудники могут иметь надбавки за ученую степень (кандидат наук – 10% от оклада, доктор наук – 20% от оклада) и/или категорию секретности (от 5 до 15%).
Некоторые сотрудники долгое время работают в организации и занимали в разное время те или иные должности. Эта информация фиксируется в журнале перемещений в соответствии с приказом. В приказе указывается дата перемещения и новая должность. При увольнении также издается приказ и освобождаемая должность в данном подразделении становится вакантной.

## Задание.

1.	Создать базу данных в соответствии с предметной областью. Определить необходимые отношения, ограничения для полей. Установить связи для поддержки ссылочной целостности.

2.	Создать триггеры:
А) для формирования значений первичных ключей.
Б) для проверки правильности формирования "Серия паспорта" и "Номер паспорта". Маска серии для паспорта – 4 цифры. Маска номера: шесть цифр (обратите внимание на то, что в номере могут быть ведущие нули).
В) для запрета удаления сотрудника в том случае, если для него не имеется приказ об увольнении.

3.	Создать пакет, содержащий следующие функции и процедуры:

	А) Функция, определяющая по дате рождения, является ли человек юбиляром в текущем году, и выдающая для юбиляра возраст (юбилейную дату, например, "50")

	Б) Функция, определяющая количество полных лет и месяцев, прошедших между двумя датами. Если вторая дата не указана, берется текущая дата. Функция вызывается для даты приёма на работу

	В) Процедура, выводящая список всех сотрудников – юбиляров текущего года (с указанием даты юбилея и возраста).

	Г) Процедура, выводящая сведения об отсутствии вакансии для должности в подразделение, куда собираются зачислить нового сотрудника.


# Решение

## UML Схема
https://drive.google.com/file/d/12-1XkIgv3KsH4vUdFRDuny22ARyq0VSR/view?usp=sharing

## Код
```SQL
-- Задача 1

-- Создание таблиц
CREATE TABLE
	Departments (
		Id SERIAL,
		Title VARCHAR(255) NOT NULL,
		CONSTRAINT department_Id PRIMARY KEY (Id)
	);

CREATE TABLE
	Positions (
		Id SERIAL,
		DepartmentId INTEGER,
		Title VARCHAR(255) NOT NULL,
		NumberOfPossibleWorkers INTEGER,
		Salary MONEY NOT NULL,
		CONSTRAINT position_Id PRIMARY KEY (Id)
	);

CREATE TABLE
	Workers (
		Id SERIAL,
		DateOfBirth DATE NOT NULL,
		Gender VARCHAR(20) NOT NULL,
		PassportSeries VARCHAR(20) NOT NULL,
		PassportNumber VARCHAR(20) NOT NULL,
		Address VARCHAR(255) NOT NULL,
		Phone VARCHAR(20) NOT NULL,
		PositionId INTEGER NOT NULL,
		FullName VARCHAR(255) not NULL,
		CONSTRAINT worker_Id PRIMARY KEY (Id),
		UNIQUE (Phone)
	);

CREATE TABLE
	MovementLog (
		Id SERIAL,
		WorkerId INTEGER NOT NULL,
		NextPosition INTEGER,
		DateOfMove DATE NOT NULL,
		CONSTRAINT movement_log_Id PRIMARY KEY (Id)
	);

CREATE TABLE
	Bonuses (
		Id SERIAL,
		Title VARCHAR(255) NOT NULL,
		Porecent INTEGER NOT NULL,
		CONSTRAINT bonuse_Id PRIMARY KEY (Id)
	);

CREATE TABLE
	ActiveBonuses (
		Id SERIAL,
		BonuseId INTEGER NOT NULL,
		WorkerId INTEGER NOT NULL,
		CONSTRAINT active_bonuse_id PRIMARY KEY (Id)
	);

-- Добавление внешних ключей
ALTER TABLE Positions
ADD CONSTRAINT department_of_position FOREIGN KEY (DepartmentId) REFERENCES Departments (Id);

ALTER TABLE Workers
ADD CONSTRAINT position_of_worker FOREIGN KEY (PositionId) REFERENCES Positions (Id);

ALTER TABLE MovementLog
ADD CONSTRAINT worker_of_movement_log FOREIGN KEY (WorkerId) REFERENCES Workers (Id);

ALTER TABLE MovementLog
ADD CONSTRAINT next_position_of_movement_log FOREIGN KEY (NextPosition) REFERENCES Positions (Id);

ALTER TABLE ActiveBonuses
ADD CONSTRAINT bonuse_of_active_bonuse FOREIGN KEY (BonuseId) REFERENCES Bonuses (Id);

ALTER TABLE ActiveBonuses
ADD CONSTRAINT worker_of_active_bonuse FOREIGN KEY (WorkerId) REFERENCES Workers (Id);


-- Загрузка данных
INSERT INTO
	Departments
VALUES
	(1, 'Отдел 1');

INSERT INTO
	Positions
VALUES
	(
		1,
		1,
		'Должность 1 с 10 доступными местами',
		10,
		50000
	);

INSERT INTO
	Workers
VALUES
	(
		1,
		'10.10.2000',
		'Мужчина',
		'1111',
		'222222',
		'Место жительства сотрудника 1',
		'899999999',
		1,
		'Сотрудник 1'
	);

INSERT INTO
	MovementLog
VALUES
	(
		1,
		1,
		1,
		'10.10.2022'
	);


INSERT INTO
	Bonuses
VALUES
	(
		1,
		'Кандидат наук',
		10
	),
	(
		2,
		'Доктор наук',
		20
	),
	(
		3,
		'Секретность 3 уровня',
		5
	),
	(
		4,
		'Секретность 2 уровня',
		10
	),
	(
		5,
		'Секретность 1 уровня',
		15
	);

INSERT INTO
	ActiveBonuses
VALUES
	(
		1,
		1,
		1
	),
	(
		2,
		4,
		1
	);

-- Задача 2

-- А)

-- Создание универсальной функции для использования в триггерах заполнения значений первичного ключа для всех таблиц
CREATE OR REPLACE FUNCTION setID() RETURNS TRIGGER AS $$
DECLARE
   max_id INT;
BEGIN
	EXECUTE 'SELECT COALESCE(MAX(id), 0) FROM ' || TG_TABLE_NAME INTO max_id;
	NEW.id := max_id + 1;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Создание триггера заполнения значений первичного ключа для таблицы departments
CREATE OR REPLACE TRIGGER setID_departments
BEFORE INSERT ON departments
FOR EACH ROW
EXECUTE FUNCTION setID();

-- Создание триггера заполнения значений первичного ключа для таблицы movementlog
CREATE OR REPLACE TRIGGER setID_movementlog
BEFORE INSERT ON movementlog
FOR EACH ROW
EXECUTE FUNCTION setID();

-- Создание триггера заполнения значений первичного ключа для таблицы positions
CREATE OR REPLACE TRIGGER setID_positions
BEFORE INSERT ON positions
FOR EACH ROW
EXECUTE FUNCTION setID();

-- Создание триггера заполнения значений первичного ключа для таблицы workers
CREATE OR REPLACE TRIGGER setID_workers
BEFORE INSERT ON workers
FOR EACH ROW
EXECUTE FUNCTION setID();

-- Б) 
-- Создание процедуры для использования в триггере проверки данных паспорта
CREATE OR REPLACE FUNCTION checkPassport() RETURNS trigger AS $$
begin
	if REGEXP_MATCH(NEW.PassportSeries, '^\d{4}$') IS NULL THEN
		RAISE 'Некорректное значение серии паспорта;';
	end if;
	if REGEXP_MATCH(NEW.PassportNumber, '^\d{6}$') IS NULL THEN
		RAISE  'Некорректное значение номера паспорта;';
	end if;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Создание триггера заполнения значений первичного ключа для таблицы workers
CREATE OR REPLACE TRIGGER checkPassport_workers
BEFORE INSERT ON workers
FOR EACH ROW
EXECUTE FUNCTION checkpassport();


-- В) Запрет удаления записей о работнике без приказа о увольнении

CREATE OR REPLACE FUNCTION checkDeleteWorker() RETURNS trigger AS
$$
declare
	MovementLogId integer;
begin
	select id into MovementLogId from MovementLog where OLD.Id = MovementLog.WorkerId AND MovementLog.NextPosition IS NULL;

	if MovementLogId IS NULL THEN
		RAISE 'Для удаления нужна запись о увольнении работника в таблице MovementLog с NextPosition=0;';
	end if;

	delete from MovementLog where OLD.Id = MovementLog.WorkerId;

	RETURN OLD;
END;
$$ 
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_checkDeleteWorker
BEFORE DELETE ON workers
FOR EACH ROW
EXECUTE FUNCTION checkDeleteWorker();

-- Задача 3

-- А) Определение является ли сотрудник юбиляром и возвращает его юбилейный возраст в этом году, если да

CREATE OR REPLACE FUNCTION anniversary_check(integer) RETURNS integer
as
$BODY$
declare
	WorkerId integer;
	Result integer;
begin
	WorkerId := $1;

 	select (date_part('year', CURRENT_DATE) - date_part('year', Workers.DateOfBirth)) 
	into Result 
	from Workers 
	where 
		WorkerId = Workers.Id 
		and 
		CAST((date_part('year', CURRENT_DATE) - date_part('year', Workers.DateOfBirth)) as INTEGER) % 10 = 0
	;

	return Result;
END;
$BODY$
LANGUAGE plpgsql;

-- Б) Определение количества прошедших лет месяцев и дней между двумя датами

CREATE OR REPLACE FUNCTION time_between (date, date) RETURNS varchar(255)
as
$BODY$
declare
	dateA date;
	dateB date;

	Result varchar(255);
begin
	dateA := $1;
	dateB := $2;

	if dateB IS NULL THEN
		dateB := CURRENT_DATE;
	end if;

 	select age(dateB, dateA) into Result;

	return Result;
END;
$BODY$
LANGUAGE plpgsql;

-- В) Получить всех юбиляров текущего года

CREATE OR REPLACE FUNCTION get_ubilars () RETURNS TABLE(id integer, fullname character varying, dateOfBirth date, age integer)
as
$BODY$
begin
	RETURN QUERY
        SELECT Workers.id, Workers.FullName, make_date(CAST(date_part('year', CURRENT_DATE) as INTEGER), CAST(extract(month from Workers.DateOfBirth) as INTEGER), CAST(extract(day from Workers.DateOfBirth) as INTEGER)), anniversary_check(Workers.id)
        FROM Workers
        WHERE anniversary_check(Workers.Id) IS NOT NULL;

END;
$BODY$
LANGUAGE plpgsql;


-- Г) Получить количество вакантных мест на должность 

CREATE OR REPLACE FUNCTION get_number_of_vacancies(integer) RETURNS integer
as
$BODY$
declare
	vacancyId integer;
	countWorkersForVacancy integer;
	numberOfPossibleWorkers integer; 
begin
	vacancyId := $1;

	select COUNT(DISTINCT Workers.id) into countWorkersForVacancy from Workers where Workers.PositionId = vacancyId;

	select Positions.NumberOfPossibleWorkers into numberOfPossibleWorkers from Positions where Positions.Id = vacancyId;

	RETURN numberOfPossibleWorkers - countWorkersForVacancy; 

END;
$BODY$
LANGUAGE plpgsql;

```
