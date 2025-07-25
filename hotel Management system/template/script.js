// Function to generate a random ID for booking and billing
function generateRandomID(prefix) {
    return prefix + Math.floor(100000 + Math.random() * 900000); // 6-digit random number
}

// Booking Form Submission
document.getElementById('bookingForm').addEventListener('submit', function(event) {
    event.preventDefault();
    
    const guestName = document.getElementById('guestName').value;
    const mobileNo = document.getElementById('mobileNo').value;
    const roomType = document.getElementById('roomType').value;
    const checkInDate = document.getElementById('checkInDate').value;
    const checkOutDate = document.getElementById('checkOutDate').value;

    const bookingID = generateRandomID("BID-");

    // Display booking details
    const bookingResultDiv = document.getElementById('bookingResult');
    bookingResultDiv.innerHTML = `
        <h3>Booking Confirmation</h3>
        <p><strong>Booking ID:</strong> ${bookingID}</p>
        <p><strong>Guest Name:</strong> ${guestName}</p>
        <p><strong>Room Type:</strong> ${roomType}</p>
        <p><strong>Check-in Date:</strong> ${checkInDate}</p>
        <p><strong>Check-out Date:</strong> ${checkOutDate}</p>
    `;
    bookingResultDiv.style.display = 'block';
});

// Billing Form Submission
document.getElementById('billingForm').addEventListener('submit', function(event) {
    event.preventDefault();
    
    const bookingID = document.getElementById('bookingID').value;

    // Assume a fixed rate per room type (this could be enhanced with actual room rates)
    const totalBill = Math.floor(Math.random() * 10000); // Random bill amount for now

    // Display billing details
    const billingResultDiv = document.getElementById('billingResult');
    billingResultDiv.innerHTML = `
        <h3>Billing Details</h3>
        <p><strong>Booking ID:</strong> ${bookingID}</p>
        <p><strong>Total Amount:</strong> $${totalBill}</p>
    `;
    billingResultDiv.style.display = 'block';
});
