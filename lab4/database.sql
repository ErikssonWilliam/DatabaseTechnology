ET foreign_key_checks = 0;
DROP TABLE IF EXISTS Reservation CASCADE;
DROP TABLE IF EXISTS Booking CASCADE;
DROP TABLE IF EXISTS CreditCard CASCADE;
DROP TABLE IF EXISTS HasTicket CASCADE;
DROP TABLE IF EXISTS Passenger CASCADE;
DROP TABLE IF EXISTS Contact CASCADE;
DROP TABLE IF EXISTS WeeklySchedule CASCADE;
DROP TABLE IF EXISTS Route CASCADE;
DROP TABLE IF EXISTS Airport CASCADE;
DROP TABLE IF EXISTS Flight CASCADE;
DROP TABLE IF EXISTS Year CASCADE;
DROP TABLE IF EXISTS DayOfWeek CASCADE;
SET foreign_key_checks = 1;
CREATE TABLE Reservation
   (ReservationNumber INTEGER,
    FlightNumb INTEGER,
   
    CONSTRAINT pk_reservation PRIMARY KEY(Reservationnumber)) ENGINE=InnoDB;
    
CREATE TABLE Booking
   (ReservationNumb INTEGER,
    TotalPrice INTEGER,
    CCNumber BIGINT,
    ContactPassengerNumb INTEGER,
   
    CONSTRAINT pk_booking PRIMARY KEY(ReservationNumb)) ENGINE=InnoDB;
    
CREATE TABLE CreditCard
   (CardNumber BIGINT,
    CardHolder VARCHAR(30),
   
    CONSTRAINT pk_creditcard PRIMARY KEY(CardNumber)) ENGINE=InnoDB;
    
CREATE TABLE HasTicket
   (ReservNumb INTEGER,
    PassportNumb INTEGER,
    TicketNumber INTEGER,
   
    CONSTRAINT pk_hasticket PRIMARY KEY(ReservNumb, PassportNumb)) ENGINE=InnoDB;
    
CREATE TABLE Passenger
   (PassportNumber INTEGER,
    FullName VARCHAR(30),
   
    CONSTRAINT pk_passenger PRIMARY KEY(PassportNumber)) ENGINE=InnoDB;
    
CREATE TABLE Contact
   (PassportNumb INTEGER,
    PhoneNumber BIGINT,
    Email VARCHAR(30),
   
    CONSTRAINT pk_contact PRIMARY KEY(PassportNumb)) ENGINE=InnoDB;
    
CREATE TABLE WeeklySchedule
   (ScheduleID INTEGER NOT NULL AUTO_INCREMENT,
    DepartureTime TIME,
    RouteId INTEGER,
    WsDay VARCHAR(10),
    WsYear INTEGER,
   
    CONSTRAINT pk_weeklyschedule PRIMARY KEY(ScheduleID)) ENGINE=InnoDB;
    
CREATE TABLE Route
   (RouteID INTEGER NOT NULL AUTO_INCREMENT,
    RouteYear INTEGER,
    RoutePrice DOUBLE,
    DepartureID VARCHAR(3),
    ArrivesID VARCHAR(3),
   
    CONSTRAINT pk_route PRIMARY KEY(RouteID)) ENGINE=InnoDB;
    
CREATE TABLE Airport
   (Code VARCHAR(3),
    Name VARCHAR(30),
    Country VARCHAR(30),
   
    CONSTRAINT pk_airport PRIMARY KEY(Code)) ENGINE=InnoDB;
    
CREATE TABLE Flight
   (FlightNumber INTEGER NOT NULL AUTO_INCREMENT,
    Week INTEGER,
    BookedPassenegers INTEGER NOT NULL DEFAULT 0,
    WsID INTEGER,
   
    CONSTRAINT pk_flight PRIMARY KEY(FlightNumber)) ENGINE=InnoDB;
    
CREATE TABLE Year
     (Year INTEGER,
      ProfitFactor DOUBLE,
     
    CONSTRAINT pk_year PRIMARY KEY(Year)) ENGINE=InnoDB;
    
CREATE TABLE DayOfWeek
     (DOWYear INTEGER,
      Day VARCHAR(10),
      WeekdayFactor DOUBLE,
     
    CONSTRAINT pk_dayofweek PRIMARY KEY(DOWYear, Day)) ENGINE=InnoDB;

