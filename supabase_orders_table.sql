-- Supabase SQL for Orders Table
-- Run this in your Supabase SQL Editor

-- Create the orders table
CREATE TABLE IF NOT EXISTS orders (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id TEXT NOT NULL,
    from_name TEXT NOT NULL,
    from_address TEXT NOT NULL,
    from_latitude DOUBLE PRECISION NOT NULL,
    from_longitude DOUBLE PRECISION NOT NULL,
    to_name TEXT NOT NULL,
    to_address TEXT NOT NULL,
    to_latitude DOUBLE PRECISION NOT NULL,
    to_longitude DOUBLE PRECISION NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    estimated_price DOUBLE PRECISION,
    distance DOUBLE PRECISION,
    estimated_duration INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_orders_updated_at 
    BEFORE UPDATE ON orders 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Add Row Level Security (RLS) policies
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own orders
CREATE POLICY "Users can view own orders" ON orders
    FOR SELECT USING (user_id = current_setting('request.jwt.claims', true)::json->>'sub');

-- Policy: Users can only insert their own orders
CREATE POLICY "Users can insert own orders" ON orders
    FOR INSERT WITH CHECK (user_id = current_setting('request.jwt.claims', true)::json->>'sub');

-- Policy: Users can only update their own orders
CREATE POLICY "Users can update own orders" ON orders
    FOR UPDATE USING (user_id = current_setting('request.jwt.claims', true)::json->>'sub');

-- Policy: Users can only delete their own orders (optional)
CREATE POLICY "Users can delete own orders" ON orders
    FOR DELETE USING (user_id = current_setting('request.jwt.claims', true)::json->>'sub');

-- Insert some sample data for testing (optional)
-- Note: Replace 'test-user-123' with actual user IDs from your auth system
/*
INSERT INTO orders (user_id, from_name, from_address, from_latitude, from_longitude, 
                   to_name, to_address, to_latitude, to_longitude, status, estimated_price, distance, estimated_duration)
VALUES 
    ('123', 'Home', '123 Main St', 41.7151, 44.8271, 'Office', '456 Business Ave', 41.7251, 44.8371, 'pending', 15.50, 8.5, 25),
    ('123', 'Mall', '789 Shopping Center', 41.7051, 44.8171, 'Airport', 'Tbilisi International Airport', 41.6692, 44.9547, 'completed', 45.00, 28.2, 35);
*/