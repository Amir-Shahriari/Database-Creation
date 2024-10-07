# SQL Table Create statements below
# ===
CREATE TABLE Car_Park (
    carpark_id INT PRIMARY KEY,
    map_reference VARCHAR(10) NOT NULL,
    description VARCHAR(200) NULL
);

CREATE TABLE Swipe_Card (
    card_id INT PRIMARY KEY,
    name_on_card VARCHAR(100) NOT NULL,
    staff_number VARCHAR(10) NULL,
    contact_phone VARCHAR(20) NOT NULL
);

CREATE TABLE Spot_Reservation_Parking_Area (
    area_id INT PRIMARY KEY,
    carpark_id INT NOT NULL,
    area_name VARCHAR(45) NULL,
    FOREIGN KEY (carpark_id) REFERENCES Car_Park(carpark_id)
);

CREATE TABLE Numbered_Parking_Spot (
    parking_spot_id INT PRIMARY KEY,
    area_id INT NOT NULL,
    location_description VARCHAR(100) NULL,
    FOREIGN KEY (area_id) REFERENCES Spot_Reservation_Parking_Area(area_id)
);

CREATE TABLE Timeslot (
    Year YEAR(4),
    Semester CHAR(2) NOT NULL,
    PRIMARY KEY (Year, Semester)
);

CREATE TABLE Car (
    number_plate VARCHAR(10) PRIMARY KEY,
    car_brand VARCHAR(45) NOT NULL,
    car_model VARCHAR(45) NOT NULL
);

CREATE TABLE Spot_Reservation (
    reservation_id INT PRIMARY KEY,
    card_id INT NOT NULL,
    number_plate VARCHAR(10) NOT NULL,
    payment_amount DECIMAL(5,2) NOT NULL,
    when_created DATETIME NOT NULL,
    FOREIGN KEY (card_id) REFERENCES Swipe_Card(card_id),
    FOREIGN KEY (number_plate) REFERENCES Car(number_plate)
);

CREATE TABLE Spot_Area_Entry_Attempt (
    attempt_id INT PRIMARY KEY,
    card_id INT NOT NULL,
    area_id INT NOT NULL,
    date_and_time_of_entry DATETIME NOT NULL,
    FOREIGN KEY (card_id) REFERENCES Swipe_Card(card_id),
    FOREIGN KEY (area_id) REFERENCES Spot_Reservation_Parking_Area(area_id)
);

CREATE TABLE Allocation (
    parking_spot_id INT,
    Timeslot_Year YEAR(4),
    Timeslot_semester CHAR(2),
    Spot_Reservation_reservation_id INT NOT NULL,
    PRIMARY KEY (parking_spot_id, Timeslot_Year, Timeslot_semester),
    FOREIGN KEY (parking_spot_id) REFERENCES Numbered_Parking_Spot(parking_spot_id),
    FOREIGN KEY (Timeslot_Year, Timeslot_semester) REFERENCES Timeslot(Year, Semester),
    FOREIGN KEY (Spot_Reservation_reservation_id) REFERENCES Spot_Reservation(reservation_id)
);
# ===

# A2 Part 2 - SQL insert statements for data to be inserted into your tables
# ===
INSERT INTO Car_Park (carpark_id, map_reference, description) VALUES (1, 'A1', 'Near Main Entrance');
INSERT INTO Car_Park (carpark_id, map_reference, description) VALUES (2, 'B1', 'Near Building B');
INSERT INTO Car_Park (carpark_id, map_reference, description) VALUES (3, 'C1', 'Beside Gym');
INSERT INTO Car_Park (carpark_id, map_reference, description) VALUES (1, 'A1', 'Near Main Entrance');
INSERT INTO Car_Park (carpark_id, map_reference, description) VALUES (2, 'B1', 'Near Building B');
INSERT INTO Car_Park (carpark_id, map_reference, description) VALUES (3, 'C1', 'Beside Gym');
INSERT INTO Swipe_Card (card_id, name_on_card,staff_number, contact_phone) VALUES (57165, 'Pomona Ford','571651', '0400000000');
INSERT INTO Swipe_Card (card_id, name_on_card,staff_number, contact_phone) VALUES (61688, 'John Sally','711876', '0401111111');
INSERT INTO Swipe_Card (card_id, name_on_card,staff_number, contact_phone) VALUES (84826, 'Barry Holden','873686', '0402111111');

