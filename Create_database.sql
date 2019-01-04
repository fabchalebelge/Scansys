-- Crétion de la base de données

USE [master];
DROP DATABASE IF EXISTS [scansys];
CREATE DATABASE [scansys];
USE [scansys];


/*-----------------------------------------------------------------------------------------------------------*/


-- Création des tables
-- ___________________

-- Bancs de test

CREATE TABLE [Machines] (
	[id] TINYINT NOT NULL IDENTITY,
	[serial] CHAR(6) NOT NULL,
	[assy_line] CHAR(3) NOT NULL
	PRIMARY KEY ([id])
	)
;

-- Torsen

CREATE TABLE [Types] (
	[id] TINYINT NOT NULL IDENTITY,
	[type] VARCHAR(10) NOT NULL,
	PRIMARY KEY ([id])
	)
;

CREATE TABLE [Projects] (
	[id] SMALLINT NOT NULL IDENTITY,
	[project] CHAR(4) NOT NULL,
	[part_number] CHAR(12) NOT NULL,
	[type_id] TINYINT NOT NULL,
	[split_ratio] DECIMAL(9,8) NOT NULL DEFAULT 1, 
	PRIMARY KEY ([id])
	)
;

-- Programmes

CREATE TABLE [Spec_headers] (
	[id] SMALLINT NOT NULL IDENTITY,
	[project_id] SMALLINT NOT NULL,
	[suffix] VARCHAR(10),
	[issue] TINYINT NOT NULL DEFAULT 1,
	[date_time] DATETIME NOT NULL,
	[programmer] VARCHAR(50) NOT NULL,
	[max_torque] SMALLINT NOT NULL DEFAULT 700,
	[max_speed] TINYINT NOT NULL DEFAULT 50,
	[prelubrication] SMALLINT NOT NULL DEFAULT 0,
	[lubrication] SMALLINT NOT NULL DEFAULT 0,
	[drying_speed] SMALLINT NOT NULL DEFAULT 800,
	[drying_duration] SMALLINT NOT NULL DEFAULT 60,
	[trace] BIT NOT NULL DEFAULT 0,
	PRIMARY KEY ([id])
	)
;

CREATE TABLE [Vehicle_modes] (
	[id] TINYINT NOT NULL IDENTITY,
	[vehicle_mode] CHAR(14),
	PRIMARY KEY ([id])
	)
;

CREATE TABLE [Spec_modes] (
	[id] SMALLINT NOT NULL IDENTITY,
	[spec_header_id] SMALLINT NOT NULL,
	[vehicle_mode_id] TINYINT NOT NULL,
	[machine_mode] TINYINT NOT NULL,
	[min_le] DECIMAL(4,2) NOT NULL,
	[max_le] DECIMAL(4,2) NOT NULL,
	[coef_slope] DECIMAL(3,2) NOT NULL DEFAULT 1,
	[coef_offset] DECIMAL (4,3) NOT NULL DEFAULT 0,
	PRIMARY KEY ([id])
	)
;

CREATE TABLE [Spec_lines] (
	[id] INT NOT NULL IDENTITY,
	[spec_header_id] SMALLINT NOT NULL,
	[step] TINYINT NOT NULL,
	[spec_mode_id] SMALLINT NOT NULL,
	[duration] DECIMAL(4,1) NOT NULL,
	[delta_n_begin] TINYINT NOT NULL,
	[delta_n_end] TINYINT NOT NULL,
	[total_torque_begin] SMALLINT NOT NULL,
	[total_torque_end] SMALLINT NOT NULL,
	[measure] BIT NOT NULL DEFAULT 0,
	/*[sp_n_begin] DECIMAL(3,1) NOT NULL,
	[sp_n_end] DECIMAL(3,1) NOT NULL,
	[sp_torque_begin] SMALLINT NOT NULL,
	[sp_torque_end] SMALLINT NOT NULL,*/
	PRIMARY KEY ([id])
	)
;

-- Table de relation Programme-Machine
-- (on peut utiliser le même programme sur plusieurs machines)

CREATE TABLE [Machines_Spec_headers] (
	[id] INT NOT NULL IDENTITY,
	[machine_id] TINYINT NOT NULL,
	[spec_header_id] SMALLINT NOT NULL,
	[proto] BIT NOT NULL DEFAULT 0,
	[serialized] BIT NOT NULL DEFAULT 1,
	[visible] BIT NOT NULL DEFAULT 1,
	PRIMARY KEY ([id])
	)
;

-- Mesures

CREATE TABLE [Work_orders] (
	[id] INT NOT NULL IDENTITY,
	[machine_spec_header_id] INT NOT NULL,
	[work_order] VARCHAR(50) NOT NULL,
	[date_time] DATETIME NOT NULL,
	[worker] VARCHAR(255) NOT NULL,
	PRIMARY KEY ([id])
	)
