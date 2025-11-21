┌───────────────────────┐
│        Users          │
├───────────────────────┤
│ id (PK)               │
│ name                  │
│ email                 │
│ phone                 │
│ user_type (driver/rider) │
│ created_at            │
└───────────────────────┘
           │1
           │
           │*
┌───────────────────────┐
│     RideRequests      │
├───────────────────────┤
│ id (PK)               │
│ user_id (FK→Users.id) │
│ pickup_lat            │
│ pickup_lng            │
│ dropoff_lat           │
│ dropoff_lng           │
│ estimated_price        │
│ estimated_time         │
│ status (pending/accepted/ongoing/completed/cancelled) │
│ created_at            │
└───────────────────────┘
           │1
           │
           │*
┌───────────────────────┐
│    DriverOffers       │
├───────────────────────┤
│ id (PK)               │
│ ride_request_id (FK→RideRequests.id) │
│ driver_id (FK→Users.id) │
│ offered_price          │
│ estimated_time          │
│ status (pending/accepted/rejected) │
│ created_at            │
└───────────────────────┘
           │1
           │
           │*
┌───────────────────────┐
│       Rides           │
├───────────────────────┤
│ id (PK)               │
│ ride_request_id (FK→RideRequests.id) │
│ driver_id (FK→Users.id) │
│ rider_id (FK→Users.id)  │
│ start_time             │
│ end_time               │
│ total_price            │
│ status                 │
│ created_at             │
└───────────────────────┘
           │1
           │
           │1
┌───────────────────────┐
│      Payments         │
├───────────────────────┤
│ id (PK)               │
│ ride_id (FK→Rides.id) │
│ amount                │
│ payment_method        │
│ status                │
│ created_at            │
└───────────────────────┘

┌───────────────────────┐
│      Ratings          │
├───────────────────────┤
│ id (PK)               │
│ ride_id (FK→Rides.id) │
│ rater_id (FK→Users.id)│
│ ratee_id (FK→Users.id)│
│ rating_value          │
│ comment               │
│ created_at            │
└───────────────────────┘
