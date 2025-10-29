-- Migration script from postgres_changes to broadcast pattern
-- This helps migrate existing applications using postgres_changes to the more scalable broadcast pattern

-- Step 1: Create broadcast trigger functions for your tables
-- Example for a 'messages' table:
CREATE OR REPLACE FUNCTION messages_broadcast_trigger()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM realtime.broadcast_changes(
    'messages:' || COALESCE(NEW.room_id, OLD.room_id)::text,
    TG_OP,
    TG_OP,
    TG_TABLE_NAME,
    TG_TABLE_SCHEMA,
    NEW,
    OLD
  );
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 2: Create triggers on your tables
CREATE TRIGGER messages_broadcast_trigger
  AFTER INSERT OR UPDATE OR DELETE ON messages
  FOR EACH ROW EXECUTE FUNCTION messages_broadcast_trigger();

-- Step 3: Create RLS policies for private channels
-- Allow authenticated users to read broadcasts
CREATE POLICY "users_can_receive_broadcasts" ON realtime.messages
  FOR SELECT TO authenticated
  USING (
    -- Add your authorization logic here
    -- Example: Check if user is a member of the room
    topic LIKE 'messages:%' AND
    EXISTS (
      SELECT 1 FROM room_members
      WHERE user_id = auth.uid()
      AND room_id = SPLIT_PART(topic, ':', 2)::uuid
    )
  );

-- Step 4: Create necessary indexes for RLS performance
CREATE INDEX idx_room_members_lookup ON room_members(user_id, room_id);

-- Step 5: Update client code (see migration guide in docs)
-- OLD:
-- supabase.channel('changes')
--   .on('postgres_changes', { event: '*', schema: 'public', table: 'messages' }, callback)
--
-- NEW:
-- supabase.channel('messages:room_id', { config: { private: true } })
--   .on('broadcast', { event: 'INSERT' }, callback)
--   .on('broadcast', { event: 'UPDATE' }, callback)
--   .on('broadcast', { event: 'DELETE' }, callback)

-- Optional: Clean up old postgres_changes subscriptions
-- This is handled automatically by updating client code
