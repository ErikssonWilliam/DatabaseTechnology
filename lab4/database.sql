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
    PassengerPassportNumb INTEGER,
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
   (FlightNumber INTEGER,
    Week INTEGER,
    BookedPassenegers INTEGER,
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
ALTER TABLE Booking ADD CONSTRAINT fk_bookingpassportnumber FOREIGN KEY(PassengerPassportNumb) REFERENCES Passenger(PassportNumber);
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

/*Question 3 */

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
	INSERT INTO WeeklySchedule (DepartureTime, RouteId, WsDay, WsYear)  VALUES (t, (SELECT 	 RouteID FROM Route WHERE DepartureID = dc AND ArrivesID = ac AND RouteYear = y), d, y);
	
	DECLARE schedule_id INT = LAST_INSERT_ID();
	DECLARE w INT = 1;
	WHILE w <= 52 DO
		INSERT INTO Flight(Week, WsID) VALUES (w, schedule_id);
		SET w = w + 1;
	END WHILE;
END;

//
delimiter ;
