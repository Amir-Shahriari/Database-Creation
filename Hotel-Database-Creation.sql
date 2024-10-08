-- SHOW databases;

-- CREATE DATABASE HOTEL;

-- USE HOTEL;


-- DROP TABLE IF EXISTS HOTEL, ROOM, CUSTOMER, BOOKING; 

CREATE TABLE HOTEL(
HOTELID CHAR(3),
HOTELNAME VARCHAR(25),
HOTELADDRESS VARCHAR(30),
HOTELCITY VARCHAR(15),
CONSTRAINT HOTEL_PK PRIMARY KEY (HOTELID)

);

CREATE TABLE ROOM(
HOTELID CHAR(3),
ROOMNO CHAR(5),
ROOMTYPE VARCHAR(10),
ACCESSIBILITY CHAR(1),
PRICE SMALLINT,

CONSTRAINT ROOM_PK PRIMARY KEY (HOTELID, ROOMNO),
CONSTRAINT ROOM_FK FOREIGN KEY (HOTELID) REFERENCES HOTEL(HOTELID)
);

CREATE TABLE CUSTOMER(
CUSTOMERID CHAR(4),
CUSTOMERNAME VARCHAR(25),
CUSTOMERNATIONALITY VARCHAR(20),
CUSTOMERDOB DATE,

CONSTRAINT CUSTOMER_PK PRIMARY KEY (CUSTOMERID)
);

CREATE TABLE BOOKING(
BOOKINGID CHAR(5),
CHECKIN DATE,
NIGHTS TINYINT,
CUSTOMERID CHAR(4),
HOTELID CHAR(3),
ROOMNO CHAR(5),

CONSTRAINT BOOKING_PK PRIMARY KEY (BOOKINGID),

CONSTRAINT BOOKING_FK1 FOREIGN KEY (CUSTOMERID) REFERENCES CUSTOMER(CUSTOMERID),

CONSTRAINT BOOKING_FK2 FOREIGN KEY (HOTELID, ROOMNO) REFERENCES ROOM (HOTELID, ROOMNO)

);

INSERT INTO HOTEL VALUES ("H1","MERIT HOTEL","KENT STREET","SYDNEY");				
INSERT INTO HOTEL VALUES ("H2","EDEN PARADISE HOTEL","VICTORIA STREET","SYDNEY");				
INSERT INTO HOTEL VALUES ("H3","BELLA HOTEL","SOUTHBANK","MELBOURNE");	

INSERT INTO ROOM VALUES ("H1","100A","SINGLE","Y",120);								
INSERT INTO ROOM VALUES ("H1","150A","DOUBLE","Y",200);								
INSERT INTO ROOM VALUES ("H1","200B","SUITE","Y",350);								
INSERT INTO ROOM VALUES ("H2","80B","SINGLE","N",145);								
INSERT INTO ROOM VALUES ("H2","100A","DOUBLE","Y",190);								
INSERT INTO ROOM VALUES ("H3","300A","SINGLE","Y",140);	

INSERT INTO CUSTOMER VALUES ("C1","Adams Davis","AUSTRALIAN","2001-5-1");					
INSERT INTO CUSTOMER VALUES ("C2","Lisa Baker","AMERICAN","1984-4-15");					
INSERT INTO CUSTOMER VALUES ("C3","Liang Liu","CHINESE","1948-3-21");					
INSERT INTO CUSTOMER VALUES ("C4","Joseph Vijay","INDIAN","1991-11-9");					
INSERT INTO CUSTOMER VALUES ("C5","Emily Smith","AUSTRALIAN","2000-8-12");					
INSERT INTO CUSTOMER VALUES ("C6","Cyrine Abdelnour","LEBANESE","1977-7-7");					

INSERT INTO BOOKING VALUES ("B01","2018-9-3",2,"C1","H1","100A");							
INSERT INTO BOOKING VALUES ("B02","2018-9-3",1,"C2","H1","150A");							
INSERT INTO BOOKING VALUES ("B03","2018-9-4",3,"C1","H2","80B");							
INSERT INTO BOOKING VALUES ("B04","2018-9-4",2,"C3","H1","100A");							
INSERT INTO BOOKING VALUES ("B05","2018-9-4",4,"C4","H2","80B");							
INSERT INTO BOOKING VALUES ("B06","2018-9-5",3,"C2","H2","100A");							
INSERT INTO BOOKING VALUES ("B07","2018-9-5",1,"C1","H3","300A");