from flask import Flask, render_template ,request, redirect, flash
import mysql.connector

app = Flask(__name__)
app.secret_key = 'your_secret_key'  # For flashing messages

# Database connection
def connect_db():
    conn = mysql.connector.connect('hotel.sql')  # Connect to SQLite
    return conn

# Home route (rendering the HTML page)
@app.route('/')
def index():
    return render_template('index.html')

# Route to handle room booking
@app.route('/book-room', methods=['POST'])
def book_room():
    guest_name = request.form['guestName']
    mobile_no = request.form['mobileNo']
    room_type = request.form['roomType']
    check_in = request.form['checkInDate']
    check_out = request.form['checkOutDate']

    conn = connect_db()
    cursor = conn.cursor()

    # Find an available room based on room_type
    cursor.execute("SELECT room_id FROM Rooms WHERE room_type=? AND availability='Y' LIMIT 1", (room_type,))
    room = cursor.fetchone()

    if room:
        room_id = room[0]
        # Insert booking into Bookings table
        cursor.execute("INSERT INTO Bookings (guest_id, room_id, check_in_date, check_out_date) VALUES (?, ?, ?, ?)",
                       (guest_name, room_id, check_in, check_out))
        # Update room availability
        cursor.execute("UPDATE Rooms SET availability='N' WHERE room_id=?", (room_id,))
        conn.commit()
        flash("Room booked successfully!", "success")
    else:
        flash("No rooms available for the selected type.", "danger")

    conn.close()
    return redirect('/')

# Route to generate a bill
@app.route('/generate-bill', methods=['POST'])
def generate_bill():
    booking_id = request.form['bookingID']

    conn = connect_db()
    cursor = conn.cursor()

    # Get room price and calculate bill
    cursor.execute("""
        SELECT r.price_per_night, (julianday(b.check_out_date) - julianday(b.check_in_date)) AS nights
        FROM Bookings b
        JOIN Rooms r ON b.room_id = r.room_id
        WHERE b.booking_id = ?""", (booking_id,))
    booking = cursor.fetchone()

    if booking:
        price_per_night, nights = booking
        total_amount = price_per_night * nights

        # Insert into Billing table
        cursor.execute("INSERT INTO Billing (booking_id, total_amount) VALUES (?, ?)", (booking_id, total_amount))
        conn.commit()
        flash(f"Bill generated successfully! Total: {total_amount} USD", "success")
    else:
        flash("Booking ID not found", "danger")

    conn.close()
    return redirect('/')

# Route to list guests (you can create a page for this)
@app.route('/guests')
def list_guests():
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM Guests")
    guests = cursor.fetchall()
    conn.close()
    return render_template('guests.html', 'guests=guests') 

if __name__ == '__main__':
    app.run(debug=True)


