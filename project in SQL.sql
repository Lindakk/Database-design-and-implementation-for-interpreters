DROP TABLE Address;
DROP TABLE Interperter;
DROP TABLE FULL_TIME;
DROP TABLE PART_TIME;
DROP TABLE Temporary;
DROP TABLE Language;
DROP TABLE Speaks;
DROP TABLE Account;
DROP TABLE Call;
DROP TABLE Client;
DROP TABLE Service;
DROP TABLE Department;
DROP TABLE Communicates;
DROP TABLE Mentor;
DROP TABLE Training;
DROP TABLE Participation;
DROP TABLE Paychange;

DROP SEQUENCE interpreter_seq;
DROP SEQUENCE client_seq;
DROP SEQUENCE aadress_seq;
DROP SEQUENCE call_seq;
DROP SEQUENCE training_seq;
DROP SEQUENCE account_seq;
DROP SEQUENCE language_seq;
DROP SEQUENCE mentor_seq;
DROP SEQUENCE department_seq;
DROP SEQUENCE Pay_change_seq;

DROP PROCEDURE AddFulltimeInterpreter;
DROP PROCEDURE AddParttimeInterpreter;
DROP PROCEDURE AddTemporaryInterpreter;
DROP PROCEDURE AddClient;
DROP PROCEDURE AddDepartment;
DROP PROCEDURE AddMentor;
DROP PROCEDURE AddTraining;
DROP PROCEDURE AddAccount;
DROP PROCEDURE AddCall;

--TABLES
CREATE TABLE Address (
			address_id DECIMAL(12) PRIMARY KEY,
			street VARCHAR (255),
			city VARCHAR (255),
			state VARCHAR (255),
			post_code VARCHAR (65));



CREATE TABLE Interpreter (
			interpreter_id DECIMAL(5) PRIMARY KEY,
			first_name VARCHAR (100)  NOT NULL,
			last_name VARCHAR (100)  NOT NULL,
			work_status CHAR (1)  NOT NULL,
			email_address VARCHAR (255)  NOT NULL,
			phone_number DECIMAL(20)  NOT NULL,
			address_id DECIMAL(12),  
			time_zone VARCHAR (50)  NOT NULL,
			FOREIGN KEY (address_id) REFERENCES Address);

CREATE TABLE FULL_TIME(
			interpreter_id DECIMAL(5) PRIMARY KEY,
			first_name VARCHAR (100)  NOT NULL,
			last_name VARCHAR (100)  NOT NULL,
			start_date DATE NOT NULL,
			monthly_salary DECIMAL (5) NOT NULL,
			FOREIGN KEY (interpreter_id) REFERENCES Interpreter);

CREATE TABLE PART_TIME(
			interpreter_id DECIMAL(5) PRIMARY KEY,
			first_name VARCHAR (100)  NOT NULL,
			last_name VARCHAR (100)  NOT NULL,
			start_date DATE NOT NULL,
			hourly_rate DECIMAL (4) NOT NULL,
			FOREIGN KEY (interpreter_id) REFERENCES Interpreter);

CREATE TABLE Temporary(
			interpreter_id DECIMAL(5) PRIMARY KEY,
			first_name VARCHAR (100)  NOT NULL,
			last_name VARCHAR (100)  NOT NULL,
			start_date DATE NOT NULL,
			end_date DATE NOT NULL,
			hourly_rate DECIMAL (4) NOT NULL,
			FOREIGN KEY (interpreter_id) REFERENCES Interpreter);

CREATE TABLE Language (
			language_id DECIMAL(4) PRIMARY KEY,
			language_name VARCHAR (255) NOT NULL);

CREATE TABLE Speaks (
			interpreter_id DECIMAL (5) NOT NULL,
			language_id DECIMAL(4) NOT NULL,
			FOREIGN KEY (interpreter_id) REFERENCES Interpreter,
			FOREIGN KEY (language_id) REFERENCES Language);


CREATE TABLE Account(
			account_id DECIMAL (5) PRIMARY KEY,
			interpreter_id DECIMAL (5) NOT NULL,
			password VARCHAR (20) NOT NULL,
			status VARCHAR (8) NOT NULL,
			FOREIGN KEY (interpreter_id) REFERENCES Interpreter(interpreter_id));
			drop table call;
			CREATE TABLE Call (
			call_id DECIMAL(10) PRIMARY KEY,
			interpreter_id DECIMAL(5) NOT NULL,
			account_id DECIMAL (5) NOT NULL,
			client_id DECIMAL (5) NOT NULL,
			call_type CHAR(3) NOT NULL,
			call_date DATE NOT NULL,
			start_time VARCHAR(10) NOT NULL,
			end_time VARCHAR(10) NOT NULL,
			work_duration DECIMAL (4,2) NOT NULL,
			call_description VARCHAR (500) NOT NULL,
			FOREIGN KEY (interpreter_id) REFERENCES Interpreter(interpreter_id),
			FOREIGN KEY (call_id) REFERENCES Call (call_id),
			FOREIGN KEY (account_id) REFERENCES Account(account_id),
			FOREIGN KEY (client_id) REFERENCES Client(client_id));

CREATE TABLE Client (
			client_id DECIMAL(5) PRIMARY KEY,
			client_name VARCHAR (100) NOT NULL,
			client_phone DECIMAL (20),
			address_id DECIMAL(12),
			FOREIGN KEY (address_id) REFERENCES Address);


CREATE TABLE Service(
			interpreter_id DECIMAL (5) NOT NULL,
			client_id DECIMAL (5) NOT NULL,
			FOREIGN KEY(interpreter_id) REFERENCES Interpreter (interpreter_id),
			FOREIGN KEY(client_id) REFERENCES Client (client_id));


CREATE TABLE Department (
			department_id DECIMAL (5) PRIMARY KEY,
			department_name VARCHAR (50) NOT NULL,
			email_address VARCHAR (255) NOT NULL,
			phone_number DECIMAL (20) NOT NULL,
			contact_personnel VARCHAR (255) NOT NULL);

CREATE TABLE Communicates (
			interpreter_id  DECIMAL(5) NOT NULL,
			department_id DECIMAL(5) NOT NULL,
			FOREIGN KEY(interpreter_id) REFERENCES Interpreter (interpreter_id),
			FOREIGN KEY(department_id) REFERENCES Department (department_id));

CREATE TABLE Mentor (
			mentor_id DECIMAL (5) PRIMARY KEY,
			first_name VARCHAR (100) NOT NULL,
			last_name VARCHAR(100) NOT NULL);

