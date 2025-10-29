# Svelte Component Patterns

Common patterns and best practices for Svelte component development.

## Svelte 5 Component Patterns

### Basic Component with Props
```svelte
<script>
  let { name = 'World', count = 0 } = $props();
</script>

<h1>Hello {name}!</h1>
<p>Count: {count}</p>
```

### Component with State and Effects
```svelte
<script>
  let count = $state(0);
  let doubled = $derived(count * 2);
  
  $effect(() => {
    console.log(`Count changed to ${count}`);
    return () => {
      console.log('Cleanup');
    };
  });
</script>

<button onclick={() => count++}>
  Count: {count}, Doubled: {doubled}
</button>
```

### Two-Way Binding with $bindable
```svelte
<script>
  let { value = $bindable('') } = $props();
</script>

<input bind:value placeholder="Type something..." />
```

### Component with Slots and Snippets
```svelte
<script>
  let { title } = $props();
</script>

<article>
  <h2>{title}</h2>
  {#if $$slots.header}
    <header>
      {@render header()}
    </header>
  {/if}
  
  <main>
    {@render children()}
  </main>
  
  {#if $$slots.footer}
    <footer>
      {@render footer()}
    </footer>
  {/if}
</article>
```

### Event Handling and Custom Events
```svelte
<script>
  import { createEventDispatcher } from 'svelte';
  
  const dispatch = createEventDispatcher();
  let { value = '' } = $props();
  
  function handleSubmit(e) {
    e.preventDefault();
    dispatch('submit', { value });
  }
</script>

<form onsubmit={handleSubmit}>
  <input bind:value />
  <button type="submit">Submit</button>
</form>
```

## Form Patterns

### Controlled Form
```svelte
<script>
  let formData = $state({
    name: '',
    email: '',
    message: ''
  });
  
  let errors = $state({});
  
  function validate() {
    errors = {};
    if (!formData.name) errors.name = 'Name is required';
    if (!formData.email) errors.email = 'Email is required';
    if (!formData.message) errors.message = 'Message is required';
    return Object.keys(errors).length === 0;
  }
  
  function handleSubmit(e) {
    e.preventDefault();
    if (validate()) {
      console.log('Form submitted:', formData);
    }
  }
</script>

<form onsubmit={handleSubmit}>
  <label>
    Name:
    <input bind:value={formData.name} />
    {#if errors.name}<span class="error">{errors.name}</span>{/if}
  </label>
  
  <label>
    Email:
    <input type="email" bind:value={formData.email} />
    {#if errors.email}<span class="error">{errors.email}</span>{/if}
  </label>
  
  <label>
    Message:
    <textarea bind:value={formData.message}></textarea>
    {#if errors.message}<span class="error">{errors.message}</span>{/if}
  </label>
  
  <button type="submit">Submit</button>
</form>
```

## Store Patterns

### Custom Store
```javascript
import { writable, derived } from 'svelte/store';

export function createCounterStore(initial = 0) {
  const { subscribe, set, update } = writable(initial);
  
  return {
    subscribe,
    increment: () => update(n => n + 1),
    decrement: () => update(n => n - 1),
    reset: () => set(initial)
  };
}

// Derived store
export const doubled = derived(counter, $counter => $counter * 2);
```

### Store with Local Storage
```javascript
import { writable } from 'svelte/store';
import { browser } from '$app/environment';

export function persistentStore(key, initial) {
  const stored = browser ? localStorage.getItem(key) : null;
  const data = stored ? JSON.parse(stored) : initial;
  
  const store = writable(data);
  
  if (browser) {
    store.subscribe(value => {
      localStorage.setItem(key, JSON.stringify(value));
    });
  }
  
  return store;
}
```

## Animation Patterns

### List Transitions
```svelte
<script>
  import { flip } from 'svelte/animate';
  import { fade, slide } from 'svelte/transition';
  
  let items = $state([
    { id: 1, name: 'Item 1' },
    { id: 2, name: 'Item 2' },
    { id: 3, name: 'Item 3' }
  ]);
  
  function addItem() {
    items = [...items, { 
      id: Math.max(...items.map(i => i.id)) + 1, 
      name: `Item ${items.length + 1}` 
    }];
  }
  
  function removeItem(id) {
    items = items.filter(item => item.id !== id);
  }
</script>

<button onclick={addItem}>Add Item</button>

<ul>
  {#each items as item (item.id)}
    <li 
      animate:flip={{ duration: 300 }}
      in:fade
      out:slide
    >
      {item.name}
      <button onclick={() => removeItem(item.id)}>Remove</button>
    </li>
  {/each}
</ul>
```