ALTER TABLE Reservation ADD CONSTRAINT fk_reservationflight FOREIGN KEY(FlightNumb) REFERENCES Flight(FlightNumber);
ALTER TABLE Booking ADD CONSTRAINT fk_bookingreservation FOREIGN KEY(ReservationNumb) REFERENCES Reservation(ReservationNumber);
ALTER TABLE Booking ADD CONSTRAINT fk_bookingcreditcard FOREIGN KEY(CCNumber) REFERENCES CreditCard(CardNumber);
ALTER TABLE Booking ADD CONSTRAINT fk_bookingcontact FOREIGN KEY(ContactPassengerNumb) REFERENCES Contact(PassportNumb);
ALTER TABLE HasTicket ADD CONSTRAINT fk_ticketreservation FOREIGN KEY(ReservNumb) REFERENCES Reservation(ReservationNumber);
ALTER TABLE HasTicket ADD CONSTRAINT fk_ticketpassenger FOREIGN KEY(PassportNumb) REFERENCES Passenger(PassportNumber);
ALTER TABLE Contact ADD CONSTRAINT fk_contactpassport FOREIGN KEY(PassportNumb) REFERENCES Passenger(PassportNumber);
ALTER TABLE Route ADD CONSTRAINT fk_routeyear FOREIGN KEY(RouteYear) REFERENCES Year(Year);
ALTER TABLE Route ADD CONSTRAINT fk_routedep FOREIGN KEY(DepartureID) REFERENCES Airport(Code);
ALTER TABLE Flight ADD CONSTRAINT fk_flightweek FOREIGN KEY(WsID) REFERENCES WeeklySchedule(ScheduleID);
ALTER TABLE DayOfWeek ADD CONSTRAINT fk_dayyear FOREIGN KEY(DOWYear) REFERENCES Year(Year);
ALTER TABLE WeeklySchedule ADD CONSTRAINT fk_weeklyroute FOREIGN KEY(RouteId) REFERENCES Route(RouteID);
ALTER TABLE WeeklySchedule ADD CONSTRAINT fk_weekly FOREIGN KEY(WsYear, WsDay) REFERENCES DayOfWeek(DOWYear, Day);

/*Question 3 
Test script tested and should be ok
*/ 

DROP PROCEDURE IF EXISTS addYear;
DROP PROCEDURE IF EXISTS addDay;
DROP PROCEDURE IF EXISTS addDestination;
DROP PROCEDURE IF EXISTS addRoute;
DROP PROCEDURE IF EXISTS addFlight;

delimiter //
CREATE Procedure addYear(IN y INTEGER,IN factor DOUBLE)
BEGIN
	INSERT INTO Year (Year, ProfitFactor) VALUES (y, factor);
END;

CREATE Procedure addDay(IN Year INTEGER,IN d VARCHAR(10), IN factor DOUBLE)
BEGIN
	INSERT INTO DayOfWeek (DOWYear, Day ,WeekdayFactor) VALUES (Year, d, factor);
END;

CREATE Procedure addDestination(IN airport_code VARCHAR(3),IN n VARCHAR(30), IN c VARCHAR(30))
BEGIN
	INSERT INTO Airport (Code, Name, Country) VALUES (airport_code, n, c);
END;

CREATE Procedure addRoute(IN dc VARCHAR(3),IN ac VARCHAR(3), IN y INTEGER, IN rp DOUBLE)
BEGIN
	INSERT INTO Route (DepartureID, ArrivesID, RouteYear, RoutePrice) VALUES (dc, ac, y, rp);
END;

CREATE Procedure addFlight(IN dc VARCHAR(3),IN ac VARCHAR(3), IN y INTEGER, IN d VARCHAR(10), IN t TIME)
BEGIN
    DECLARE schedule_id INT;
    DECLARE w INT;

	INSERT INTO WeeklySchedule (DepartureTime, RouteId, WsDay, WsYear) VALUES (t, (SELECT RouteID FROM Route WHERE DepartureID = dc AND ArrivesID = ac AND RouteYear = y), d, y);
	
	SET schedule_id = LAST_INSERT_ID();
	SET w = 1;
	WHILE w <= 52 DO
		INSERT INTO Flight(Week, WsID) VALUES (w, schedule_id);
		SET w = w + 1;
	END WHILE;
END;
//
delimiter ;

/*Question 4 */
DROP FUNCTION IF EXISTS calculateFreeSeats;
DROP FUNCTION IF EXISTS calculatePrice;