CREATE TABLE Training (
			training_id DECIMAL (7) PRIMARY KEY,
			description VARCHAR (1000) NOT NULL,
			available_date DATE NOT NULL,
			completion_date DATE NOT NULL,
			training_status VARCHAR(15) NOT NULL,
			mentor_id DECIMAL (5),
			FOREIGN KEY(mentor_id) REFERENCES Mentor (mentor_id));

CREATE TABLE PARTICIPATION (
			interpreter_id DECIMAL (5) NOT NULL,
			training_id DECIMAL (7) NOT NULL,
			FOREIGN KEY(interpreter_id) REFERENCES Interpreter (interpreter_id),
			FOREIGN KEY (training_id) REFERENCES Training(training_id));

CREATE TABLE Paychange (
			pay_change_id DECIMAL (5) PRIMARY KEY,
			old_pay DECIMAL(5) NOT NULL,
			new_pay DECIMAL(5) NOT NULL,
			interpreter_id DECIMAL (5) NOT NULL,
			change_date DATE,
			FOREIGN KEY (interpreter_id) REFERENCES Interpreter(interpreter_id));


--SEQUENCES
CREATE SEQUENCE interpreter_seq START WITH 1;
CREATE SEQUENCE client_seq START WITH 1;
CREATE SEQUENCE address_seq START WITH 1;
CREATE SEQUENCE call_seq START WITH 1;
CREATE SEQUENCE training_seq START WITH 1;
CREATE SEQUENCE account_seq START WITH 1;
CREATE SEQUENCE language_seq START WITH 1;
CREATE SEQUENCE mentor_seq START WITH 1;
CREATE SEQUENCE department_seq START WITH 1;
CREATE SEQUENCE Paychange_seq START WITH 1;


--HISTORY TRIGGER
-- Trigger for temporary interpreters
CREATE OR ALTER TRIGGER pay_change_trg_t
on Temporary
AFTER UPDATE
AS
BEGIN
  DECLARE @old_pay DECIMAL(5)=(SELECT hourly_rate FROM DELETED);
  DECLARE @new_pay DECIMAL (5)=(SELECT hourly_rate FROM INSERTED);

  IF (@old_pay<>@new_pay)
     INSERT INTO Paychange (pay_change_id, old_pay, new_pay, interpreter_id, change_date)
     VALUES(NEXT VALUE FOR Paychange_seq, @old_pay, @new_pay, (SELECT interpreter_id FROM INSERTED), GETDATE());
END;

----Trigger for part time interpreters
CREATE OR ALTER TRIGGER pay_change_trg_p
on PART_TIME
AFTER UPDATE
AS
BEGIN
  DECLARE @old_pay DECIMAL(5)=(SELECT hourly_rate FROM DELETED);
  DECLARE @new_pay DECIMAL (5)=(SELECT hourly_rate FROM INSERTED);

  IF (@old_pay<>@new_pay)
     INSERT INTO Paychange (pay_change_id, old_pay, new_pay, interpreter_id, change_date)
     VALUES(NEXT VALUE FOR Paychange_seq, @old_pay, @new_pay, (SELECT interpreter_id FROM INSERTED), GETDATE());
END;

----Trigger for full time interpreters
CREATE OR ALTER TRIGGER pay_change_trg_f
on FULL_TIME
AFTER UPDATE
AS
BEGIN
  DECLARE @old_pay DECIMAL(5)=(SELECT monthly_salary FROM DELETED);
  DECLARE @new_pay DECIMAL (5)=(SELECT monthly_salary FROM INSERTED);

  IF (@old_pay<>@new_pay)
     INSERT INTO Paychange (pay_change_id, old_pay, new_pay, interpreter_id, change_date)
     VALUES(NEXT VALUE FOR Paychange_seq, @old_pay, @new_pay, (SELECT interpreter_id FROM INSERTED), GETDATE());
END;

--INDEXES
CREATE UNIQUE INDEX AccountInterpreterIdx
	ON Account(interpreter_id);

CREATE INDEX CallInterpreterIdx
	ON Call(interpreter_id);

CREATE INDEX CallClientIdx
	ON Call(client_id);

CREATE INDEX CallAccountIdx
	ON Call (account_id);

CREATE INDEX InterpreterAddressIdx
	ON Interpreter (address_id);

CREATE UNIQUE INDEX ClientAddressIdx
	ON Client (address_id);

CREATE INDEX ServiceInterpreterIdx
	ON Service(interpreter_id);

CREATE INDEX ServiceClientIdx
	ON Service(client_id);

CREATE INDEX SpeaksInterpreterIdx
	ON Speaks(interpreter_id);

CREATE INDEX SpeaksLanguageIdx
	ON Speaks(Language_id);

CREATE INDEX CommunicatesInterpreterIdx
	ON Communicates(interpreter_id);

CREATE INDEX CommunicatesDepartmentIdx
	ON Communicates(department_id);

CREATE INDEX ParticipationInterpreterIdx
	ON Participation(interpreter_id);

CREATE INDEX ParticipationTrainingIdx
	ON Participation(training_id);

CREATE INDEX TrainingMentorIdx
	ON Training(mentor_id);

CREATE INDEX PaychangeInterpreterIdx
	ON Paychange (interpreter_id);

CREATE INDEX CallDateIdx
	ON CALL (call_date);

CREATE INDEX TrainingAvailableDateIdx
	ON Training (available_date);

CREATE INDEX ClientNameIdx
	ON Client (client_name);


------ Create stored procedure AddFulltimeInterpreter and add information in the Full-time, Interpreter and address tables.
CREATE PROCEDURE AddFulltimeInterpreter 
		@first_name VARCHAR (100) ,
		@last_name VARCHAR (100) ,
		@email_address VARCHAR (255),
		@phone_number DECIMAL(20) , 
		@time_zone VARCHAR (50),
		@start_date DATE,
		@monthly_salary DECIMAL(5),
		@street VARCHAR (255),
		@city VARCHAR (255),
		@state VARCHAR (255),
		@post_code VARCHAR (65)
AS
BEGIN
DECLARE @current_interpreter_id INT = NEXT VALUE FOR interpreter_seq; 
DECLARE @current_address_id INT = NEXT VALUE FOR address_seq;
INSERT INTO Address (address_id,street, city, state, post_code)
VALUES ( @current_address_id,@street, @city, @state, @post_code);

INSERT INTO Interpreter(interpreter_id,first_name, last_name,
			work_status, email_address, phone_number,
		    address_id, time_zone)
VALUES (@current_interpreter_id,@first_name, @last_name,
		'F', @email_address, @phone_number,
	    @current_address_id,@time_zone);
