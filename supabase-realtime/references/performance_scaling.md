# Performance & Scaling Guide

## Topic Design for Scale

### Granular Topics Pattern
Divide topics by logical boundaries to minimize unnecessary message delivery:

```javascript
// ❌ Bad: All users receive all notifications
const channel = supabase.channel('global:notifications')

// ✅ Good: Only relevant users receive notifications
const channel = supabase.channel(`user:${userId}:notifications`)
const channel = supabase.channel(`org:${orgId}:alerts`)
const channel = supabase.channel(`room:${roomId}:messages`)
```

### Topic Sharding for High Volume
For extremely high-volume topics, implement sharding:

```javascript
// Shard by user ID
const shardId = userId % 10
const channel = supabase.channel(`notifications:shard:${shardId}`)

// Shard by geographic region
const channel = supabase.channel(`events:region:${region}`)

// Time-based sharding
const hour = new Date().getHours()
const channel = supabase.channel(`logs:hour:${hour}`)
```

## Database Optimization

### Critical Indexes
Create indexes for all columns used in RLS policies:

```sql
-- Single column index
CREATE INDEX idx_user_id ON room_members(user_id);

-- Composite index for common queries
CREATE INDEX idx_user_room ON room_members(user_id, room_id);

-- Partial index for specific conditions
CREATE INDEX idx_active_users ON users(id) WHERE is_active = true;

-- Expression index for computed values
CREATE INDEX idx_topic_room_id ON realtime.messages(SPLIT_PART(topic, ':', 2));
```

### RLS Policy Optimization
Write efficient RLS policies that leverage indexes:

```sql
-- ✅ Good: Uses indexed columns directly
CREATE POLICY "efficient_policy" ON realtime.messages
FOR SELECT USING (
  topic LIKE 'room:%' AND
  EXISTS (
    SELECT 1 FROM room_members
    WHERE user_id = auth.uid()
    AND room_id = SPLIT_PART(topic, ':', 2)::uuid
    LIMIT 1  -- Stop at first match
  )
);

-- ❌ Bad: Function calls prevent index usage
CREATE POLICY "inefficient_policy" ON realtime.messages
FOR SELECT USING (
  LOWER(topic) LIKE 'room:%' AND  -- Function prevents index
  topic IN (SELECT get_user_topics(auth.uid()))  -- Subquery without limit
);
```

## Connection Pool Management

### Configure Database Pool Size
Adjust in Realtime Settings:
- Small apps: 10-20 connections
- Medium apps: 50-100 connections
- Large apps: 200+ connections

### Monitor Connection Usage
```sql
-- Check current connections
SELECT count(*) FROM pg_stat_activity 
WHERE datname = current_database();

-- Identify connection sources
SELECT application_name, count(*) 
FROM pg_stat_activity 
GROUP BY application_name;
```

## Payload Optimization

### Minimize Broadcast Payloads
```javascript
// ❌ Bad: Sending entire objects
channel.send({
  type: 'broadcast',
  event: 'user_updated',
  payload: entireUserObject  // 10KB of data
})

// ✅ Good: Send only changes
channel.send({
  type: 'broadcast',
  event: 'user_updated',
  payload: {
    id: userId,
    changes: { status: 'online' }  // 100 bytes
  }
})
```

### Batch Updates When Possible
```javascript
// Instead of multiple broadcasts
const batchUpdate = {
  type: 'broadcast',
  event: 'batch_update',
  payload: {
    updates: [
      { id: 1, status: 'online' },
      { id: 2, status: 'away' },
      { id: 3, status: 'offline' }
    ]
  }
}
channel.send(batchUpdate)
```

## Client-Side Optimization

### Debounce High-Frequency Updates
```javascript
import { debounce } from 'lodash'

const sendTypingStatus = debounce((isTyping) => {
  channel.send({
    type: 'broadcast',
    event: 'typing_status',
    payload: { userId, isTyping }
  })
}, 300)  // Max 1 update per 300ms
```

### Implement Message Queuing
```javascript
class MessageQueue {
  constructor(channel, maxBatchSize = 10, flushInterval = 100) {
    this.channel = channel
    this.queue = []
    this.maxBatchSize = maxBatchSize
    this.flushInterval = flushInterval
    this.timer = null
  }

  send(event, payload) {
    this.queue.push({ event, payload })
    
    if (this.queue.length >= this.maxBatchSize) {
      this.flush()
    } else if (!this.timer) {
      this.timer = setTimeout(() => this.flush(), this.flushInterval)
    }
  }

  flush() {
    if (this.queue.length === 0) return
    
    this.channel.send({
      type: 'broadcast',
      event: 'batch_message',
      payload: this.queue
    })
    
    this.queue = []
    clearTimeout(this.timer)
    this.timer = null
  }
}
```

## Monitoring & Debugging

### Performance Metrics
```javascript
// Track message latency
const startTime = Date.now()

channel.send({
  type: 'broadcast',
  event: 'ping',
  payload: { timestamp: startTime }
}).then(() => {
  const latency = Date.now() - startTime
  console.log(`Broadcast latency: ${latency}ms`)
})

// Monitor subscription time
const subscribeStart = Date.now()
channel.subscribe((status) => {
  if (status === 'SUBSCRIBED') {
    console.log(`Subscribe time: ${Date.now() - subscribeStart}ms`)
  }
})
```

### Debug Slow Queries
```sql
-- Find slow RLS policy checks
SELECT 
  query,
  total_time,
  mean_time,
  calls
FROM pg_stat_statements
WHERE query LIKE '%realtime.messages%'
ORDER BY mean_time DESC
LIMIT 10;

-- Analyze policy performance
EXPLAIN ANALYZE
SELECT * FROM realtime.messages
WHERE topic = 'room:123'
AND (SELECT auth.uid()) IS NOT NULL;
```

## Scaling Checklist

1. **Database Layer**
   - ✅ Create indexes for all RLS policy columns
   - ✅ Optimize RLS policies for performance
   - ✅ Configure appropriate connection pool size
   - ✅ Monitor slow queries and optimize

2. **Application Layer**
   - ✅ Use granular topic names
   - ✅ Implement sharding for high-volume topics
   - ✅ Minimize payload sizes
   - ✅ Batch updates when possible
   - ✅ Debounce high-frequency updates

3. **Client Layer**
   - ✅ Implement proper cleanup/unsubscribe
   - ✅ Handle reconnection gracefully
   - ✅ Monitor connection states
   - ✅ Queue messages during disconnection

4. **Infrastructure**
   - ✅ Enable private-only channels in production
   - ✅ Monitor bandwidth usage
   - ✅ Set up alerting for connection limits
   - ✅ Plan for geographic distribution