INSERT INTO Spot_Reservation_Parking_Area (area_id, carpark_id, area_name) VALUES (1, 1, 'Area A');
INSERT INTO Spot_Reservation_Parking_Area (area_id, carpark_id, area_name) VALUES (2, 2, 'Area B');
INSERT INTO Spot_Reservation_Parking_Area (area_id, carpark_id, area_name) VALUES (3, 3, 'Area C');
INSERT INTO Numbered_Parking_Spot (parking_spot_id, area_id, location_description) VALUES (1, 1, 'Near tree');
INSERT INTO Numbered_Parking_Spot (parking_spot_id, area_id, location_description) VALUES (2, 2, 'Beside lamp post');
INSERT INTO Numbered_Parking_Spot (parking_spot_id, area_id, location_description) VALUES (3, 3, 'Close to exit');
INSERT INTO Timeslot (Year, Semester) VALUES (2023, 'A');
INSERT INTO Timeslot (Year, Semester) VALUES (2023, 'B');
INSERT INTO Car (number_plate, car_brand, car_model) VALUES ('ABC123', 'Toyota', 'Camry');
INSERT INTO Car (number_plate, car_brand, car_model) VALUES ('XYZ789', 'Honda', 'Civic');
INSERT INTO Car (number_plate, car_brand, car_model) VALUES ('LMN456', 'Ford', 'Focus');
INSERT INTO Car (number_plate, car_brand, car_model) VALUES ('KDM443', 'Suzuki', 'Vitara');
INSERT INTO Spot_Reservation (reservation_id, card_id, number_plate, payment_amount, when_created) VALUES (1, 57165, 'ABC123', 50.00, NOW());
INSERT INTO Spot_Reservation (reservation_id, card_id, number_plate, payment_amount, when_created) VALUES (2, 61688, 'XYZ789', 60.00, NOW());
INSERT INTO Spot_Reservation (reservation_id, card_id, number_plate, payment_amount, when_created) VALUES (4, 61688, 'XYZ789', 65.00, NOW());
INSERT INTO Spot_Reservation (reservation_id, card_id, number_plate, payment_amount, when_created) VALUES (3, 57165, 'LMN456', 55.00, NOW());
INSERT INTO Spot_Reservation (reservation_id, card_id, number_plate, payment_amount, when_created) VALUES (5, 84826, 'KDM443', 45.00, NOW());
INSERT INTO Spot_Reservation (reservation_id, card_id, number_plate, payment_amount, when_created) VALUES (6, 84826, 'KDM443', 55.00, NOW());
INSERT INTO Spot_Area_Entry_Attempt (attempt_id, card_id, area_id, date_and_time_of_entry) VALUES (1, 57165, 1, NOW());
INSERT INTO Spot_Area_Entry_Attempt (attempt_id, card_id, area_id, date_and_time_of_entry) VALUES (3, 57165, 1, NOW());
INSERT INTO Spot_Area_Entry_Attempt (attempt_id, card_id, area_id, date_and_time_of_entry) VALUES (2, 61688, 2, NOW());
INSERT INTO Spot_Area_Entry_Attempt (attempt_id, card_id, area_id, date_and_time_of_entry) VALUES (4, 61688, 2, NOW());
INSERT INTO Spot_Area_Entry_Attempt (attempt_id, card_id, area_id, date_and_time_of_entry) VALUES (5, 61688, 2, NOW());
INSERT INTO Allocation (parking_spot_id, Timeslot_Year, Timeslot_semester, Spot_Reservation_reservation_id) VALUES (1, 2023, 'A', 1);
INSERT INTO Allocation (parking_spot_id, Timeslot_Year, Timeslot_semester, Spot_Reservation_reservation_id) VALUES (2, 2023, 'B', 2);
INSERT INTO Allocation (parking_spot_id, Timeslot_Year, Timeslot_semester, Spot_Reservation_reservation_id) VALUES (3, 2023, 'A', 3);
INSERT INTO Allocation (parking_spot_id, Timeslot_Year, Timeslot_semester, Spot_Reservation_reservation_id) VALUES (2, 2023, 'A', 4);
INSERT INTO Allocation (parking_spot_id, Timeslot_Year, Timeslot_semester, Spot_Reservation_reservation_id) VALUES (3, 2023, 'B', 5);
INSERT INTO Allocation (parking_spot_id, Timeslot_Year, Timeslot_semester, Spot_Reservation_reservation_id) VALUES (1, 2023, 'B', 6);
# ===

