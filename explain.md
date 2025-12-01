# MEGO Client App - Functional Overview

This document explains **what your app does** and **how its features work**, based on the current codebase structure and logic.

## 📱 App Purpose
MEGO is a **ride-hailing application** (similar to Uber, Bolt, or inDrive) that allows users to book rides.
**Key Unique Feature**: It appears to use a **negotiation/bidding model** (like inDrive), where users can adjust the offered fare before requesting a ride, and then receive offers from drivers.

---

## 🚀 Key Features & User Flow

### 1. Authentication (Login)
- **Methods**: Users can sign in using **Phone Number** (via Firebase OTP) or **Google Sign-In**.
- **Data Sync**: After authentication, the app checks if the user exists in your **Supabase** database.
  - If yes: Logs them in.
  - If no: Directs them to a "Complete Profile" screen to enter their name/details.

### 2. Home & Map
- The main screen shows a **Google Map** centered on the user's location.
- Users can see available cars (likely simulated or real-time from Supabase) and select their destination.

### 3. Booking a Ride (The Core Flow)
This is the most complex part of your app:

1.  **Search & Calculation**:
    - User selects a Pickup and Destination.
    - The app calculates the **Distance**, **Estimated Time**, and a **Recommended Fare**.
    - *Code Reference*: `features/search_places & calculation`

2.  **Confirm & Adjust Fare**:
    - The user sees the route on the map.
    - **Unique Feature**: The user can **Increase** or **Decrease** the fare price from the recommended amount. This suggests you are building a model where the user proposes a price.
    - User selects Payment Method (Cash or Card).
    - *Code Reference*: `features/confirm_ride`

3.  **Finding Drivers & Offers**:
    - Once confirmed, the request is sent to the server.
    - The user is taken to the **Drivers Offers** screen.
    - Here, the user likely waits to see drivers who accept the ride or offer their own prices.
    - *Code Reference*: `features/drivers_offers`

### 4. On The Ride
- **Tracking**: Once a driver is accepted, the app switches to a tracking mode where the user can see the driver's location in real-time.
- **Status Updates**: The app handles states like `Arrived`, `In Progress`, `Completed`.
- *Code Reference*: `features/ride_accept_track` and `features/trip_tracking...`

### 5. Post-Ride
- **Rating**: User can rate the driver.
- **History**: The ride is saved to the `history_trips` section.

### 6. Wallet & Payments
- Users have a digital wallet.
- They can likely see their balance, add funds, or pay for rides using wallet credit.
- *Code Reference*: `features/wallet`

---

## ⚙️ Technical Summary for You
- **State Management**: You are using **GetX** for everything (Navigation, Logic, Dependency Injection).
- **Backend**:
  - **Supabase**: Your main database (Users, Rides, Offers, Wallet).
  - **Firebase**: Used specifically for Phone Authentication.
- **Maps**: Google Maps Flutter package.

## 💡 How it works "Under the Hood"
1.  **View**: The UI (screens) calls the **Controller**.
2.  **Controller**: Handles the logic (e.g., "User clicked Login"). It calls the **Repository**.
3.  **Repository**: Talks to **Supabase** to save/fetch data.
4.  **Supabase**: Returns the data, which goes back up the chain to update the UI.
