-- Create chat_messages table for customer support real-time chat
CREATE TABLE IF NOT EXISTS public.chat_messages (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Indexes for better query performance
    CONSTRAINT chat_messages_user_id_fkey FOREIGN KEY (user_id) 
        REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Create index on created_at for ordering messages
CREATE INDEX IF NOT EXISTS idx_chat_messages_created_at 
    ON public.chat_messages(created_at DESC);

-- Create index on user_id for filtering user messages
CREATE INDEX IF NOT EXISTS idx_chat_messages_user_id 
    ON public.chat_messages(user_id);

-- Enable Row Level Security
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

-- Policy: Users can read all messages (for support visibility)
CREATE POLICY "Anyone can read chat messages" 
    ON public.chat_messages 
    FOR SELECT 
    USING (true);

-- Policy: Authenticated users can insert their own messages
CREATE POLICY "Users can insert their own messages" 
    ON public.chat_messages 
    FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own messages (optional, for editing)
CREATE POLICY "Users can update their own messages" 
    ON public.chat_messages 
    FOR UPDATE 
    USING (auth.uid() = user_id);

-- Policy: Users can delete their own messages (optional)
CREATE POLICY "Users can delete their own messages" 
    ON public.chat_messages 
    FOR DELETE 
    USING (auth.uid() = user_id);

-- Enable realtime for this table
ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_messages;

-- Grant permissions
GRANT ALL ON public.chat_messages TO authenticated;
GRANT ALL ON public.chat_messages TO service_role;