# A2 Part 3 - SQL queries

# Part 3 query a)
SELECT staff_number, COUNT(*) AS number_of_records
FROM Swipe_Card
GROUP BY staff_number
ORDER BY number_of_records DESC;

# Part 3 query b)
SELECT s.name_on_card, s.staff_number
FROM Swipe_Card s
JOIN Spot_Reservation sr ON s.card_id = sr.card_id
GROUP BY s.name_on_card, s.staff_number
HAVING COUNT(DISTINCT sr.reservation_id) >= 2
ORDER BY s.name_on_card ASC;

# Part 3 query c)
#tried with car_id 61688
SELECT * 
FROM Spot_Area_Entry_Attempt
WHERE card_id = 61688;

# Part 3 query d)
SELECT cp.carpark_id, cp.description, COUNT(nps.parking_spot_id) AS total_spots
FROM Car_Park cp
JOIN Spot_Reservation_Parking_Area srpa ON cp.carpark_id = srpa.carpark_id
JOIN Numbered_Parking_Spot nps ON srpa.area_id = nps.area_id
GROUP BY cp.carpark_id, cp.description;

# Part 3 query e)
SELECT sc.card_id, COUNT(DISTINCT sr.number_plate) AS num_of_cars
FROM Swipe_Card sc
JOIN Spot_Reservation sr ON sc.card_id = sr.card_id
GROUP BY sc.card_id;


# Part 3 query f)
#tried with 2021 for year and "B" for the semester
SELECT cp.carpark_id, cp.description, COUNT(DISTINCT nps.parking_spot_id) AS unallocated_spots
FROM Car_Park cp
JOIN Spot_Reservation_Parking_Area srpa ON cp.carpark_id = srpa.carpark_id
JOIN Numbered_Parking_Spot nps ON srpa.area_id = nps.area_id
LEFT JOIN Allocation a ON nps.parking_spot_id = a.parking_spot_id
WHERE (a.Timeslot_Year != 2021 OR a.Timeslot_semester != 'B') OR a.parking_spot_id IS NULL
GROUP BY cp.carpark_id, cp.description;

# Part 3 query g)
SELECT s.staff_number, SUM(sr.payment_amount) AS total_amount
FROM Swipe_Card s
JOIN Spot_Reservation sr ON s.card_id = sr.card_id
GROUP BY s.staff_number;

# Part 3 query h)
SELECT cp.carpark_id, YEAR(sr.when_created) AS year, SUM(sr.payment_amount) AS total_revenue
FROM Car_Park cp
JOIN Spot_Reservation_Parking_Area srpa ON cp.carpark_id = srpa.carpark_id
JOIN Numbered_Parking_Spot nps ON srpa.area_id = nps.area_id
JOIN Allocation a ON nps.parking_spot_id = a.parking_spot_id
JOIN Spot_Reservation sr ON a.Spot_Reservation_reservation_id = sr.reservation_id
GROUP BY cp.carpark_id, YEAR(sr.when_created);