delimiter //

CREATE Function calculateFreeSeats(fn INTEGER) RETURNS INTEGER
BEGIN
    DECLARE booked INTEGER;
    SELECT BookedPassenegers INTO booked FROM Flight WHERE FlightNumber = fn;
    RETURN 40 - booked;
END;

CREATE Function calculatePrice(fn INTEGER) RETURNS DOUBLE
/* total price = routeprice * weekdayfactor (#bookedPassengers +1)/40 * profitfactor */
BEGIN
    DECLARE booked INTEGER;
    DECLARE profit_factor DOUBLE;
    DECLARE route_price DOUBLE;
    DECLARE weekday_factor DOUBLE;

    SELECT BookedPassenegers INTO booked FROM Flight WHERE FlightNumber = fn;
    
    SELECT ProfitFactor INTO profit_factor FROM Year
    WHERE Year = (SELECT WsYear FROM WeeklySchedule WHERE ScheduleID = (SELECT WsID FROM Flight WHERE FlightNumber = fn));

    SELECT Route.RoutePrice
    INTO route_price
    FROM Flight
    JOIN WeeklySchedule ON Flight.WsID = WeeklySchedule.ScheduleID
    JOIN Route ON WeeklySchedule.RouteId = Route.RouteID
    WHERE Flight.FlightNumber = fn;

    SELECT DayOfWeek.WeekdayFactor
    INTO weekday_factor
    FROM Flight
    JOIN WeeklySchedule ON Flight.WsID = WeeklySchedule.ScheduleID
    JOIN DayOfWeek ON WeeklySchedule.WsDay = DayOfWeek.Day AND WeeklySchedule.WsYear = DayOfWeek.DOWYear
    WHERE Flight.FlightNumber = fn;

    RETURN ROUND((route_price * weekday_factor * (booked + 1) / 40 )* profit_factor,3);
END;
//
delimiter ;

/*Question 5 */
DROP TRIGGER IF EXISTS createTicketNumber;
delimiter //

CREATE TRIGGER createTicketNumber AFTER INSERT ON Booking FOR EACH ROW
BEGIN
    DECLARE new_ticket_number INTEGER;
    DECLARE i INTEGER;
    DECLARE passengers INTEGER;

    SELECT COUNT(*) INTO passengers FROM HasTicket WHERE HasTicket.ReservNumb = NEW.ReservationNumb;
    SET i =1;
    WHILE i <= passengers DO 
        SET new_ticket_number = FLOOR(RAND() * 100000);
        UPDATE HasTicket SET TicketNumber = new_ticket_number WHERE HasTicket.ReservNumb = NEW.ReservationNumb AND TicketNumber IS NULL LIMIT 1;
        SET i = i + 1;
    END WHILE;
END;
//
delimiter ;

/*Question 6 */
DROP PROCEDURE IF EXISTS addReservation;
DROP PROCEDURE IF EXISTS addPassenger;
DROP PROCEDURE IF EXISTS addContact;
DROP PROCEDURE IF EXISTS addPayment;
delimiter //

CREATE Procedure addReservation(IN dc VARCHAR(3),IN ac VARCHAR(3), IN y INTEGER, IN w INTEGER, IN d VARCHAR(10), IN t TIME, IN np INTEGER, OUT output_reservation_nr INTEGER)
BEGIN
    DECLARE flightNumb INTEGER DEFAULT 0;
  /*  SELECT FlightNumber INTO flightNumb FROM Flight WHERE Flight.week = w AND Flight.WsID = (
        SELECT ScheduleID FROM WeeklySchedule WHERE WsDay = d AND WsYear = y AND DepartureTime = t AND RouteId = (
            SELECT RouteID FROM Route WHERE ArrivesID = ac AND DepartureID = dc AND RouteYear = y)
    );*/
    SELECT f.FlightNumber INTO flightNumb
    FROM Flight f
    INNER JOIN WeeklySchedule ws ON f.WsID = ws.ScheduleID
    INNER JOIN Route r ON ws.RouteId = r.RouteID
    WHERE f.Week = w
    AND ws.WsDay = d
    AND ws.WsYear = y
    AND ws.DepartureTime = t
    AND r.ArrivesID = ac
    AND r.DepartureID = dc
    AND r.RouteYear = y;

    IF flightNumb > 0 AND calculateFreeSeats(flightNumb) >= np THEN /*kan vara  != 0*/
        SET output_reservation_nr = FLOOR(RAND() * 100000);
        INSERT INTO Reservation(ReservationNumber, FlightNumb) VALUES (output_reservation_nr, flightNumb);
    ELSE
        SET output_reservation_nr = 0;
        SELECT 'There exist no flight for the given route, date and time' AS Message;
    END IF;