INSERT INTO Full_time (interpreter_id,first_name, last_name,start_date,monthly_salary)
VALUES (@current_interpreter_id,@first_name, @last_name,@start_date,@monthly_salary)
END;


BEGIN TRANSACTION AddFulltimeInterpreter;
EXECUTE AddFulltimeInterpreter 'Alex','Johnson', 'alej@gmail.com', 6176541234,'EST', '10/12/2016', 5000,
'1356 Harrison Blvd','Overland', 'KS', '66589';
COMMIT TRANSACTION AddFulltimeInterpreter;

BEGIN TRANSACTION AddFulltimeInterpreter;
EXECUTE AddFulltimeInterpreter 'Preston','Decker', 'prdek@gmail.com', 123456789,'EST', '10/12/2017', 5000,
'119 Grant Ave','Boise', 'ID', '83724';
COMMIT TRANSACTION AddFulltimeInterpreter;

BEGIN TRANSACTION AddFulltimeInterpreter;
EXECUTE AddFulltimeInterpreter 'Linda','Li', 'lindali@gmail.com', 61276783415,'CST', '06/01/2016', 5000,
'345 Nineth Street','Boise', 'ID', '83702';
COMMIT TRANSACTION AddFulltimeInterpreter ;

BEGIN TRANSACTION AddFulltimeInterpreter;
EXECUTE AddFulltimeInterpreter  'Eric','Park', 'erpk@gmail.com',817456123,'PST', '10/12/2019', 4000,
'13 North Street','Lawrence', 'KS', '66044';
COMMIT TRANSACTION AddFulltimeInterpreter ;

BEGIN TRANSACTION AddFulltimeInterpreter;
EXECUTE AddFulltimeInterpreter  'Tom','Tang', 'tomt@gmail.com', 1314568524,'EST', '01/12/2010', 6000,
'2089 Allison Street','Seatle', 'WA', '654789';
COMMIT TRANSACTION AddFulltimeInterpreter ;

BEGIN TRANSACTION AddFulltimeInterpreter;
EXECUTE AddFulltimeInterpreter  'Amy','Agnew', 'amg@gmail.com', 7891452634,'EST', '10/12/2016', 5000,
'1002 Wakarusa Blvd','Wrenthem', 'MA', '024475';
COMMIT TRANSACTION AddFulltimeInterpreter ;

BEGIN TRANSACTION AddFulltimeInterpreter;
EXECUTE AddFulltimeInterpreter   'Mary','Post', 'marp@gmail.com', 6548247894, 'EST', '11/20/2009', 7000, 
'123 South Street','Waltham', 'MA', '025481';
COMMIT TRANSACTION AddFulltimeInterpreter ;

BEGIN TRANSACTION AddFulltimeInterpreter;
EXECUTE AddFulltimeInterpreter   'Hal','Johnson', 'halj@gmail.com', 4587564213,'PST', '10/06/2016', 5000, 
'12 Adam Ave','Boston', 'MA', '02485';
COMMIT TRANSACTION AddFulltimeInterpreter ;

BEGIN TRANSACTION AddFulltimeInterpreter;
EXECUTE AddFulltimeInterpreter   'Sam','Polose', 'samp@gmail.com', 8574041254,'EST', '10/10/2016', 5000, 
'211 Fifth Street','Flushing', 'NY', '11220';
COMMIT TRANSACTION AddFulltimeInterpreter ;

BEGIN TRANSACTION AddFulltimeInterpreter;
EXECUTE AddFulltimeInterpreter   'Kate','Zhang', 'kaz@gmail.com', 7547651234,'CST', '10/12/2020', 3000, 
'89 Western DR','Boston', 'MA', '061254';
COMMIT TRANSACTION AddFulltimeInterpreter ;


----------Create stored procedure AddParttimeInterpreter and add information in the Part-time, Interpreter and Address tables.
CREATE PROCEDURE AddParttimeInterpreter 
		@first_name VARCHAR (100) ,
		@last_name VARCHAR (100) ,
		@email_address VARCHAR (255),
		@phone_number DECIMAL(20) , 
		@time_zone VARCHAR (50),
		@start_date DATE,
		@hourly_rate DECIMAL(5),
		@street VARCHAR (255),
		@city VARCHAR (255),
		@state VARCHAR (255),
		@post_code VARCHAR (65)
AS
BEGIN
DECLARE @current_interpreter_id INT = NEXT VALUE FOR interpreter_seq; 
DECLARE @current_address_id INT = NEXT VALUE FOR address_seq;
INSERT INTO Address (address_id,street, city, state, post_code)
VALUES ( @current_address_id,@street, @city, @state, @post_code);

INSERT INTO Interpreter(interpreter_id,first_name, last_name,
			work_status, email_address, phone_number,
		    address_id, time_zone)
VALUES (@current_interpreter_id,@first_name, @last_name,
		'P', @email_address, @phone_number,
	    @current_address_id,@time_zone);
INSERT INTO Part_time (interpreter_id,first_name, last_name,start_date,hourly_rate)
VALUES (@current_interpreter_id,@first_name, @last_name,@start_date,@hourly_rate)
END;

BEGIN TRANSACTION AddParttimeInterpreter;
EXECUTE AddParttimeInterpreter   'Wanwan','Huang', 'wanh@gmail.com', 6548248542, 'EST', '11/20/2010', 30, 
'111 South Street','Huthsin', 'KS', '65423';
COMMIT TRANSACTION AddParttimeInterpreter ;

BEGIN TRANSACTION AddParttimeInterpreter;
EXECUTE AddParttimeInterpreter   'Vivian','Smith', 'vism@gmail.com', 3214567895, 'CST', '11/20/2010', 30, 
'18 South Ave','Burlinton', 'VT', '785423';
COMMIT TRANSACTION AddParttimeInterpreter ;

BEGIN TRANSACTION AddParttimeInterpreter;
EXECUTE AddParttimeInterpreter   'Shawn','Smith', 'sssm@gmail.com', 5687954632 ,'EST', '09/20/2010', 30, 
'1011 W Sixth Street','Burlinton', 'VT', '785423';
COMMIT TRANSACTION AddParttimeInterpreter ;


----------------Create stored procedure AddTemporaryInterpreter and add information in the Part-time, Interpreter and Address tables.

CREATE PROCEDURE AddTemporaryInterpreter 
		@first_name VARCHAR (100) ,
		@last_name VARCHAR (100) ,
		@email_address VARCHAR (255),
		@phone_number DECIMAL(20) , 
		@time_zone VARCHAR (50),
		@start_date DATE,
		@end_date DATE,
		@hourly_rate DECIMAL(5),
		@street VARCHAR (255),
		@city VARCHAR (255),
		@state VARCHAR (255),
		@post_code VARCHAR (65)
