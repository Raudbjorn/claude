-- Generic broadcast trigger function for Supabase Realtime
-- This trigger broadcasts changes to topics based on table name and row ID
-- Usage: CREATE TRIGGER <name> AFTER INSERT OR UPDATE OR DELETE ON <table> FOR EACH ROW EXECUTE FUNCTION notify_table_changes();

CREATE OR REPLACE FUNCTION notify_table_changes()
RETURNS TRIGGER AS $$
BEGIN
  -- Broadcast to topic pattern: table_name:row_id
  PERFORM realtime.broadcast_changes(
    TG_TABLE_NAME || ':' || COALESCE(NEW.id, OLD.id)::text,
    TG_OP,  -- INSERT, UPDATE, or DELETE
    TG_OP,  -- Event name (same as operation)
    TG_TABLE_NAME,
    TG_TABLE_SCHEMA,
    NEW,    -- New row data (null on DELETE)
    OLD     -- Old row data (null on INSERT)
  );
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Example: Room-specific broadcast trigger
CREATE OR REPLACE FUNCTION room_messages_broadcast_trigger()
RETURNS TRIGGER AS $$
BEGIN
  -- Broadcast to room-specific topic
  PERFORM realtime.broadcast_changes(
    'room:' || COALESCE(NEW.room_id, OLD.room_id)::text || ':messages',
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

-- Conditional broadcasting example
CREATE OR REPLACE FUNCTION notify_significant_changes()
RETURNS TRIGGER AS $$
BEGIN
  -- Only broadcast if status changed
  IF TG_OP = 'UPDATE' AND OLD.status IS DISTINCT FROM NEW.status THEN
    PERFORM realtime.broadcast_changes(
      'entity:' || NEW.id::text || ':status',
      TG_OP,
      'status_changed',  -- Custom event name
      TG_TABLE_NAME,
      TG_TABLE_SCHEMA,
      NEW,
      OLD
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Custom event broadcasting (not tied to table changes)
CREATE OR REPLACE FUNCTION notify_custom_event(
  topic text,
  event text,
  payload jsonb
)
RETURNS void AS $$
BEGIN
  PERFORM realtime.send(topic, event, payload, false);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
