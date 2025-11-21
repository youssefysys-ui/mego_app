-- Create coupons table for user discount coupons
CREATE TABLE IF NOT EXISTS public.coupons (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL,
    type TEXT NOT NULL,
    valid_until TIMESTAMP WITH TIME ZONE NOT NULL,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Foreign key constraint
    CONSTRAINT coupons_user_id_fkey FOREIGN KEY (user_id) 
        REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_coupons_user_id 
    ON public.coupons(user_id);

CREATE INDEX IF NOT EXISTS idx_coupons_active 
    ON public.coupons(active);

CREATE INDEX IF NOT EXISTS idx_coupons_valid_until 
    ON public.coupons(valid_until);

CREATE INDEX IF NOT EXISTS idx_coupons_created_at 
    ON public.coupons(created_at DESC);

-- Enable Row Level Security
ALTER TABLE public.coupons ENABLE ROW LEVEL SECURITY;

-- Policy: Users can read their own coupons
CREATE POLICY "Users can read their own coupons" 
    ON public.coupons 
    FOR SELECT 
    USING (auth.uid() = user_id);

-- Policy: Only service role can insert coupons (admin/system)
CREATE POLICY "Service role can insert coupons" 
    ON public.coupons 
    FOR INSERT 
    WITH CHECK (auth.role() = 'service_role');

-- Policy: Users can update their own coupons (deactivate)
CREATE POLICY "Users can update their own coupons" 
    ON public.coupons 
    FOR UPDATE 
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policy: Only service role can delete coupons
CREATE POLICY "Service role can delete coupons" 
    ON public.coupons 
    FOR DELETE 
    USING (auth.role() = 'service_role');

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update updated_at on row update
CREATE TRIGGER update_coupons_updated_at
    BEFORE UPDATE ON public.coupons
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Grant permissions
GRANT SELECT, UPDATE ON public.coupons TO authenticated;
GRANT ALL ON public.coupons TO service_role;

-- Insert sample coupons for testing (optional)
-- Replace 'USER_UUID_HERE' with actual user ID
/*
INSERT INTO public.coupons (user_id, type, coupon_for, valid_until, active) VALUES
    -- Client-specific coupons (only visible to specific user)
    ('USER_UUID_HERE', 'DISCOUNT_10', 'client', NOW() + INTERVAL '30 days', true),
    ('USER_UUID_HERE', 'DISCOUNT_20', 'client', NOW() + INTERVAL '7 days', true),
    ('USER_UUID_HERE', 'FLAT_100', 'client', NOW() + INTERVAL '60 days', true),
    
    -- All-users coupons (visible to everyone)
    ('system-user-id', 'FREE_RIDE', 'all', NOW() + INTERVAL '15 days', true),
    ('system-user-id', 'FLAT_50', 'all', NOW() + INTERVAL '10 days', true),
    ('system-user-id', 'DISCOUNT_50', 'all', NOW() + INTERVAL '5 days', true);
*/