AS
BEGIN
DECLARE @current_interpreter_id INT = NEXT VALUE FOR interpreter_seq; 
DECLARE @current_address_id INT = NEXT VALUE FOR address_seq;
INSERT INTO Address (address_id,street, city, state, post_code)
VALUES ( @current_address_id,@street, @city, @state, @post_code);

INSERT INTO Interpreter(interpreter_id,first_name, last_name,
			work_status, email_address, phone_number,
		    address_id, time_zone)
VALUES (@current_interpreter_id,@first_name, @last_name,
		'T', @email_address, @phone_number,
	    @current_address_id,@time_zone);
INSERT INTO Temporary (interpreter_id,first_name, last_name,start_date, end_date,hourly_rate)
VALUES (@current_interpreter_id,@first_name, @last_name,@start_date,@end_date,@hourly_rate)
END;

BEGIN TRANSACTION AddTemporaryInterpreter;
EXECUTE AddTemporaryInterpreter   'Shuan','Song', 'shuansm@gmail.com', 1234567855, 'CST', '11/20/2016', '01/20/2017', 30, 
'198 South Ave','Lawrence', 'KS', '66044';
COMMIT TRANSACTION AddTemporaryInterpreter ;

BEGIN TRANSACTION AddTemporaryInterpreter;
EXECUTE AddTemporaryInterpreter   'Juan','Archi', 'juanar@gmail.com', 6575864569, 'EST', '11/20/2017', '01/20/2018', 30, 
'890 Adams Ave','Newton', 'MA', '02569';
COMMIT TRANSACTION AddTemporaryInterpreter ;

BEGIN TRANSACTION AddTemporaryInterpreter;
EXECUTE AddTemporaryInterpreter   'James','Luis', 'jlui@gmail.com', 6324567895, 'EST', '11/20/2018', '01/20/2019', 30, 
'222 York Rd','Boston', 'MA', '02563';
COMMIT TRANSACTION AddTemporaryInterpreter;

BEGIN TRANSACTION AddTemporaryInterpreter;
EXECUTE AddTemporaryInterpreter   'Lucca','Smith', 'lush@gmail.com', 4562311234, 'EST', '11/20/2018', '01/20/2019', 30, 
'202 Second Rd','Newton', 'MA', '025603';
COMMIT TRANSACTION AddTemporaryInterpreter;

------Create stored procedure AddClient and add information in the Client table.

CREATE PROCEDURE  AddClient
				@client_name VARCHAR (100), 
				@client_phone DECIMAL (20),
				@street VARCHAR (255),
				@city VARCHAR (255),
				@state VARCHAR (255),
				@post_code VARCHAR (65)

AS
BEGIN
DECLARE @current_client_id INT = NEXT VALUE FOR client_seq;
DECLARE @current_address_id INT = NEXT VALUE FOR address_seq;
INSERT INTO Address (address_id,street, city, state, post_code)
VALUES ( @current_address_id,@street, @city, @state, @post_code);
INSERT INTO Client (client_id,client_name, client_phone, address_id)
VALUES (@current_client_id,@client_name, @client_phone, @current_address_id);
END;
		
BEGIN TRANSACTION AddClient ;
EXECUTE AddClient  'VNC',6145467896, 'XXX','Boston','MA',123456;
COMMIT TRANSACTION AddClient ;

BEGIN TRANSACTION AddClient ;
EXECUTE AddClient  'ABF',2534789654, 'XXX','Seatle','WA',158945;
COMMIT TRANSACTION AddClient ;

BEGIN TRANSACTION AddClient ;
EXECUTE AddClient  'AB BANK',8524161234, '123 North Street','Boston','MA',123456;
COMMIT TRANSACTION AddClient ;

BEGIN TRANSACTION AddClient ;
EXECUTE AddClient  'BNV',1234587544, '12 Sixth Road','Boston','MA',123456;
COMMIT TRANSACTION AddClient ;

BEGIN TRANSACTION AddClient ;
EXECUTE AddClient  'ST Insurance',8882511234, '123 Fourth Street','Boston','MA',123456;
COMMIT TRANSACTION AddClient ;

BEGIN TRANSACTION AddClient ;
EXECUTE AddClient  'NY Hospital',5461234561, 'Seventh Road','New York','NY',11220;
COMMIT TRANSACTION AddClient ;

BEGIN TRANSACTION AddClient ;
EXECUTE AddClient  'ABC School',0106541234789, 'West Street','Beijing','Beijing',010010;
COMMIT TRANSACTION AddClient ;

BEGIN TRANSACTION AddClient ;
EXECUTE AddClient  'Ali Trading',1122134567412, 'Huaxi Street','Shanghai','SH',201132;
COMMIT TRANSACTION AddClient ;


BEGIN TRANSACTION AddClient ;
EXECUTE AddClient  'West School District',6174521234, 'Adams Street','Boston','MA',123456;
COMMIT TRANSACTION AddClient ;

BEGIN TRANSACTION AddClient ;
EXECUTE AddClient  'Macys',2413214563, 'Biship Street','New York','NY',123456;
COMMIT TRANSACTION AddClient ;

SELECT * FROM CLIENT;
SELECT * FROM ADDRESS;



--------Create stored procedure AddDepartment and add information in the Department table.

CREATE PROCEDURE AddDepartment
		@department_name VARCHAR (50),
		@email_address VARCHAR (255) ,
		@phone_number DECIMAL (20),
		@contact_personnel VARCHAR (255)
AS
BEGIN

INSERT INTO Department (department_id, department_name, email_address, phone_number, contact_personnel)
VALUES (NEXT VALUE FOR department_seq,@department_name, @email_address, @phone_number, @contact_personnel);
END;

BEGIN TRANSACTION AddDepartment;
EXECUTE AddDepartment 'Human Resource', 'hr@lls.com', 6511112321,'Preston Leeway';
COMMIT TRANSACTION AddDepartment;

BEGIN TRANSACTION AddDepartment;
EXECUTE AddDepartment 'Research and Development', 'rd@lls.com', 6511114321,'Adam Yang';
COMMIT TRANSACTION AddDepartment;

BEGIN TRANSACTION AddDepartment;
EXECUTE AddDepartment 'Marketing', 'marketing@lls.com', 6511116541,'Lilian Woods';
COMMIT TRANSACTION AddDepartment;

BEGIN TRANSACTION AddDepartment;
EXECUTE AddDepartment 'Accounting', 'accounting@lls.com', 6511117896,'Bill Smith';
COMMIT TRANSACTION AddDepartment;

