
-- Creating Tables

-- Creating Vaccine Table
Create table Vaccine(
VaccineID char(4),
VaccineName varchar(25),
VaccineExpiry date,
Constraint Vaccine_PK Primary Key (VaccineID)
);


-- Creating Patient Table
create table Patient(
PatientID char(4),
PatientName varchar(20),
PatientSuburb varchar(20),
PatientAge int,
PatientOccupation varchar(20),
constraint Patient_PK primary key (PatientID)
);
-- Creating Nurse Table
create table Nurse(
NurseID char(4),
NurseName varchar(25),
NursePhoneNumber numeric,
NurseExperience int,
constraint Nurse_PK primary key (NurseID)
);


-- Creating Appointment table
create table Appointment(
AppointmentID char(5),
AppointmentTime time,
AppointmentDate date,
PatientID char(4),
constraint Appointment_PK primary key (AppointmentID),
constraint Appointment_FK foreign key (PatientID) references Patient (PatientID)
);


-- Creating  Shot table
create table Shot(
ShotTime time,
DoseNumber int,
PatientID char(4),
NurseID char(4),
VaccineID char(4),

constraint Shot_PK primary key (DoseNumber, PatientID),
constraint Shot_FK1 foreign key (PatientID) references Patient (patientID),
constraint Shot_FK2 foreign key (NurseID) references Nurse (NurseID),
constraint Shot_FK3 foreign key (VaccineID) references Vaccine (VaccineID)
);

-- Inserting Values
insert into Patient(PatientID, PatientName, PatientSuburb,PatientAge,PatientOccupation) 
values ('P001','RICKY PONTING','BURWOOD',46,'HEALTH'),
		('P002','MATHEW HYDEN','BURWOOD',48,'EDUCATION'),
		('P003','BRIAN LARA','MARSFIELD',52,'EDUCATION'),
		('P004','YOUNAS KHAN','EPPING',45,'AGED CARE'),
		('P005','RAHULL DRAVID','TOP RYDE',49,'HOSPITALITY'),
		('P006','KANE WILLIAMSON','AUBURN',39,'HEALTH'),
		('P007','BRIAN LARA','LIVERPOOL',55,'EDUCATION'),
		('P008','EOIN MORGAN','EPPING',37,'AGED CARE'),
		('P009','KUMAR SANGAKARA','PENRITH',42,'HOSPITALITY'),
		('P010','ANDY FLOWER','EPPING',61,'HEALTH');
insert into Nurse(NurseID,NurseName,NursePhoneNumber,NurseExperience)
values ('N001','WASIM AKRAM',122331,20),
('N002','CHAMINDA VAS',223441,15),
('N003','BRET LEE',443251,12),
('N004','JAMES ANDERSON',124321,10),
('N005','SAQLAIN MUSHTAQ',226670,18),
('N006','MUTTIAH MURALITHARAN',123450,19);
Insert into Vaccine(VaccineID,VaccineName,VaccineExpiry)
values ('V001','PFIZER','2021-11-01'),
		('V002','MODERNA','2022-01-01'),
		('V003','SPUTNICK','2022-03-01'),
		('V004','SINOVAC','2022-01-01'),
		('V005','PAKVAC','2022-12-01');
        
    
Insert Into Appointment(AppointmentID, AppointmentTime,AppointmentDate,PatientID)
values ('PT001','10:00','2021/03/02','P001'),
		('PT002','11:00','2021/04/03','P002'),
		('PT003','9:00','2021/03/02','P003'),
		('PT004','10:00','2021/03/02','P004'),
		('PT005','10:00','2021/04/05','P003'),
		('PT006','11:00','2021/05/06','P005'),
		('PT007','13:00','2021/04/03','P004'),
		('PT008','14:00','2021/05/02','P002'),
		('PT009','15:00','2021/04/03','P001'),
		('PT010','14:00','2021/05/02','P006'),
		('PT011','10:00','2021/04/04','P007'),
		('PT012','11:00','2021/06/03','P008'),
		('PT013','16:00','2021/06/25','P008');
            
Insert into Shot(ShotTime,DoseNumber,PatientID,NurseID,VaccineID)
values ('11:00',1,'P001','N001','V001'),
		('12:00',1,'P003','N002','V002'),
		('11:30',1,'P002','N003','V003'),
		('13:00',1,'P004','N002','V001'),
		('14:15',1,'P008','N001','V004'),
		('12:00',2,'P003','N005','V002'),
		('10:00',2,'P001','N001','V001'),
		('15:00',2,'P008','N001','V004'),
		('16:00',2,'P004','N005','V001'),
		('12:30',1,'P007','N006','V005'),
		('11:00',1,'P006','N006','V004'),
		('10:30',1,'P005','N004','V005');