;

CREATE TABLE [Parts] (
	[id] INT NOT NULL IDENTITY,
	[work_order_id] INT NOT NULL,
	[date_time] DATETIME NOT NULL,
	[serial] VARCHAR(50),
	[valid] BIT NOT NULL,
	PRIMARY KEY ([id])
	)
;

CREATE TABLE [Part_modes] (
	[id] BIGINT NOT NULL IDENTITY,
	[part_id] INT NOT NULL,
	[spec_mode_id] SMALLINT NOT NULL,
	[valid] BIT NOT NULL,
	[avg_top_torque] DECIMAL(18,14),
	[stdev_top_torque] DECIMAL(6,3),
	[avg_bot_torque] DECIMAL(18,14),
	[stdev_bot_torque] DECIMAL(6,3),
	[avg_fix_torque] DECIMAL(18,14),
	[stdev_fix_torque] DECIMAL(6,3),
	[avg_le] DECIMAL(9,6) NOT NULL,
	[stdev_le] DECIMAL(9,6) NOT NULL,
	PRIMARY KEY ([id])
	)
;

 
/*-----------------------------------------------------------------------------------------------------------*/


-- Création des index
-- __________________

CREATE UNIQUE INDEX ind_Machines_serial ON [Machines]([serial]);
CREATE INDEX ind_Machines_assy_line ON [Machines]([assy_line]);
CREATE UNIQUE INDEX ind_Types_type ON [Types]([type]);
CREATE INDEX ind_Projects_project ON [Projects]([project]);
CREATE UNIQUE INDEX ind_Projects_part_number ON [Projects]([part_number]);
CREATE UNIQUE INDEX ind_Spec_headers_mach_proj_suff_iss ON [Spec_headers]([project_id],[suffix],[issue]);
CREATE UNIQUE INDEX ind_Vehicle_modes_vehicle_mode ON [Vehicle_modes]([vehicle_mode]);
CREATE UNIQUE INDEX ind_Spec_modes_vehicle_mode_id ON [Spec_modes]([spec_header_id],[vehicle_mode_id]);
CREATE UNIQUE INDEX ind_Spec_modes_machine_mode ON [Spec_modes]([spec_header_id],[machine_mode]);
CREATE UNIQUE INDEX ind_Spec_lines_spec_header_step ON [Spec_lines]([spec_header_id],[step]);
-- CREATE UNIQUE INDEX ind_Spec_lines_spec_header_spec_mode ON [Spec_lines]([spec_header_id],[spec_mode_id]);
CREATE UNIQUE INDEX ind_Machines_Spec_headers_machine_spec_header_proto ON [Machines_Spec_headers]([machine_id],[spec_header_id],[proto]);
CREATE UNIQUE INDEX ind_Work_orders_work_order ON [Work_orders]([work_order]);


/*-----------------------------------------------------------------------------------------------------------*/


-- Création des clés étrangères
-- ____________________________

ALTER TABLE [Projects]
	ADD CONSTRAINT fk_Projects_type_id FOREIGN KEY ([type_id])
		REFERENCES [Types]([id])
		ON DELETE NO ACTION
		ON UPDATE CASCADE
;

ALTER TABLE [Spec_headers]
	ADD CONSTRAINT fk_Spec_headers_project_id FOREIGN KEY ([project_id])
		REFERENCES [Projects]([id])
		ON DELETE NO ACTION
		ON UPDATE CASCADE
;

ALTER TABLE [Machines_Spec_headers]
	ADD CONSTRAINT fk_Machines_Spec_headers_machine_id FOREIGN KEY ([machine_id])
		REFERENCES [Machines]([id])
		ON DELETE NO ACTION
		ON UPDATE CASCADE
;

ALTER TABLE [Machines_Spec_headers]
	ADD CONSTRAINT fk_Machines_Spec_headers_spec_header_id FOREIGN KEY ([spec_header_id])
		REFERENCES [Spec_headers]([id])
		ON DELETE NO ACTION
		ON UPDATE CASCADE
;

ALTER TABLE [Spec_modes]
	ADD CONSTRAINT fk_Spec_modes_vehicle_mode_id FOREIGN KEY ([vehicle_mode_id])
		REFERENCES [Vehicle_modes]([id])
		ON DELETE NO ACTION
		ON UPDATE CASCADE
;

ALTER TABLE [Spec_lines]
	ADD CONSTRAINT fk_Spec_lines_spec_header_id FOREIGN KEY ([spec_header_id])
		REFERENCES [Spec_headers]([id])
		ON DELETE NO ACTION
		ON UPDATE CASCADE
;