BEGIN TRANSACTION AddDepartment;
EXECUTE AddDepartment 'Purchasing', 'purchasing@lls.com', 6511118521,'Sara Park';
COMMIT TRANSACTION AddDepartment;

BEGIN TRANSACTION AddDepartment;
EXECUTE AddDepartment 'IT', 'IT@lls.com', 6511113654,'Linda Shea';
COMMIT TRANSACTION AddDepartment;

BEGIN TRANSACTION AddDepartment;
EXECUTE AddDepartment 'Operation', 'operation@lls.com', 6511117852,'Ryan Becker';
COMMIT TRANSACTION AddDepartment;

BEGIN TRANSACTION AddDepartment;
EXECUTE AddDepartment 'Finance', 'finance@lls.com', 6511118521,'Semantha Whittings';
COMMIT TRANSACTION AddDepartment;

BEGIN TRANSACTION AddDepartment;
EXECUTE AddDepartment 'Product and Service', 'prnser@lls.com', 6511118523,'Marisa Post';
COMMIT TRANSACTION AddDepartment;

BEGIN TRANSACTION AddDepartment;
EXECUTE AddDepartment 'Maintenance', 'maintenance@lls.com', 6511111254,'Katie Biers';
COMMIT TRANSACTION AddDepartment;



------- Create stored procedure AddMentor and add information in the Mentor table.
CREATE PROCEDURE AddMentor
		@first_name VARCHAR (100),
		@last_name VARCHAR (100)
AS
BEGIN
INSERT INTO Mentor (mentor_id, first_name,last_name)
VALUES (NEXT VALUE FOR mentor_seq, @first_name, @last_name);
END;

BEGIN TRANSACTION AddMentor;
EXECUTE AddMentor 'Xiaoying', 'Wang';
COMMIT TRANSACTION AddMentor;

BEGIN TRANSACTION AddMentor;
EXECUTE AddMentor 'Wei', 'Lee';
COMMIT TRANSACTION AddMentor;
Select* from Mentor;

BEGIN TRANSACTION AddMentor;
EXECUTE AddMentor 'Amanda', 'Smith';
COMMIT TRANSACTION AddMentor;

BEGIN TRANSACTION AddMentor;
EXECUTE AddMentor 'Monica', 'Johnson';
COMMIT TRANSACTION AddMentor;

BEGIN TRANSACTION AddMentor;
EXECUTE AddMentor 'Huirong', 'Wang';
COMMIT TRANSACTION AddMentor;

BEGIN TRANSACTION AddMentor;
EXECUTE AddMentor 'Runalian', 'Zhang';
COMMIT TRANSACTION AddMentor;

BEGIN TRANSACTION AddMentor;
EXECUTE AddMentor 'Fang', 'Young';
COMMIT TRANSACTION AddMentor;

BEGIN TRANSACTION AddMentor;
EXECUTE AddMentor 'Alison', 'Decker';
COMMIT TRANSACTION AddMentor;

BEGIN TRANSACTION AddMentor;
EXECUTE AddMentor 'Ryan', 'Agnew';
COMMIT TRANSACTION AddMentor;

BEGIN TRANSACTION AddMentor;
EXECUTE AddMentor 'Chun', 'Yang';
COMMIT TRANSACTION AddMentor;



---------------Create stored procedure AddTraining and add information in the Training table.
CREATE PROCEDURE AddTraining
		@description VARCHAR (1000),
		@available_date DATE,
		@completion_date DATE,
		@training_status VARCHAR(15),
		@first_name VARCHAR (100),
		@last_name VARCHAR (100)		
AS
BEGIN
DECLARE @current_training_id INT = NEXT VALUE FOR training_seq;
INSERT INTO Training 
			(training_id,description, available_date, completion_date, training_status, mentor_id)
VALUES	(@current_training_id, @description,@available_date, @completion_date, @training_status, 
		(SELECT mentor_id from Mentor where first_name=@first_name AND last_name = @last_name));
END;



BEGIN TRANSACTION AddTraining;
EXECUTE AddTraining 'Medical terminology', '10/15/2020','11/15/2020','Completed','Xiaoying','Wang';
COMMIT TRANSACTION AddTraining;

BEGIN TRANSACTION AddTraining;
EXECUTE AddTraining 'Finance terminology', '10/20/2020','12/20/2020','Completed','Alison', 'Decker';
COMMIT TRANSACTION AddTraining;

BEGIN TRANSACTION AddTraining;
EXECUTE AddTraining 'Court terminology', '01/20/2021','12/20/2021','Completed','Ryan', 'Agnew';
COMMIT TRANSACTION AddTraining;

BEGIN TRANSACTION AddTraining;
EXECUTE AddTraining 'HIPPA', '01/20/2020','12/20/2020','Completed','Chun', 'Yang';;
COMMIT TRANSACTION AddTraining;
select* from training;

BEGIN TRANSACTION AddTraining;
EXECUTE AddTraining 'Life insurance Interview', '8/15/2020','11/15/2020','Completed', 'Runalian', 'Zhang';
COMMIT TRANSACTION AddTraining;

BEGIN TRANSACTION AddTraining;
EXECUTE AddTraining 'ER Visit', '7/15/2020','10/15/2020','Completed', 'Runalian', 'Zhang';
COMMIT TRANSACTION AddTraining;

BEGIN TRANSACTION AddTraining;
EXECUTE AddTraining 'Deposition', '6/15/2020','8/15/2020','Completed', 'Monica', 'Johnson';
COMMIT TRANSACTION AddTraining;

BEGIN TRANSACTION AddTraining;
EXECUTE AddTraining 'Social work', '4/15/2020','9/15/2020','Completed', 'Amanda', 'Smith';
COMMIT TRANSACTION AddTraining;

BEGIN TRANSACTION AddTraining;
EXECUTE AddTraining 'Billing despute', '7/15/2020','9/15/2020','Completed', 'Amanda', 'Smith';
COMMIT TRANSACTION AddTraining;

BEGIN TRANSACTION AddTraining;
EXECUTE AddTraining 'CMS System', '3/15/2020','9/15/2020','Completed', 'Runalian', 'Zhang';
COMMIT TRANSACTION AddTraining;



-----Create stored procedure AddAccount and add information in the Account table.

CREATE PROCEDURE AddAccount
		@password VARCHAR (20),
		@status VARCHAR (8)		
AS
BEGIN
DECLARE @current_account_id INT = NEXT VALUE FOR account_seq;
INSERT INTO Account
			(account_id,interpreter_id, password, status)