END;

CREATE Procedure addPassenger(IN rnumb INTEGER, IN passNumb INTEGER, IN passname VARCHAR(30))
BEGIN
    DECLARE passenger_exists INT;
    DECLARE reservation_exists INT;
    DECLARE reservation_paid INT;

    SELECT COUNT(*) INTO passenger_exists FROM Passenger WHERE PassportNumber = passNumb;
    SELECT COUNT(*) INTO reservation_exists FROM Reservation WHERE ReservationNumber = rnumb;
    SELECT COUNT(*) INTO reservation_paid FROM HasTicket WHERE ReservNumb = rnumb AND TicketNumber IS NOT NULL;
    
    
    IF passenger_exists = 0 THEN
        INSERT INTO Passenger(PassportNumber, FullName) VALUES (passNumb, passname);
    END IF;

    IF reservation_exists > 0 THEN
 
        IF reservation_paid > 0 THEN
            SELECT 'The booking has already been payed and no futher passengers can be added' AS Message; 
        ELSE
            INSERT INTO HasTicket(ReservNumb, PassportNumb) VALUES (rnumb, passNumb);
        END IF;
    ELSE
        SELECT 'The given reservation number does not exist' AS Message;
    END IF;
    
END;

CREATE PROCEDURE addContact(
    IN reservation_nr INTEGER,
    IN passport_number INTEGER,
    IN email VARCHAR(30),
    IN phone BIGINT)
BEGIN
    DECLARE passenger_exists INTEGER;
    DECLARE reservation_exists INT;

    SELECT COUNT(*) INTO passenger_exists FROM HasTicket 
    WHERE ReservNumb = reservation_nr AND PassportNumb = passport_number;
    SELECT COUNT(*) INTO reservation_exists FROM Reservation WHERE ReservationNumber = reservation_nr;

    IF reservation_exists > 0 THEN
        IF passenger_exists > 0 THEN
            INSERT INTO Contact(PassportNumb, Email, PhoneNumber)
            VALUES (passport_number, email, phone);
            UPDATE Booking SET ContactPassengerNumb = passport_number WHERE ReservationNumb = reservation_nr;          
        ELSE
            SELECT 'The person is not a passenger of the reservation' AS Message;
        END IF;
    ELSE
        SELECT 'The given reservation number does not exist' AS Message;
    END IF;
END;

CREATE PROCEDURE addPayment(
    IN reservation_nr INTEGER,
    IN cardholder_name VARCHAR(30),
    IN credit_card_number BIGINT
)
BEGIN
    DECLARE flight_number INTEGER;
    DECLARE unpaid_seats INTEGER;
    DECLARE contact_exists INTEGER;
    DECLARE card_exists INTEGER;
    DECLARE number_passengers INTEGER;

    SELECT FlightNumb INTO flight_number FROM Reservation WHERE ReservationNumber = reservation_nr; 
    SET unpaid_seats = calculateFreeSeats(flight_number);

    SELECT COUNT(*) INTO contact_exists FROM Contact WHERE PassportNumb IN
            (SELECT PassportNumb FROM HasTicket WHERE ReservNumb = reservation_nr);

    SELECT COUNT(*) INTO card_exists FROM CreditCard WHERE CardNumber = credit_card_number AND CardHolder = cardholder_name;

    SELECT COUNT(*) INTO number_passengers FROM HasTicket WHERE reservation_nr = ReservNumb;

    IF unpaid_seats >= number_passengers AND contact_exists > 0 THEN
        if card_exists = 0 THEN
            INSERT INTO CreditCard(CardNumber, CardHolder) VALUES(credit_card_number, cardholder_name);
        END IF;
        INSERT INTO Booking(ReservationNumb, TotalPrice, CCNumber) VALUES (reservation_nr, calculatePrice(flight_number), credit_card_number);
        UPDATE Flight SET BookedPassenegers = BookedPassenegers + number_passengers WHERE FlightNumber = flight_number;
    ELSE
        SELECT 'Reservation does not have a contact or there are not enough unpaid seats on the plane.' AS Message;
    END IF;

