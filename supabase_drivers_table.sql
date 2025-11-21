-- Optional: Create drivers table for more realistic simulation
-- Run this in your Supabase SQL Editor if you want to store actual drivers

-- Create the drivers table
CREATE TABLE IF NOT EXISTS drivers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE,
    phone TEXT,
    avatar TEXT,
    rating DOUBLE PRECISION DEFAULT 4.5,
    total_reviews INTEGER DEFAULT 0,
    vehicle_type TEXT DEFAULT 'Standard',
    license_plate TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    is_available BOOLEAN DEFAULT true,
    is_online BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_drivers_location ON drivers(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_drivers_available ON drivers(is_available, is_online);
CREATE INDEX IF NOT EXISTS idx_drivers_rating ON drivers(rating);

-- Add RLS policies
ALTER TABLE drivers ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view available drivers
CREATE POLICY "Anyone can view available drivers" ON drivers
    FOR SELECT USING (is_available = true AND is_online = true);

-- Policy: Drivers can update their own profile
CREATE POLICY "Drivers can update own profile" ON drivers
    FOR UPDATE USING (auth.uid()::text = id::text);

-- Insert some sample drivers for testing
INSERT INTO drivers (name, avatar, rating, total_reviews, vehicle_type, license_plate, latitude, longitude, is_available, is_online)
VALUES 
    ('Sergio Ramasis', 'https://i.pravatar.cc/150?img=1', 4.9, 231, 'Premium', 'AB-123-CD', 41.7151, 44.8271, true, true),
    ('David Tsintsadze', 'https://i.pravatar.cc/150?img=2', 4.8, 189, 'Standard', 'EF-456-GH', 41.7251, 44.8371, true, true),
    ('Giorgi Beridze', 'https://i.pravatar.cc/150?img=3', 4.7, 156, 'Economy', 'IJ-789-KL', 41.7051, 44.8171, true, true),
    ('Nino Kvaratskhelia', 'https://i.pravatar.cc/150?img=4', 4.6, 134, 'Standard', 'MN-012-OP', 41.7351, 44.8471, true, false),
    ('Levan Nakaidze', 'https://i.pravatar.cc/150?img=5', 4.8, 198, 'Premium', 'QR-345-ST', 41.6951, 44.8071, false, true);

-- Add driver_id column to trip_requests table to link orders with drivers
ALTER TABLE trip_requests ADD COLUMN IF NOT EXISTS driver_id UUID REFERENCES drivers(id);

-- Create index for driver assignments
CREATE INDEX IF NOT EXISTS idx_trip_requests_driver ON trip_requests(driver_id);