VALUES		(@current_account_id,(SELECT interpreter_id from Interpreter WHERE interpreter_id = @current_account_id ), @password, @status); 		
END;

BEGIN TRANSACTION AddAccount;
EXECUTE AddAccount 'sfhosdfsgf123','Active';
COMMIT TRANSACTION AddAccount;

BEGIN TRANSACTION AddAccount;
EXECUTE AddAccount 'khdsgioshg','Active';
COMMIT TRANSACTION AddAccount;

BEGIN TRANSACTION AddAccount;
EXECUTE AddAccount 'dshfid1245','Active';
COMMIT TRANSACTION AddAccount;

BEGIN TRANSACTION AddAccount;
EXECUTE AddAccount '8248bjbdgfd','Inactive';
COMMIT TRANSACTION AddAccount;

BEGIN TRANSACTION AddAccount;
EXECUTE AddAccount 'skhfds78','Active';
COMMIT TRANSACTION AddAccount;

BEGIN TRANSACTION AddAccount;
EXECUTE AddAccount 'shfisud67364!','Active';
COMMIT TRANSACTION AddAccount;

BEGIN TRANSACTION AddAccount;
EXECUTE AddAccount 'lkhu!354','Active';
COMMIT TRANSACTION AddAccount;

BEGIN TRANSACTION AddAccount;
EXECUTE AddAccount 'Linsdghsduig2!','Active';
COMMIT TRANSACTION AddAccount;

BEGIN TRANSACTION AddAccount;
EXECUTE AddAccount 'uhdfyudy!@','Active';
COMMIT TRANSACTION AddAccount;

BEGIN TRANSACTION AddAccount;
EXECUTE AddAccount 'shgifdusa1!','Active';
COMMIT TRANSACTION AddAccount;

BEGIN TRANSACTION AddAccount;
EXECUTE AddAccount 'sighsoi','Active';
COMMIT TRANSACTION AddAccount;

BEGIN TRANSACTION AddAccount;
EXECUTE AddAccount 'sighdi','Active';
COMMIT TRANSACTION AddAccount;

BEGIN TRANSACTION AddAccount;
EXECUTE AddAccount 'ih-0234nf','Active';
COMMIT TRANSACTION AddAccount;

BEGIN TRANSACTION AddAccount;
EXECUTE AddAccount '935bjhbfsd','Active';
COMMIT TRANSACTION AddAccount;

BEGIN TRANSACTION AddAccount;
EXECUTE AddAccount 'dkgndkfg','Inactive';
COMMIT TRANSACTION AddAccount;

BEGIN TRANSACTION AddAccount;
EXECUTE AddAccount '45fgdfg','Inactive';
COMMIT TRANSACTION AddAccount;

BEGIN TRANSACTION AddAccount;
EXECUTE AddAccount '8hggjg','Active';
COMMIT TRANSACTION AddAccount;

BEGIN TRANSACTION AddAccount;
EXECUTE AddAccount 'efd','Active';
COMMIT TRANSACTION AddAccount;

BEGIN TRANSACTION AddAccount;
EXECUTE AddAccount 'fdfdg','Active';
COMMIT TRANSACTION AddAccount;

BEGIN TRANSACTION AddAccount;
EXECUTE AddAccount 'fdfdf','Active';
COMMIT TRANSACTION AddAccount;

BEGIN TRANSACTION AddAccount;
EXECUTE AddAccount 'dfdgdgd','Active';
COMMIT TRANSACTION AddAccount;

BEGIN TRANSACTION AddAccount;
EXECUTE AddAccount 'fdfdf','Active';
COMMIT TRANSACTION AddAccount;


------Create stored procedure Addcall and add information in the Call table.

CREATE PROCEDURE AddCall
		@call_type CHAR (3),
		@call_date DATE,
		@start_time TIME,
		@end_time TIME,
		@work_duration DECIMAL (4,2),
		@call_description VARCHAR (500)
AS
BEGIN
DECLARE @current_call_id INT = NEXT VALUE FOR call_seq;
 
INSERT INTO Call
			(call_id,interpreter_id,client_id,account_id,call_type,call_date,start_time,end_time,work_duration,call_description)
VALUES		(@current_call_id,@current_call_id,@current_call_id, @current_call_id,@call_type,@call_date,@start_time,@end_time,@work_duration,@call_description); 		
END;

BEGIN TRANSACTION AddCall;
EXECUTE AddCall 'OPI','01/02/2010','12:30 AM', '1:30 AM', '1.00','ER visit';
COMMIT TRANSACTION AddCall;

BEGIN TRANSACTION AddCall;
EXECUTE AddCall 'OPI','02/02/2010','12:30 PM', '2:00 PM', '1.30','Court hearing';
COMMIT TRANSACTION AddCall;

BEGIN TRANSACTION AddCall;
EXECUTE AddCall 'OPI','02/02/2010','10:30 AM', '11:00 AM', '1.50','Court hearing';
COMMIT TRANSACTION AddCall;

BEGIN TRANSACTION AddCall;
EXECUTE AddCall 'VRI','02/02/2010','1:30 PM', '2:00 PM', '0.50','Financial advising';
COMMIT TRANSACTION AddCall;

BEGIN TRANSACTION AddCall;
EXECUTE AddCall 'VRI','02/03/2010','1:30 PM', '2:00 PM', '0.5','Doctor visit';
COMMIT TRANSACTION AddCall;

BEGIN TRANSACTION AddCall;
EXECUTE AddCall 'OPI','02/04/2010','1:30 PM', '2:00 PM', '0.5','Probation officer visit';
COMMIT TRANSACTION AddCall;

BEGIN TRANSACTION AddCall;
EXECUTE AddCall 'VRI','02/05/2010','1:30 PM', '2:00 PM', '0.5','Doctor visit';
COMMIT TRANSACTION AddCall;

BEGIN TRANSACTION AddCall;
EXECUTE AddCall 'VRI','02/06/2010','1:30 PM', '2:00 PM', '0.5','Parent meeting';
COMMIT TRANSACTION AddCall;

BEGIN TRANSACTION AddCall;
EXECUTE AddCall 'OPI','02/07/2010','1:30 PM', '2:00 PM', '0.5','Home care';
COMMIT TRANSACTION AddCall;

BEGIN TRANSACTION AddCall;
EXECUTE AddCall 'VRI','02/09/2010','10:30 AM', '12:30 PM', '2','Physical therapy';
COMMIT TRANSACTION AddCall;


------- Add information in the Language table.

INSERT INTO  Language (language_id, language_name)
VALUES (NEXT VALUE FOR language_seq, 'English');

INSERT INTO  Language (language_id, language_name)
VALUES (NEXT VALUE FOR language_seq, 'Mandarin');