END;
//
delimiter ;

/*Question 7 */
DROP VIEW IF EXISTS allFlights;
CREATE VIEW allFlights AS
SELECT
    dep.Name AS departure_city_name,
    dest.Name AS destination_city_name,
    ws.DepartureTime AS departure_time,
    ws.WsDay AS departure_day,
    ws.WsYear AS departure_year,
    f.week AS departure_week,
    calculateFreeSeats(f.FlightNumber) AS nr_of_free_seats,
    calculatePrice(f.FlightNumber) AS current_price_per_seat
FROM Flight f
JOIN WeeklySchedule ws ON f.WsID = ws.ScheduleID
JOIN Route r ON ws.RouteId = r.RouteID
JOIN Airport dep ON r.DepartureID = dep.Code
JOIN Airport dest ON r.ArrivesID = dest.Code;

/*Question 8 */

/*A) 
You can limit table access
You can encrypt data, the data is encoded using some coding algorithm. unaouthorized users will have a hard time deciphering the data,
authorized users will be goiven a decoding key, s1124 kursboken*/

/*B)
s.336 kursboken
advantages
1. The same database and stored procedures can be used by several applications, reduces duplication and impoves software modularity
2. reduce data transfer and communication cost between client and server
3. enhance modeling powers of views by allowing more complex types of derived data to be made avaliable. Can be used tp
check complex constraints 
*/

/*Question 9 */

/*A)run q7 test code
START TRANSACTION;
then add reservation by  
CALL addReservation("MIT","HOB",2010,2,"Monday","09:00:00",1,@a);
Query OK, 3 rows affected (0,00 sec)

B) NO, they have different output
mysql> SELECT * FROM Reservation;
+-------------------+------------+
| ReservationNumber | FlightNumb |
+-------------------+------------+
|             16673 |          1 |
|             59790 |          1 |
|             77272 |          1 |
|             42147 |          2 |
+-------------------+------------+
4 rows in set (0,00 sec)
+-------------------+------------+
| ReservationNumber | FlightNumb |
+-------------------+------------+
|             16673 |          1 |
|             59790 |          1 |
|             77272 |          1 |
+-------------------+------------+

The changes in terminal A is not visible until the changes are commited 

C) 
In Terminal b we did the below command, to modify the data from terminal a
UPDATE Reservation SET ReservationNumber = 111 WHERE ReservationNumber = 31362;
ERROR 1205 (HY000): Lock wait timeout exceeded; try restarting transaction

This happens because sql automatically adds locks to the rows being modified within a transaction to ensure concurrency
*/

/*Question 10*/

