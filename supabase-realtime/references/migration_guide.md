# Migration Guide: postgres_changes to broadcast

## Overview
This guide helps migrate from `postgres_changes` to the more scalable `broadcast` pattern.

## Why Migrate?

### postgres_changes Limitations
- Single-threaded processing
- Limited scalability
- No custom payloads
- All-or-nothing filtering
- Performance degradation with scale

### broadcast Advantages
- Multi-threaded processing
- Highly scalable
- Custom payloads
- Granular topic filtering
- Better performance

## Step-by-Step Migration

### Step 1: Identify Current Usage
Audit your current postgres_changes subscriptions:

```javascript
// Current postgres_changes pattern
supabase.channel('db-changes')
  .on('postgres_changes', {
    event: 'INSERT',
    schema: 'public',
    table: 'messages',
    filter: 'room_id=eq.123'
  }, handleInsert)
  .on('postgres_changes', {
    event: 'UPDATE',
    schema: 'public',
    table: 'messages'
  }, handleUpdate)
  .subscribe()
```

### Step 2: Create Database Triggers
Replace with broadcast triggers:

```sql
-- Create broadcast function
CREATE OR REPLACE FUNCTION broadcast_messages_changes()
RETURNS TRIGGER AS $$
BEGIN
  -- Custom topic based on room_id
  PERFORM realtime.broadcast_changes(
    'room:' || COALESCE(NEW.room_id, OLD.room_id)::text || ':messages',
    TG_OP,
    CASE 
      WHEN TG_OP = 'INSERT' THEN 'message_created'
      WHEN TG_OP = 'UPDATE' THEN 'message_updated'
      WHEN TG_OP = 'DELETE' THEN 'message_deleted'
    END,
    TG_TABLE_NAME,
    TG_TABLE_SCHEMA,
    NEW,
    OLD
  );
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger
CREATE TRIGGER messages_broadcast
  AFTER INSERT OR UPDATE OR DELETE ON messages
  FOR EACH ROW EXECUTE FUNCTION broadcast_messages_changes();
```

### Step 3: Update Client Code

#### Before (postgres_changes):
```javascript
const channel = supabase.channel('db-changes')
  .on('postgres_changes', {
    event: '*',
    schema: 'public',
    table: 'messages',
    filter: `room_id=eq.${roomId}`
  }, (payload) => {
    console.log('Change:', payload.eventType, payload.new)
  })
  .subscribe()
```

#### After (broadcast):
```javascript
const channel = supabase.channel(`room:${roomId}:messages`, {
  config: { private: true }
})
  .on('broadcast', { event: 'message_created' }, (payload) => {
    console.log('New message:', payload.new)
  })
  .on('broadcast', { event: 'message_updated' }, (payload) => {
    console.log('Updated message:', payload.new)
  })
  .on('broadcast', { event: 'message_deleted' }, (payload) => {
    console.log('Deleted message:', payload.old)
  })
  .subscribe()
```

### Step 4: Add Authorization
Create RLS policies for private channels:

```sql
-- Read policy
CREATE POLICY "can_read_room_broadcasts" ON realtime.messages
FOR SELECT TO authenticated
USING (
  topic LIKE 'room:%:messages' AND
  auth.uid() IN (
    SELECT user_id FROM room_members 
    WHERE room_id = SPLIT_PART(topic, ':', 2)::uuid
  )
);

-- Write policy (if allowing client broadcasts)
CREATE POLICY "can_write_room_broadcasts" ON realtime.messages
FOR INSERT TO authenticated
USING (
  topic LIKE 'room:%:messages' AND
  auth.uid() IN (
    SELECT user_id FROM room_members 
    WHERE room_id = SPLIT_PART(topic, ':', 2)::uuid
  )
);
```

### Step 5: Parallel Testing
Run both patterns in parallel during migration:

```javascript
// Temporary parallel implementation
const pgChannel = supabase.channel('postgres-test')
  .on('postgres_changes', { /* ... */ }, (payload) => {
    console.log('[PG]', payload)
  })

const broadcastChannel = supabase.channel('room:123:test', {
  config: { private: true }
})
  .on('broadcast', { event: 'INSERT' }, (payload) => {
    console.log('[BC]', payload)
  })

// Compare outputs to ensure parity
```

## Common Migration Patterns

### Pattern 1: User-Specific Notifications
```javascript
// Before
.on('postgres_changes', {
  event: 'INSERT',
  schema: 'public',
  table: 'notifications',
  filter: `user_id=eq.${userId}`
}, handler)

// After
channel(`user:${userId}:notifications`)
  .on('broadcast', { event: 'notification_created' }, handler)
```

### Pattern 2: Global Updates
```javascript
// Before
.on('postgres_changes', {
  event: 'UPDATE',
  schema: 'public',
  table: 'settings'
}, handler)

// After
channel('global:settings')
  .on('broadcast', { event: 'settings_updated' }, handler)
```

### Pattern 3: Filtered Table Changes
```javascript
// Before
.on('postgres_changes', {
  event: '*',
  schema: 'public',
  table: 'orders',
  filter: 'status=eq.pending'
}, handler)

// After - Use conditional trigger
CREATE TRIGGER pending_orders_broadcast
  AFTER INSERT OR UPDATE ON orders
  FOR EACH ROW 
  WHEN (NEW.status = 'pending')
  EXECUTE FUNCTION broadcast_order_changes();
```

## Rollback Strategy

Keep triggers non-destructive during migration:

```sql
-- Safe to run alongside postgres_changes
CREATE OR REPLACE FUNCTION safe_broadcast()
RETURNS TRIGGER AS $$
BEGIN
  -- Only broadcast if feature flag is enabled
  IF current_setting('app.enable_broadcast', true) = 'true' THEN
    PERFORM realtime.broadcast_changes(/* ... */);
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Enable/disable via SQL
SET app.enable_broadcast = 'true';
```

## Testing Checklist

- [ ] All events are captured correctly
- [ ] Payload structure matches requirements
- [ ] Authorization works as expected
- [ ] Performance meets requirements
- [ ] Error handling is robust
- [ ] Cleanup/unsubscribe works properly

## Troubleshooting

### Missing Events
- Check trigger is created and enabled
- Verify RLS policies allow access
- Ensure `private: true` is set
- Check auth token is valid

### Performance Issues
- Create indexes for RLS policies
- Use specific topic names
- Minimize payload size
- Consider sharding high-volume topics

### Authorization Errors
- Verify auth.uid() is set
- Check RLS policy conditions
- Test with `supabase.realtime.setAuth()`
- Enable debug logging