INSERT INTO  Language (language_id, language_name)
VALUES (NEXT VALUE FOR language_seq, 'French');

INSERT INTO  Language (language_id, language_name)
VALUES (NEXT VALUE FOR language_seq, 'Spanish');

INSERT INTO  Language (language_id, language_name)
VALUES (NEXT VALUE FOR language_seq, 'Cantonese');

INSERT INTO  Language (language_id, language_name)
VALUES (NEXT VALUE FOR language_seq, 'Japanese');

INSERT INTO  Language (language_id, language_name)
VALUES (NEXT VALUE FOR language_seq, 'Korean');

INSERT INTO  Language (language_id, language_name)
VALUES (NEXT VALUE FOR language_seq, 'Portuguese');


INSERT INTO  Language (language_id, language_name)
VALUES (NEXT VALUE FOR language_seq, 'Vietnamese');

INSERT INTO  Language (language_id, language_name)
VALUES (NEXT VALUE FOR language_seq, 'Russian');



-----Add information in the Speaks table

INSERT INTO  Speaks (interpreter_id, language_id)
VALUES( (select interpreter_id from interpreter where first_name ='Alex'AND last_name = 'Johnson') ,
		(select language_id from language where language_name = 'English'));

INSERT INTO  Speaks (interpreter_id, language_id)
VALUES( (select interpreter_id from interpreter where first_name ='Linda'AND last_name = 'Li') ,
		(select language_id from language where language_name = 'Mandarin'));

INSERT INTO  Speaks (interpreter_id, language_id)
VALUES( (select interpreter_id from interpreter where first_name ='Preston'AND last_name = 'Decker') ,
		(select language_id from language where language_name = 'English'));

INSERT INTO  Speaks (interpreter_id, language_id)
VALUES( (select interpreter_id from interpreter where first_name ='Eric'AND last_name = 'Park') ,
		(select language_id from language where language_name = 'Korean'));

INSERT INTO  Speaks (interpreter_id, language_id)
VALUES( (select interpreter_id from interpreter where first_name ='Tom'AND last_name = 'Tang') ,
		(select language_id from language where language_name = 'Russian'));

INSERT INTO  Speaks (interpreter_id, language_id)
VALUES( (select interpreter_id from interpreter where first_name ='Mary'AND last_name = 'Post') ,
		(select language_id from language where language_name = 'English'));

INSERT INTO  Speaks (interpreter_id, language_id)
VALUES( (select interpreter_id from interpreter where first_name ='Hal'AND last_name = 'Johnson') ,
		(select language_id from language where language_name = 'Japanese'));

INSERT INTO  Speaks (interpreter_id, language_id)
VALUES( (select interpreter_id from interpreter where first_name ='Sam'AND last_name = 'Polose') ,
		(select language_id from language where language_name = 'Vietnamese'));


INSERT INTO  Speaks (interpreter_id, language_id)
VALUES( (select interpreter_id from interpreter where first_name ='Kate'AND last_name = 'Zhang') ,
		(select language_id from language where language_name = 'Mandarin'));

INSERT INTO  Speaks (interpreter_id, language_id)
VALUES( (select interpreter_id from interpreter where first_name ='Amy'AND last_name = 'Agnew') ,
		(select language_id from language where language_name = 'Mandarin'));

INSERT INTO  Speaks (interpreter_id, language_id)
VALUES( (select interpreter_id from interpreter where first_name ='James'AND last_name = 'Luis') ,
		(select language_id from language where language_name = 'Mandarin'));

INSERT INTO  Speaks (interpreter_id, language_id)
VALUES( (select interpreter_id from interpreter where first_name ='Wanwan'AND last_name = 'Huang') ,
		(select language_id from language where language_name = 'Mandarin'));


------Add information in the Service table.

INSERT INTO  Service (interpreter_id, client_id)
VALUES( (select interpreter_id from interpreter where first_name ='Amy'AND last_name = 'Agnew') ,
		(select client_id from Client where client_name = 'VNC'));

INSERT INTO  Service (interpreter_id, client_id)
VALUES( (select interpreter_id from interpreter where first_name ='Linda'AND last_name = 'Li') ,
		(select client_id from Client where client_name = 'ABF'));

INSERT INTO Service (interpreter_id, client_id)
VALUES( (select interpreter_id from interpreter where first_name ='Preston'AND last_name = 'Decker') ,
		(select client_id from Client where client_name = 'BNV'));

INSERT INTO  Service (interpreter_id, client_id)
VALUES( (select interpreter_id from interpreter where first_name ='Eric'AND last_name = 'Park') ,
		(select client_id from Client where client_name = 'AB Bank'));

INSERT INTO  Service (interpreter_id, client_id)
VALUES( (select interpreter_id from interpreter where first_name ='Tom'AND last_name = 'Tang') ,
		(select client_id from Client where client_name = 'ABF'));

INSERT INTO  Service (interpreter_id, client_id)
VALUES( (select interpreter_id from interpreter where first_name ='Mary'AND last_name = 'Post') ,
		(select client_id from Client where client_name = 'NY Hospital'));

INSERT INTO  Service (interpreter_id, client_id)
VALUES( (select interpreter_id from interpreter where first_name ='Hal'AND last_name = 'Johnson') ,
		(select client_id from Client where client_name = 'Ali Trading'));

INSERT INTO Service (interpreter_id, client_id)
VALUES( (select interpreter_id from interpreter where first_name ='Sam'AND last_name = 'Polose') ,
		(select client_id from Client where client_name = 'Macys'));


INSERT INTO Service (interpreter_id, client_id)
VALUES( (select interpreter_id from interpreter where first_name ='Kate'AND last_name = 'Zhang') ,
		(select client_id from Client where client_name = 'ST Insurance'));

INSERT INTO  Service (interpreter_id, client_id)
VALUES( (select interpreter_id from interpreter where first_name ='Amy'AND last_name = 'Agnew') ,
		(select client_id from Client where client_name = 'West School District'));


----------- Add information in the Communicates table

INSERT INTO  Communicates (interpreter_id, department_id)
VALUES( (select interpreter_id from interpreter where first_name ='Amy'AND last_name = 'Agnew') ,
		(select department_id from Department where department_name = 'Human Resource'));

INSERT INTO  Communicates (interpreter_id, department_id)
VALUES( (select interpreter_id from interpreter where first_name ='Kate'AND last_name = 'Zhang') ,
		(select department_id from Department where department_name = 'Operation'));

INSERT INTO  Communicates (interpreter_id, department_id)
VALUES( (select interpreter_id from interpreter where first_name ='Hal'AND last_name = 'Johnson') ,
		(select department_id from Department where department_name = 'IT'));