/*a) Session A: 
Source Question10FillWithFlights.sql

+-----------------------+
| Message               |
+-----------------------+
| Testing answer for 10 |
+-----------------------+
1 row in set (0,00 sec)

+---------------------------------------------------------------------------+
| Message                                                                   |
+---------------------------------------------------------------------------+
| Filling database with flights, should only be run in one of the terminals |
+---------------------------------------------------------------------------+
1 row in set (0,00 sec)

I forgot to copy all rows...

Source Question10MakeBooking.sql

+---------------------------------------------------------------------------------+
| Message                                                                         |
+---------------------------------------------------------------------------------+
| Testing script for Question 10, Adds a booking, should be run in both terminals |
+---------------------------------------------------------------------------------+
1 row in set (0,00 sec)

+--------------------------------------+
| Message                              |
+--------------------------------------+
| Adding a reservations and passengers |
+--------------------------------------+
1 row in set (0,00 sec)

Query OK, 3 rows affected (0,00 sec)

Query OK, 5 rows affected (0,02 sec)

Query OK, 5 rows affected (0,01 sec)

Query OK, 5 rows affected (0,02 sec)

Query OK, 5 rows affected (0,01 sec)

Query OK, 5 rows affected (0,01 sec)

Query OK, 5 rows affected (0,01 sec)

Query OK, 5 rows affected (0,00 sec)

Query OK, 5 rows affected (0,02 sec)

Query OK, 5 rows affected (0,01 sec)

Query OK, 5 rows affected (0,01 sec)

Query OK, 5 rows affected (0,00 sec)

Query OK, 5 rows affected (0,01 sec)

Query OK, 5 rows affected (0,01 sec)

Query OK, 5 rows affected (0,01 sec)

Query OK, 5 rows affected (0,01 sec)

Query OK, 5 rows affected (0,01 sec)

Query OK, 5 rows affected (0,01 sec)

Query OK, 5 rows affected (0,01 sec)

Query OK, 5 rows affected (0,01 sec)

Query OK, 5 rows affected (0,01 sec)

Query OK, 5 rows affected (0,01 sec)

Query OK, 3 rows affected (0,00 sec)

+----------+
| SLEEP(5) |
+----------+
|        0 |
+----------+
1 row in set (5,00 sec)

+------------------------------------------------------------------------------+
| Message                                                                      |
+------------------------------------------------------------------------------+
| Making payment, supposed to work for one session and be denied for the other |
+------------------------------------------------------------------------------+
1 row in set (0,00 sec)

Query OK, 34 rows affected (0,02 sec)

+-----------------------------------------------------------------------------------------+------------------+
| Message                                                                                 | nr_of_free_seats |
+-----------------------------------------------------------------------------------------+------------------+
| Nr of free seats on the flight (should be 19 if no overbooking occured, otherwise -2):  |               19 |
+-----------------------------------------------------------------------------------------+------------------+
1 row in set (0,00 sec)

Session B

Source Question10MakeBooking.sql

+---------------------------------------------------------------------------------+
| Message                                                                         |
+---------------------------------------------------------------------------------+
| Testing script for Question 10, Adds a booking, should be run in both terminals |
+---------------------------------------------------------------------------------+
1 row in set (0,01 sec)

+--------------------------------------+
| Message                              |
+--------------------------------------+
| Adding a reservations and passengers |
+--------------------------------------+
1 row in set (0,00 sec)

+----------------------------------------------------------+
| Message                                                  |
+----------------------------------------------------------+
| There exist no flight for the given route, date and time |
+----------------------------------------------------------+
1 row in set (0,00 sec)

Query OK, 2 rows affected (0,00 sec)

+---------------------------------------------+
| Message                                     |
+---------------------------------------------+
| The given reservation number does not exist |
+---------------------------------------------+
1 row in set (0,00 sec)

Query OK, 3 rows affected (0,00 sec)

+---------------------------------------------+
| Message                                     |
+---------------------------------------------+
| The given reservation number does not exist |
+---------------------------------------------+
1 row in set (0,00 sec)

Query OK, 3 rows affected (0,00 sec)

+---------------------------------------------+
| Message                                     |
+---------------------------------------------+
| The given reservation number does not exist |
+---------------------------------------------+
1 row in set (0,00 sec)

Query OK, 3 rows affected (0,00 sec)

+---------------------------------------------+
| Message                                     |
+---------------------------------------------+
| The given reservation number does not exist |
+---------------------------------------------+
1 row in set (0,00 sec)

Query OK, 3 rows affected (0,00 sec)

+---------------------------------------------+
| Message                                     |
+---------------------------------------------+
| The given reservation number does not exist |
+---------------------------------------------+
1 row in set (0,01 sec)

Query OK, 3 rows affected (0,01 sec)

+---------------------------------------------+
| Message                                     |
+---------------------------------------------+
| The given reservation number does not exist |
+---------------------------------------------+
1 row in set (0,00 sec)

Query OK, 3 rows affected (0,00 sec)

+---------------------------------------------+
| Message                                     |
+---------------------------------------------+
| The given reservation number does not exist |
+---------------------------------------------+
1 row in set (0,00 sec)

Query OK, 3 rows affected (0,00 sec)

+---------------------------------------------+
| Message                                     |
+---------------------------------------------+
| The given reservation number does not exist |
+---------------------------------------------+
1 row in set (0,00 sec)

Query OK, 3 rows affected (0,00 sec)

+---------------------------------------------+
| Message                                     |
+---------------------------------------------+
| The given reservation number does not exist |
+---------------------------------------------+
1 row in set (0,00 sec)

Query OK, 3 rows affected (0,00 sec)

+---------------------------------------------+
| Message                                     |
+---------------------------------------------+
| The given reservation number does not exist |
+---------------------------------------------+
1 row in set (0,00 sec)

Query OK, 3 rows affected (0,00 sec)

+---------------------------------------------+
| Message                                     |
+---------------------------------------------+
| The given reservation number does not exist |
+---------------------------------------------+
1 row in set (0,00 sec)

Query OK, 3 rows affected (0,00 sec)

+---------------------------------------------+
| Message                                     |
+---------------------------------------------+
| The given reservation number does not exist |
+---------------------------------------------+
1 row in set (0,00 sec)

Query OK, 3 rows affected (0,00 sec)

+---------------------------------------------+
| Message                                     |
+---------------------------------------------+
| The given reservation number does not exist |
+---------------------------------------------+
1 row in set (0,00 sec)

Query OK, 3 rows affected (0,00 sec)

+---------------------------------------------+
| Message                                     |
+---------------------------------------------+
| The given reservation number does not exist |
+---------------------------------------------+
1 row in set (0,00 sec)

Query OK, 3 rows affected (0,00 sec)

+---------------------------------------------+
| Message                                     |
+---------------------------------------------+
| The given reservation number does not exist |
+---------------------------------------------+
1 row in set (0,00 sec)

Query OK, 3 rows affected (0,00 sec)

+---------------------------------------------+
| Message                                     |
+---------------------------------------------+
| The given reservation number does not exist |
+---------------------------------------------+
1 row in set (0,00 sec)

Query OK, 3 rows affected (0,00 sec)

+---------------------------------------------+
| Message                                     |
+---------------------------------------------+
| The given reservation number does not exist |
+---------------------------------------------+
1 row in set (0,00 sec)

Query OK, 3 rows affected (0,00 sec)

+---------------------------------------------+
| Message                                     |
+---------------------------------------------+
| The given reservation number does not exist |
+---------------------------------------------+
1 row in set (0,00 sec)

Query OK, 3 rows affected (0,00 sec)

+---------------------------------------------+
| Message                                     |
+---------------------------------------------+
| The given reservation number does not exist |
+---------------------------------------------+
1 row in set (0,00 sec)

Query OK, 3 rows affected (0,00 sec)

+---------------------------------------------+
| Message                                     |
+---------------------------------------------+
| The given reservation number does not exist |
+---------------------------------------------+
1 row in set (0,00 sec)

Query OK, 3 rows affected (0,00 sec)

+---------------------------------------------+
| Message                                     |
+---------------------------------------------+
| The given reservation number does not exist |
+---------------------------------------------+
1 row in set (0,01 sec)

Query OK, 3 rows affected (0,01 sec)

+---------------------------------------------+
| Message                                     |
+---------------------------------------------+
| The given reservation number does not exist |
+---------------------------------------------+
1 row in set (0,00 sec)

Query OK, 2 rows affected (0,00 sec)

+----------+
| SLEEP(5) |
+----------+
|        0 |
+----------+
1 row in set (5,00 sec)

+------------------------------------------------------------------------------+
| Message                                                                      |
+------------------------------------------------------------------------------+
| Making payment, supposed to work for one session and be denied for the other |
+------------------------------------------------------------------------------+
1 row in set (0,00 sec)

+----------------------------------------------------------------------------------------+
| Message                                                                                |
+----------------------------------------------------------------------------------------+
| Reservation does not have a contact or there are not enough unpaid seats on the plane. |
+----------------------------------------------------------------------------------------+
1 row in set (0,00 sec)

Query OK, 3 rows affected (0,00 sec)

+-----------------------------------------------------------------------------------------+------------------+
| Message                                                                                 | nr_of_free_seats |
+-----------------------------------------------------------------------------------------+------------------+
| Nr of free seats on the flight (should be 19 if no overbooking occured, otherwise -2):  |               19 |
+-----------------------------------------------------------------------------------------+------------------+
1 row in set (0,00 sec)

Answer: No overbooking occured since the value of the last test in session B was 19 and not -2. This is because session A was ahead of session B which can be shown by the fact that the payment
only when through in session A. Therefore Calculate freeSeats had time to recalculate which made the message show up that there's not enough free seats left in session B.

b) It's technically possible for an overbooking to be made if both sessions read this if statement in addPayment
 before the BookedPassengers is updated which makes the freeSeats for the other session not up to date.
   IF unpaid_seats >= number_passengers AND contact_exists > 0 THEN
        if card_exists = 0 THEN
            INSERT INTO CreditCard(CardNumber, CardHolder) VALUES(credit_card_number, cardholder_name);
        END IF;
        INSERT INTO Booking(ReservationNumb, TotalPrice, CCNumber) VALUES (reservation_nr, calculatePrice(flight_number), credit_card_number);
        UPDATE Flight SET BookedPassenegers = BookedPassenegers + number_passengers WHERE FlightNumber = flight_number;
    ELSE
        SELECT 'Reservation does not have a contact or there are not enough unpaid seats on the plane.' AS Message;
    END IF;

    TILL STEPHANIE: Ska if satsen i addReservation göra så att vi får göra en reservation eller inte????? För testbänken i fråga 6 gör ju iallafall så att vi måste kolla om dte finns tillräckligt med platser.

c)

IF unpaid_seats >= number_passengers AND contact_exists > 0 THEN
        if card_exists = 0 THEN
            INSERT INTO CreditCard(CardNumber, CardHolder) VALUES(credit_card_number, cardholder_name);
        END IF;
        SELECT SLEEP(5); -- add sleep 
        INSERT INTO Booking(ReservationNumb, TotalPrice, CCNumber) VALUES (reservation_nr, calculatePrice(flight_number), credit_card_number);
        UPDATE Flight SET BookedPassenegers = BookedPassenegers + number_passengers WHERE FlightNumber = flight_number;

    ELSE
        SELECT 'Reservation does not have a contact or there are not enough unpaid seats on the plane.' AS Message;
    END IF;

    Answer: Add sleep before updating the bookedpassangers and therefore before updating the free seats. Which makes the theoretical case possible to occur

d) Question10FillWithFlights.sql:

SELECT "Testing answer for 10" as "Message";
SELECT "Filling database with flights, should only be run in one of the terminals" as "Message";
/*Fill the database with data */
CALL addYear(2010, 2.3);
CALL addDay(2010,"Monday",1);
CALL addDestination("MIT","Minas Tirith","Mordor");
CALL addDestination("HOB","Hobbiton","The Shire");
CALL addRoute("MIT","HOB",2010,2000);
CALL addFlight("MIT","HOB", 2010, "Monday", "09:00:00");