ALTER TABLE [Spec_lines]
	ADD CONSTRAINT fk_Spec_lines_spec_mode_id FOREIGN KEY ([spec_mode_id])
		REFERENCES [Spec_modes]([id])
		ON DELETE NO ACTION
		ON UPDATE CASCADE
;

ALTER TABLE [Work_orders]
	ADD CONSTRAINT fk_Work_orders_machine_spec_header_id FOREIGN KEY ([machine_spec_header_id])
		REFERENCES [Machines_Spec_headers]([id])
		ON DELETE NO ACTION
		ON UPDATE CASCADE
;

ALTER TABLE [Parts]
	ADD CONSTRAINT fk_Parts_work_order_id FOREIGN KEY ([work_order_id])
		REFERENCES [Work_orders]([id])
		ON DELETE NO ACTION
		ON UPDATE CASCADE
;

ALTER TABLE [Part_modes]
	ADD CONSTRAINT fk_Part_modes_part_id FOREIGN KEY ([part_id])
		REFERENCES [Parts]([id])
		ON DELETE NO ACTION
		ON UPDATE CASCADE
;

ALTER TABLE [Part_modes]
	ADD CONSTRAINT fk_Part_modes_spec_mode_id FOREIGN KEY ([spec_mode_id])
		REFERENCES [Spec_modes]([id])
		ON DELETE NO ACTION
		ON UPDATE CASCADE
;



/*-----------------------------------------------------------------------------------------------------------*/


-- Création des procédures stockées
-- ________________________________



/*-----------------------------------------------------------------------------------------------------------*/


-- Remplissage des tables
-- ______________________

INSERT INTO [Machines]([serial],[assy_line]) VALUES
	('J22222','AS2'),
	('J33333','AS3'),
	('J44444','AS4'),
	('J55555','AS5')
;

INSERT INTO [Types] VALUES
	('Type A'),
	('Type B'),
	('Type C'),
	('Twin diff')
;

INSERT INTO [Projects] ([project],[part_number],[type_id],[split_ratio]) VALUES
	('EA10','409001-0030A',1,1),
	('EA28','409001-0130A',3,1.5),
	('EA33','409001-0190A',3,1.5),
	('EA43','409001-0270A',3,36/CONVERT(DECIMAL,26)),
	('EA44','409001-0280A',3,26/CONVERT(DECIMAL,36)),
	('EA44','409001-0290A',3,26/CONVERT(DECIMAL,36)),
	('EA49','409001-0330A',3,36/CONVERT(DECIMAL,26)),
	('EA49','409001-0330B',3,36/CONVERT(DECIMAL,26)),
	('EA49','409001-0340A',3,36/CONVERT(DECIMAL,26)),
	('EA51','409000-2800A',3,36/CONVERT(DECIMAL,26)),
	('EC01','409300-0997A',1,1),
	('EC03','409001-8050A',1,1),
	('EG07','409001-8030A',2,1),
	('EQ06','409001-8180A',2,1),
	('ER07','409001-8190A',3,36/CONVERT(DECIMAL,26)),
	('EY05','409001-8200A',2,1),
	('EY06','409001-8210A',2,1)
;

INSERT INTO [Vehicle_modes] VALUES
	('Drive to Front'),
	('Coast to Front'),
	('Drive to Rear'),
	('Coast to Rear'),
	('Drive to Right'),
	('Coast to Right'),
	('Drive to Left'),
	('Coast to Left')
;

-- Quelques programmes pour l'exemple

INSERT INTO [Spec_headers] VALUES
	-- EA43
	(4,NULL,1,GETDATE(),'fabcha',700,50,0,0,800,200,0)
;

INSERT INTO [Spec_modes] VALUES
	-- EA43
	(1,1,2,33.33,42.36,1,0),
	(1,4,3,32.75,26.47,1,0)
;

INSERT INTO [Spec_lines] VALUES
	-- EA43
	(1,1,1,1,0,0,0,0,0),
	(1,2,1,1,0,20,0,50,0),
	(1,3,1,5,20,20,50,50,0),
	(1,4,1,1,20,50,50,50,0),
	(1,5,1,5,50,50,50,500,0),
	(1,6,1,10,50,50,500,500,0),
	(1,7,1,1,50,20,500,500,0),
	(1,8,1,5,20,20,500,500,1),
	(1,9,1,1,20,0,500,0,0),
	(1,10,2,1,0,0,0,0,0),
	(1,11,2,1,0,50,0,0,0),
	(1,12,2,5,50,50,0,500,0),
	(1,13,2,10,50,50,500,500,0),
	(1,14,2,1,50,20,500,500,0),
	(1,15,2,5,20,20,500,500,1),
	(1,16,2,1,20,0,500,0,0)
;