-- Create ratings table for driver ratings
CREATE TABLE IF NOT EXISTS public.ratings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    driver_id UUID NOT NULL REFERENCES public.drivers(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    ride_id UUID NOT NULL REFERENCES public.rides(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_ratings_driver_id ON public.ratings(driver_id);
CREATE INDEX IF NOT EXISTS idx_ratings_user_id ON public.ratings(user_id);
CREATE INDEX IF NOT EXISTS idx_ratings_ride_id ON public.ratings(ride_id);

-- Enable Row Level Security
ALTER TABLE public.ratings ENABLE ROW LEVEL SECURITY;

-- Policy: Users can insert their own ratings
CREATE POLICY "Users can insert their own ratings"
    ON public.ratings
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can view all ratings
CREATE POLICY "Anyone can view ratings"
    ON public.ratings
    FOR SELECT
    TO authenticated
    USING (true);

-- Policy: Users can update their own ratings
CREATE POLICY "Users can update their own ratings"
    ON public.ratings
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Add trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_ratings_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ratings_updated_at
    BEFORE UPDATE ON public.ratings
    FOR EACH ROW
    EXECUTE FUNCTION update_ratings_updated_at();
