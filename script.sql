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
