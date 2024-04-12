SET foreign_key_checks = 0;
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
ALTER TABLE Route ADD CONSTRAINT fk_routeyear FOREIGN K
EY(RouteYear) REFERENCES Year(Year);
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

    RETURN (route_price * weekday_factor * (booked + 1) / 40 )* profit_factor;
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

    IF flightNumb > 0 AND calculateFreeSeats(flightNumb) <= np THEN /*kan vara  != 0*/
        SET output_reservation_nr = FLOOR(RAND() * 100000);
        INSERT INTO Reservation(ReservationNumber, FlightNumb) VALUES (output_reservation_nr, flightNumb);
    ELSE
        SET output_reservation_nr = 0;
        SELECT 'Incorrect flight details addResrvation ' AS Message;
    END IF;
END;

CREATE Procedure addPassenger(IN reservationnumber INTEGER, IN passNumb INTEGER, IN passname VARCHAR(30))
BEGIN
    INSERT INTO Passenger(PassportNumber, FullName) VALUES (passNumb, passname);
    UPDATE HasTicket SET PassportNumb = passNumb WHERE ReservNumb = reservationnumber;
END;

CREATE PROCEDURE addContact(
    IN reservation_nr INTEGER,
    IN passport_number INTEGER,
    IN email VARCHAR(30),
    IN phone BIGINT)
BEGIN
    DECLARE passenger_exists INTEGER;

    SELECT COUNT(*) INTO passenger_exists FROM HasTicket 
    WHERE ReservNumb = reservation_nr AND PassportNumb = passport_number;

    IF passenger_exists > 0 THEN
        INSERT INTO Contact(PassportNumb, Email, PhoneNumber)
        VALUES (passport_number, email, phone);
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

    SELECT FlightNumb INTO flight_number FROM Reservation WHERE ReservationNumber = reservation_nr; 
    SET unpaid_seats = calculateFreeSeats(flight_number);

    SELECT COUNT(*) INTO contact_exists FROM Contact WHERE PassportNumb IN
            (SELECT PassportNumb FROM HasTicket WHERE ReservNumb = reservation_nr);
            
    IF unpaid_seats > 0 AND contact_exists > 0 THEN

        UPDATE Booking
        SET TotalPrice = calculatePrice(flight_number), CCNumber = credit_card_number
        WHERE ReservationNumb = reservation_nr;

    ELSE
        SELECT 'Reservation does not have a contact or there are not enough unpaid seats on the plane.' AS Message;
    END IF;

END;
//
delimiter ;