CREATE DATABASE hotel;

USE HOTEL;

-- Creating Guests table
CREATE TABLE Guests (
    guest_id NUMBER(10) PRIMARY KEY,
    guest_name VARCHAR2(100 CHAR),
    mobile_no VARCHAR2(15 CHAR),
    address VARCHAR2(255 CHAR)
);

-- Creating Rooms table
CREATE TABLE Rooms (
    room_id NUMBER(10) PRIMARY KEY,
    room_type VARCHAR2(50 CHAR),
    price_per_night NUMBER(10, 2),
    availability CHAR(1) CHECK (availability IN ('Y', 'N')) -- Y for available, N for unavailable
);

-- Creating Bookings table
CREATE TABLE Bookings (
    booking_id NUMBER(10) PRIMARY KEY,
    guest_id NUMBER(10),
    room_id NUMBER(10),
    check_in_date DATE,
    check_out_date DATE,
    FOREIGN KEY (guest_id) REFERENCES Guests(guest_id),
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id)
);

-- Creating Billing table
CREATE TABLE Billing (
    bill_id NUMBER(10) PRIMARY KEY,
    booking_id NUMBER(10),
    total_amount NUMBER(12, 2),
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id)
);

-- Procedure to add a guest
CREATE OR REPLACE PROCEDURE add_guest(
    p_guest_id IN NUMBER,
    p_guest_name IN VARCHAR2,
    p_mobile_no IN VARCHAR2,
    p_address IN VARCHAR2
)
IS
BEGIN
    INSERT INTO Guests (guest_id, guest_name, mobile_no, address)
    VALUES (p_guest_id, p_guest_name, p_mobile_no, p_address);

    DBMS_OUTPUT.PUT_LINE('Guest added successfully');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error adding guest: ' || SQLERRM);
END;
/

-- Procedure to book a room
CREATE OR REPLACE PROCEDURE book_room(
    p_booking_id IN NUMBER,
    p_guest_id IN NUMBER,
    p_room_id IN NUMBER,
    p_check_in_date IN DATE,
    p_check_out_date IN DATE
)
IS
    v_availability CHAR(1);
BEGIN
    -- Check if the room is available
    SELECT availability INTO v_availability 
    FROM Rooms 
    WHERE room_id = p_room_id;

    IF v_availability = 'Y' THEN
        -- Insert booking information
        INSERT INTO Bookings (booking_id, guest_id, room_id, check_in_date, check_out_date)
        VALUES (p_booking_id, p_guest_id, p_room_id, p_check_in_date, p_check_out_date);

        -- Update room availability
        UPDATE Rooms
        SET availability = 'N'
        WHERE room_id = p_room_id;

        DBMS_OUTPUT.PUT_LINE('Room booked successfully');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Room is not available');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Room ID not found');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error booking room: ' || SQLERRM);
END;
/

-- Procedure to generate a bill
CREATE OR REPLACE PROCEDURE generate_bill(
    p_booking_id IN NUMBER,
    p_bill_id IN NUMBER
)
IS
    v_room_id NUMBER;
    v_check_in_date DATE;
    v_check_out_date DATE;
    v_price_per_night NUMBER(10, 2);
    v_total_nights NUMBER;
    v_total_amount NUMBER(12, 2);
BEGIN
    -- Get booking details
    SELECT room_id, check_in_date, check_out_date 
    INTO v_room_id, v_check_in_date, v_check_out_date
    FROM Bookings
    WHERE booking_id = p_booking_id;

    -- Get room price
    SELECT price_per_night
    INTO v_price_per_night
    FROM Rooms
    WHERE room_id = v_room_id;

    -- Calculate total nights
    v_total_nights := v_check_out_date - v_check_in_date;

    -- Calculate total amount
    v_total_amount := v_total_nights * v_price_per_night;

    -- Insert billing information
    INSERT INTO Billing (bill_id, booking_id, total_amount)
    VALUES (p_bill_id, p_booking_id, v_total_amount);

    DBMS_OUTPUT.PUT_LINE('Billing generated successfully: Total Amount = ' || v_total_amount);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Booking ID not found');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error generating bill: ' || SQLERRM);
END;
/

-- Procedure to check out guest
CREATE OR REPLACE PROCEDURE checkout_guest(
    p_room_id IN NUMBER
)
IS
BEGIN
    -- Update room availability to 'Y' when guest checks out
    UPDATE Rooms
    SET availability = 'Y'
    WHERE room_id = p_room_id;

    DBMS_OUTPUT.PUT_LINE('Guest checked out, room is now available');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error during checkout: ' || SQLERRM);
END;
/