### Custom Transition
```svelte
<script>
  import { cubicOut } from 'svelte/easing';
  
  function typewriter(node, { speed = 1 }) {
    const valid = node.childNodes.length === 1 && 
                  node.childNodes[0].nodeType === Node.TEXT_NODE;
    
    if (!valid) {
      throw new Error('This transition only works on single text nodes');
    }
    
    const text = node.textContent;
    const duration = text.length / (speed * 0.01);
    
    return {
      duration,
      tick: t => {
        const i = Math.floor(text.length * t);
        node.textContent = text.slice(0, i);
      }
    };
  }
  
  let visible = $state(false);
</script>

<button onclick={() => visible = !visible}>
  Toggle
</button>

{#if visible}
  <p in:typewriter={{ speed: 2 }}>
    Hello, this is a typewriter effect!
  </p>
{/if}
```

## Action Patterns

### Click Outside Action
```javascript
export function clickOutside(node, callback) {
  const handleClick = (event) => {
    if (!node.contains(event.target)) {
      callback();
    }
  };
  
  document.addEventListener('click', handleClick, true);
  
  return {
    destroy() {
      document.removeEventListener('click', handleClick, true);
    }
  };
}
```

Usage:
```svelte
<script>
  import { clickOutside } from './actions';
  
  let showDropdown = $state(false);
</script>

<div use:clickOutside={() => showDropdown = false}>
  <button onclick={() => showDropdown = !showDropdown}>
    Toggle Dropdown
  </button>
  
  {#if showDropdown}
    <div class="dropdown">
      Dropdown content
    </div>
  {/if}
</div>
```

## SvelteKit Patterns

### Load Function with Error Handling
```javascript
export async function load({ params, fetch }) {
  try {
    const response = await fetch(`/api/items/${params.id}`);
    
    if (!response.ok) {
      throw new Error(`Failed to load item: ${response.status}`);
    }
    
    const item = await response.json();
    
    return {
      item
    };
  } catch (error) {
    throw error({
      status: 500,
      message: error.message
    });
  }
}
```

### Form Actions
```javascript
import { fail, redirect } from '@sveltejs/kit';

export const actions = {
  create: async ({ request, locals }) => {
    const data = await request.formData();
    const title = data.get('title');
    const content = data.get('content');
    
    // Validation
    if (!title || !content) {
      return fail(400, {
        title,
        content,
        error: 'All fields are required'
      });
    }
    
    try {
      const post = await db.posts.create({
        data: { title, content, userId: locals.user.id }
      });
      
      throw redirect(303, `/posts/${post.id}`);
    } catch (error) {
      return fail(500, {
        title,
        content,
        error: 'Failed to create post'
      });
    }
  }
};
```

## Testing Patterns

### Component Test with Vitest
```javascript
import { render, fireEvent } from '@testing-library/svelte';
import { expect, test } from 'vitest';
import Counter from './Counter.svelte';

test('increments count on click', async () => {
  const { getByText } = render(Counter, { count: 0 });
  const button = getByText('Count: 0');
  
  await fireEvent.click(button);
  expect(button.textContent).toBe('Count: 1');
  
  await fireEvent.click(button);
  expect(button.textContent).toBe('Count: 2');
});
```

## Accessibility Patterns

### Accessible Modal
```svelte
<script>
  import { trapFocus } from './a11y-utils';
  
  let { open = $bindable(false), title } = $props();
  let dialog;
  
  $effect(() => {
    if (open && dialog) {
      dialog.showModal();
    } else if (!open && dialog) {
      dialog.close();
    }
  });
</script>

<dialog 
  bind:this={dialog}
  use:trapFocus
  aria-labelledby="dialog-title"
  onclose={() => open = false}
>
  <h2 id="dialog-title">{title}</h2>
  {@render children()}
  
  <button onclick={() => open = false}>
    Close
  </button>
</dialog>

<style>
  dialog::backdrop {
    background: rgba(0, 0, 0, 0.5);
  }
</style>
```