Question10MakeBooking.sql:

SELECT "Testing script for Question 10, Adds a booking, should be run in both terminals" as "Message";
SELECT "Adding a reservations and passengers" as "Message";
CALL addReservation("MIT","HOB",2010,1,"Monday","09:00:00",21,@a); 
CALL addPassenger(@a,00000001,"Saruman");
CALL addPassenger(@a,00000002,"Orch1");
CALL addPassenger(@a,00000003,"Orch2");
CALL addPassenger(@a,00000004,"Orch3");
CALL addPassenger(@a,00000005,"Orch4");
CALL addPassenger(@a,00000006,"Orch5");
CALL addPassenger(@a,00000007,"Orch6");
CALL addPassenger(@a,00000008,"Orch7");
CALL addPassenger(@a,00000009,"Orch8");
CALL addPassenger(@a,00000010,"Orch9");
CALL addPassenger(@a,00000011,"Orch10");
CALL addPassenger(@a,00000012,"Orch11");
CALL addPassenger(@a,00000013,"Orch12");
CALL addPassenger(@a,00000014,"Orch13");
CALL addPassenger(@a,00000015,"Orch14");
CALL addPassenger(@a,00000016,"Orch15");
CALL addPassenger(@a,00000017,"Orch16");
CALL addPassenger(@a,00000018,"Orch17");
CALL addPassenger(@a,00000019,"Orch18");
CALL addPassenger(@a,00000020,"Orch19");
CALL addPassenger(@a,00000021,"Orch20");
CALL addContact(@a,00000001,"saruman@magic.mail",080667989); 
SELECT SLEEP(5);

--- New Code --- See Lecture 9

START TRANSACTION;
LOCK TABLES 
Booking WRITE, 
hasTicket, WRITE,
CreditCard, WRITE,
Flight READ,
Reservation READ,
Contact READ;

SELECT "Making payment, supposed to work for one session and be denied for the other" as "Message";
CALL addPayment (@a, "Sauron",7878787878);
SELECT "Nr of free seats on the flight (should be 19 if no overbooking occured, otherwise -2): " as "Message", (SELECT nr_of_free_seats from allFlights where departure_week = 1) as "nr_of_free_seats";

COMMIT;
UNLOCK TABLES;


Answer: A transaction should be added before addPayment since an overbooking is made possible during the sleep time before the Booking is updated. The code locks the tables related to updating the booking and creditcard in either to either read or write
which allows the session that first started the payment to complete it and update calculateFreeseats before the next session can make the payment.*/