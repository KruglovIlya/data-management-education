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


-- В)