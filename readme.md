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
-- Создание таблиц
CREATE TABLE
	Departments (
		Id SERIAL,
		Title VARCHAR(20) NOT NULL,
		CONSTRAINT department_Id PRIMARY KEY (Id)
	);

CREATE TABLE
	Positions (
		Id SERIAL,
		DepartmentId INTEGER,
		Title VARCHAR(20) NOT NULL,
		NumberOfPossibleWorkers INTEGER,
		Salary MONEY NOT NULL,
		CONSTRAINT position_Id PRIMARY KEY (Id)
	);

CREATE TABLE
	Workers (
		Id SERIAL,
		PositionId INTEGER NOT NULL,
		DateOfBirth DATE NOT NULL,
		Gender VARCHAR(20) NOT NULL,
		Passport VARCHAR(20) NOT NULL,
		Address VARCHAR(255) NOT NULL,
		Phone VARCHAR(20) NOT NULL,
		CONSTRAINT worker_Id PRIMARY KEY (Id),
		UNIQUE (Passport, Phone)
	);

CREATE TABLE
	MovementLog (
		Id SERIAL,
		WorkerId INTEGER NOT NULL,
		NextPosition INTEGER NOT NULL,
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

```
