# Svelte 4 to 5 Migration Guide

Quick reference for migrating components from Svelte 4 to Svelte 5.

## Props Migration

### Before (Svelte 4)
```svelte
<script>
  export let name = 'World';
  export let count = 0;
  export let required;
</script>
```

### After (Svelte 5)
```svelte
<script>
  let { name = 'World', count = 0, required } = $props();
</script>
```

## Reactive Statements

### Before (Svelte 4)
```svelte
<script>
  export let count = 0;
  
  $: doubled = count * 2;
  $: {
    console.log(`count is ${count}`);
  }
</script>
```

### After (Svelte 5)
```svelte
<script>
  let count = $state(0);
  let doubled = $derived(count * 2);
  
  $effect(() => {
    console.log(`count is ${count}`);
  });
</script>
```

## Two-Way Binding

### Before (Svelte 4)
```svelte
<!-- Parent -->
<script>
  let value = '';
</script>
<Child bind:value />

<!-- Child -->
<script>
  export let value;
</script>
<input bind:value />
```

### After (Svelte 5)
```svelte
<!-- Parent -->
<script>
  let value = $state('');
</script>
<Child bind:value />

<!-- Child -->
<script>
  let { value = $bindable() } = $props();
</script>
<input bind:value />
```

## Event Handling

### Before (Svelte 4)
```svelte
<button on:click={handleClick}>Click me</button>
<button on:click={() => count++}>Increment</button>
```

### After (Svelte 5)
```svelte
<button onclick={handleClick}>Click me</button>
<button onclick={() => count++}>Increment</button>
```

## Custom Events

### Before (Svelte 4)
```svelte
<script>
  import { createEventDispatcher } from 'svelte';
  const dispatch = createEventDispatcher();
  
  function handleClick() {
    dispatch('message', { text: 'Hello' });
  }
</script>
```

### After (Svelte 5)
```svelte
<script>
  let { onmessage } = $props();
  
  function handleClick() {
    onmessage?.({ text: 'Hello' });
  }
</script>
```

## Slots

### Before (Svelte 4)
```svelte
<!-- Parent -->
<Card>
  <span slot="header">Title</span>
  <p>Content</p>
  <span slot="footer">Footer</span>
</Card>

<!-- Child -->
<div class="card">
  <slot name="header" />
  <slot />
  <slot name="footer" />
</div>
```

### After (Svelte 5)
```svelte
<!-- Parent -->
<Card>
  {#snippet header()}
    <span>Title</span>
  {/snippet}
  
  {#snippet children()}
    <p>Content</p>
  {/snippet}
  
  {#snippet footer()}
    <span>Footer</span>
  {/snippet}
</Card>

<!-- Child -->
<script>
  let { header, children, footer } = $props();
</script>

<div class="card">
  {@render header?.()}
  {@render children?.()}
  {@render footer?.()}
</div>
```

## Lifecycle Functions

### Before (Svelte 4)
```svelte
<script>
  import { onMount, afterUpdate, beforeUpdate, onDestroy } from 'svelte';
  
  onMount(() => {
    console.log('mounted');
    return () => console.log('cleanup');
  });
  
  afterUpdate(() => {
    console.log('after update');
  });
  
  beforeUpdate(() => {
    console.log('before update');
  });
  
  onDestroy(() => {
    console.log('destroyed');
  });
</script>
```

### After (Svelte 5)
```svelte
<script>
  import { onMount } from 'svelte';
  
  // onMount still exists
  onMount(() => {
    console.log('mounted');
    return () => console.log('cleanup');
  });
  
  // Use $effect for other lifecycle needs
  $effect(() => {
    console.log('runs after every update');
    
    return () => {
      console.log('cleanup on destroy or before re-run');
    };
  });
  
  // For before update logic
  $effect.pre(() => {
    console.log('runs before DOM updates');
  });
</script>
```

## Stores

### Before (Svelte 4)
```svelte
<script>
  import { writable } from 'svelte/store';
  
  const count = writable(0);
  
  // Auto-subscription
  $: console.log($count);
</script>

<button on:click={() => $count++}>
  Count: {$count}
</button>
```

### After (Svelte 5)
```svelte
<script>
  import { writable } from 'svelte/store';
  
  const count = writable(0);
  
  // Still works with $ prefix
  $effect(() => {
    console.log($count);
  });
</script>

<button onclick={() => $count++}>
  Count: {$count}
</button>
```

## $$props and $$restProps

### Before (Svelte 4)
```svelte
<script>
  export let class;
  // Access all props
  $: allProps = $$props;
  // Exclude 'class' from rest props
  $: ({ class: _, ...rest } = $$props);
</script>

<div class={class} {...$$restProps}>
  <slot />
</div>
```

### After (Svelte 5)
```svelte
<script>
  let { class: className, ...props } = $props();
</script>

<div class={className} {...props}>
  {@render children?.()}
</div>
```

## Component Composition

### Before (Svelte 4)
```svelte
<script>
  import Component from './Component.svelte';
  let component = Component;
</script>

<svelte:component this={component} prop="value" />
```

### After (Svelte 5)
```svelte
<script>
  import Component from './Component.svelte';
  let component = Component;
</script>

{@const DynamicComponent = component}
<DynamicComponent prop="value" />
```

## Quick Reference Table

| Svelte 4 | Svelte 5 |
|----------|----------|
| `export let prop` | `let { prop } = $props()` |
| `$: reactive = expression` | `let reactive = $derived(expression)` |
| `$: { sideEffect() }` | `$effect(() => { sideEffect() })` |
| `on:event={handler}` | `onevent={handler}` |
| `<slot />` | `{@render children?.()}` |
| `<slot name="x" />` | `{@render x?.()}` |
| `bind:property` | `bind:property` (same, but child needs `$bindable`) |
| `createEventDispatcher()` | Use callback props |
| `$$props` | `$props()` |
| `$$restProps` | Destructure with `$props()` |
| `$$slots` | Check if snippet props exist |

## Migration Strategy

1. **Start with Props**: Replace `export let` with `$props()`
2. **Update Reactivity**: Convert `$:` to `$state`, `$derived`, and `$effect`
3. **Fix Events**: Change `on:` to `on` (lowercase)
4. **Convert Slots**: Replace with snippets
5. **Update Bindings**: Add `$bindable` to child components
6. **Test Thoroughly**: Ensure all functionality works as expected

## Common Gotchas

1. **Props are read-only** by default (use `$bindable` for two-way)
2. **Effects run after DOM updates** (use `$effect.pre` for before)
3. **No more `$$slots`** - check if snippet props exist instead
4. **Event names are lowercase** (`onclick` not `on:click`)
5. **Store syntax (`$store`) still works** but consider using runes
6. **Component events** should be callback props now
