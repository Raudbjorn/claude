# Framework-Specific Patterns

## React

### Hook Pattern with Cleanup
```javascript
import { useEffect, useRef } from 'react'
import { createClient } from '@supabase/supabase-js'

function useRealtimeChannel(topic, handlers) {
  const channelRef = useRef(null)
  const supabase = createClient(url, key)

  useEffect(() => {
    // Prevent duplicate subscriptions
    if (channelRef.current?.state === 'subscribed') return

    const channel = supabase.channel(topic, {
      config: { 
        private: true,
        broadcast: { self: true, ack: true }
      }
    })
    channelRef.current = channel

    // Setup auth
    supabase.realtime.setAuth().then(() => {
      // Subscribe to events
      Object.entries(handlers).forEach(([event, handler]) => {
        channel.on('broadcast', { event }, handler)
      })
      
      channel.subscribe((status, err) => {
        if (status === 'CHANNEL_ERROR') {
          console.error('Channel error:', err)
        }
      })
    })

    // Cleanup
    return () => {
      if (channelRef.current) {
        supabase.removeChannel(channelRef.current)
        channelRef.current = null
      }
    }
  }, [topic])

  return channelRef.current
}

// Usage
function ChatRoom({ roomId }) {
  const channel = useRealtimeChannel(`room:${roomId}:messages`, {
    message_created: (payload) => console.log('New message:', payload),
    user_joined: (payload) => console.log('User joined:', payload),
    user_left: (payload) => console.log('User left:', payload)
  })
  
  const sendMessage = (message) => {
    channel?.send({
      type: 'broadcast',
      event: 'message_created',
      payload: { message, userId, timestamp: new Date() }
    })
  }
  
  return <div>...</div>
}
```

### State Management Pattern
```javascript
import { useReducer } from 'react'

const initialState = {
  messages: [],
  users: [],
  connectionStatus: 'connecting'
}

function chatReducer(state, action) {
  switch (action.type) {
    case 'MESSAGE_RECEIVED':
      return { ...state, messages: [...state.messages, action.payload] }
    case 'USER_JOINED':
      return { ...state, users: [...state.users, action.payload] }
    case 'CONNECTION_STATUS':
      return { ...state, connectionStatus: action.payload }
    default:
      return state
  }
}

function ChatRoom({ roomId }) {
  const [state, dispatch] = useReducer(chatReducer, initialState)
  
  useRealtimeChannel(`room:${roomId}`, {
    message_created: (payload) => 
      dispatch({ type: 'MESSAGE_RECEIVED', payload }),
    user_joined: (payload) => 
      dispatch({ type: 'USER_JOINED', payload })
  })
  
  return <div>...</div>
}
```

## Vue 3

### Composition API Pattern
```javascript
import { ref, onUnmounted } from 'vue'
import { createClient } from '@supabase/supabase-js'

export function useRealtimeChannel(topic, handlers) {
  const channel = ref(null)
  const supabase = createClient(url, key)

  const connect = async () => {
    if (channel.value?.state === 'subscribed') return

    channel.value = supabase.channel(topic, {
      config: { private: true }
    })

    await supabase.realtime.setAuth()

    Object.entries(handlers).forEach(([event, handler]) => {
      channel.value.on('broadcast', { event }, handler)
    })

    await channel.value.subscribe()
  }

  const disconnect = () => {
    if (channel.value) {
      supabase.removeChannel(channel.value)
      channel.value = null
    }
  }

  onUnmounted(disconnect)

  return { channel, connect, disconnect }
}
```

## SvelteKit

### Store-based Pattern
```javascript
// $lib/stores/realtime.js
import { writable, derived } from 'svelte/store'
import { createClient } from '@supabase/supabase-js'

export function createRealtimeStore(topic, initialValue = []) {
  const { subscribe, set, update } = writable(initialValue)
  let channel = null
  
  const supabase = createClient(url, key)

  const connect = async () => {
    if (channel?.state === 'subscribed') return

    channel = supabase.channel(topic, {
      config: { private: true }
    })

    await supabase.realtime.setAuth()

    channel
      .on('broadcast', { event: 'item_added' }, (payload) => {
        update(items => [...items, payload.item])
      })
      .on('broadcast', { event: 'item_removed' }, (payload) => {
        update(items => items.filter(item => item.id !== payload.id))
      })
      .subscribe()
  }

  const disconnect = () => {
    if (channel) {
      supabase.removeChannel(channel)
      channel = null
    }
  }

  const send = (event, payload) => {
    channel?.send({ type: 'broadcast', event, payload })
  }

  return {
    subscribe,
    connect,
    disconnect,
    send
  }
}

// Usage in component
// <script>
//   import { onMount, onDestroy } from 'svelte'
//   import { createRealtimeStore } from '$lib/stores/realtime'
//   
//   const messages = createRealtimeStore('room:123:messages')
//   
//   onMount(() => messages.connect())
//   onDestroy(() => messages.disconnect())
// </script>
```

## Next.js

### App Router Pattern
```typescript
// app/room/[id]/realtime-provider.tsx
'use client'

import { createContext, useContext, useEffect, useRef } from 'react'
import { createClient } from '@supabase/supabase-js'
import { useParams } from 'next/navigation'

const RealtimeContext = createContext(null)

export function RealtimeProvider({ children }) {
  const params = useParams()
  const channelRef = useRef(null)
  const supabase = createClient(url, key)

  useEffect(() => {
    const setupChannel = async () => {
      if (channelRef.current?.state === 'subscribed') return

      const channel = supabase.channel(`room:${params.id}`, {
        config: { private: true }
      })
      channelRef.current = channel

      await supabase.realtime.setAuth()
      await channel.subscribe()
    }

    setupChannel()

    return () => {
      if (channelRef.current) {
        supabase.removeChannel(channelRef.current)
      }
    }
  }, [params.id])

  return (
    <RealtimeContext.Provider value={channelRef.current}>
      {children}
    </RealtimeContext.Provider>
  )
}

export const useRealtimeChannel = () => useContext(RealtimeContext)
```

## Angular

### Service Pattern
```typescript
import { Injectable, OnDestroy } from '@angular/core'
import { BehaviorSubject } from 'rxjs'
import { createClient, RealtimeChannel } from '@supabase/supabase-js'

@Injectable()
export class RealtimeService implements OnDestroy {
  private channels = new Map<string, RealtimeChannel>()
  private supabase = createClient(url, key)

  async subscribeToChannel(
    topic: string, 
    handlers: Record<string, (payload: any) => void>
  ) {
    if (this.channels.has(topic)) return

    const channel = this.supabase.channel(topic, {
      config: { private: true }
    })

    await this.supabase.realtime.setAuth()

    Object.entries(handlers).forEach(([event, handler]) => {
      channel.on('broadcast', { event }, handler)
    })

    await channel.subscribe()
    this.channels.set(topic, channel)
  }

  unsubscribeFromChannel(topic: string) {
    const channel = this.channels.get(topic)
    if (channel) {
      this.supabase.removeChannel(channel)
      this.channels.delete(topic)
    }
  }

  ngOnDestroy() {
    this.channels.forEach(channel => {
      this.supabase.removeChannel(channel)
    })
  }
}
```