INSERT INTO  Communicates (interpreter_id, department_id)
VALUES( (select interpreter_id from interpreter where first_name ='Tom'AND last_name = 'Tang') ,
		(select department_id from Department where department_name = 'Finance'));

INSERT INTO  Communicates (interpreter_id, department_id)
VALUES( (select interpreter_id from interpreter where first_name ='Eric'AND last_name = 'Park') ,
		(select department_id from Department where department_name = 'Accounting'));

INSERT INTO  Communicates (interpreter_id, department_id)
VALUES( (select interpreter_id from interpreter where first_name ='Preston'AND last_name = 'Decker') ,
		(select department_id from Department where department_name = 'Human Resource'));

INSERT INTO  Communicates (interpreter_id, department_id)
VALUES( (select interpreter_id from interpreter where first_name ='Linda'AND last_name = 'Li') ,
		(select department_id from Department where department_name = 'Product and Service'));

INSERT INTO  Communicates (interpreter_id, department_id)
VALUES( (select interpreter_id from interpreter where first_name ='Mary'AND last_name = 'Post') ,
		(select department_id from Department where department_name = 'Human Resource'));

INSERT INTO  Communicates (interpreter_id, department_id)
VALUES( (select interpreter_id from interpreter where first_name ='Sam'AND last_name = 'Polose') ,
		(select department_id from Department where department_name = 'Marketing'));

INSERT INTO  Communicates (interpreter_id, department_id)
VALUES( (select interpreter_id from interpreter where first_name ='Kate'AND last_name = 'Zhang') ,
		(select department_id from Department where department_name = 'Maintenance'));



------Add information in the Participation table.
INSERT INTO  Participation (interpreter_id, training_id)
VALUES( (select interpreter_id from interpreter where first_name ='Kate'AND last_name = 'Zhang') ,
		(select training_id from Training where description = 'Medical terminology'));

INSERT INTO  Participation (interpreter_id, training_id)
VALUES( (select interpreter_id from interpreter where first_name ='Sam'AND last_name = 'Polose') ,
		(select training_id from Training where description = 'Finance terminology'));

INSERT INTO  Participation (interpreter_id, training_id)
VALUES( (select interpreter_id from interpreter where first_name ='Mary'AND last_name = 'Post') ,
		(select training_id from Training where description = 'HIPPA'));


INSERT INTO  Participation (interpreter_id, training_id)
VALUES( (select interpreter_id from interpreter where first_name ='Linda'AND last_name = 'Li') ,
		(select training_id from Training where description = 'HIPPA'));

INSERT INTO  Participation (interpreter_id, training_id)
VALUES( (select interpreter_id from interpreter where first_name ='Linda'AND last_name = 'Li') ,
		(select training_id from Training where description = 'ER visit'));

INSERT INTO  Participation (interpreter_id, training_id)
VALUES( (select interpreter_id from interpreter where first_name ='Eric'AND last_name = 'Park') ,
		(select training_id from Training where description = 'Social work'));

INSERT INTO  Participation (interpreter_id, training_id)
VALUES( (select interpreter_id from interpreter where first_name ='Preston'AND last_name = 'Decker') ,
		(select training_id from Training where description = 'CMS System'));

INSERT INTO  Participation (interpreter_id, training_id)
VALUES( (select interpreter_id from interpreter where first_name ='Mary'AND last_name = 'Post') ,
		(select training_id from Training where description = 'CMS System'));

INSERT INTO  Participation (interpreter_id, training_id)
VALUES( (select interpreter_id from interpreter where first_name ='Amy'AND last_name = 'Agnew') ,
		(select training_id from Training where description = 'Finance terminology'));

INSERT INTO  Participation (interpreter_id, training_id)
VALUES( (select interpreter_id from interpreter where first_name ='Sam'AND last_name = 'Polose') ,
		(select training_id from Training where description = 'Court terminology'));

INSERT INTO  Participation (interpreter_id, training_id)
VALUES( (select interpreter_id from interpreter where first_name ='Sam'AND last_name = 'Polose') ,
		(select training_id from Training where description = 'Deposition'));


		


-----Query 1: retrieving all the interpreters who received a raise for more than $ 500 during 2021.

SELECT Interpreter.interpreter_id, Interpreter.first_name,Interpreter.last_name, old_pay,new_pay,change_date
FROM Paychange
JOIN Interpreter on Paychange.interpreter_id = Interpreter.interpreter_id
GROUP BY Interpreter.interpreter_id, Interpreter.first_name,Interpreter.last_name, old_pay,new_pay,change_date
HAVING new_pay-old_pay>=500 AND (change_date>='1/1/2021' AND change_date<'1/1/2022');


------Query 2: retrieving contact info for all full-time interpreters who were hired since 2016. 
SELECT Interpreter.Interpreter_id, Interpreter.first_name,Interpreter.last_name, email_address, phone_number,start_date
FROM Interpreter
JOIN Full_time on Interpreter.Interpreter_id=Full_time.interpreter_id
WHERE start_date>='1/1/2016'
ORDER BY start_date;



--------Query 3: retrieving contact info for all full-time interpreters who were hired since 2016 and speak English. 

SELECT Interpreter.Interpreter_id, Interpreter.first_name,Interpreter.last_name,email_address,phone_number,start_date,language_name
FROM Full_time
JOIN Interpreter on Interpreter.Interpreter_id=Full_time.interpreter_id
JOIN Speaks on Speaks.interpreter_id = Interpreter.Interpreter_id
JOIN Language on Speaks.language_id = Language.language_id
     AND language_name ='English'
WHERE start_date>='1/1/2016' ;


-----------------Query 4: How many of each type of Mandarin interpreters are currently active?
CREATE OR ALTER VIEW num_mandarin_interpreter_each_type AS
SELECT work_status, COUNT(work_status) AS num_mandarin_interpreters
FROM Account
JOIN Interpreter ON Interpreter.interpreter_id = Account.interpreter_id
JOIN Speaks on Speaks.interpreter_id = Interpreter.interpreter_id
JOIN Language on Language.language_id = Speaks.language_id
WHERE status = 'Active' AND Language_name='Mandarin'
GROUP BY  work_status;

select* from num_mandarin_interpreter_each_type ;


------Visulization
--------- How many interpreters does the company has for each language?

select language_name, count(interpreter_id) AS num_interpreters 
from Language
join speaks on speaks.language_id=language.language_id
group by language_name;

-----------How many calls does the company receive each day?
select count (call_id) as num_calls,call_date
from call
group by call_date;

