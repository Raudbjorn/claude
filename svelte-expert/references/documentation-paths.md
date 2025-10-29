# Svelte Documentation Paths

Complete list of available documentation for `get_documentation` tool.

## CLI Documentation

### Project Setup & Initialization
- `cli/overview` - Project setup, creating new svelte apps, scaffolding, cli tools
- `cli/faq` - Project setup, troubleshooting cli installation, package manager config
- `cli/sv-create` - Starting new sveltekit app, initializing project, choosing templates
- `cli/sv-add` - Adding features, integrating tools, testing/styling/auth/database setup

### Development Tools
- `cli/sv-check` - Code quality, CI/CD pipelines, error checking, typescript, accessibility
- `cli/sv-migrate` - Upgrading svelte versions, modernizing codebase, svelte 3→4→5
- `cli/devtools-json` - Chrome devtools integration, browser-based editing, debugging
- `cli/mcp` - Model Context Protocol integration

### Code Quality & Formatting
- `cli/eslint` - Linting, error detection, code standards, team collaboration
- `cli/prettier` - Code formatting, style consistency, linting configuration

### Database & Authentication
- `cli/drizzle` - Database setup, SQL queries, ORM integration, type-safe queries
- `cli/lucia` - Authentication, login systems, user management, session handling

### Testing
- `cli/playwright` - Browser testing, e2e testing, test automation, CI/CD pipelines
- `cli/vitest` - Unit tests, component testing, test-driven development
- `cli/storybook` - Component development, design systems, visual testing

### Styling & UI
- `cli/tailwindcss` - CSS framework, utility-first css, responsive design
- `cli/mdsvex` - Markdown rendering, blog/documentation sites, CMS integration

### Deployment & Build
- `cli/sveltekit-adapter` - Deployment, production builds, hosting setup
- `cli/paraglide` - Internationalization, i18n, multi-language sites

## SvelteKit Documentation

### Getting Started
- `kit/introduction` - Learning sveltekit, framework basics, getting started
- `kit/creating-a-project` - Starting new app, development environment
- `kit/project-types` - SSG, SPA, SSR, serverless, mobile/desktop apps, PWA
- `kit/project-structure` - File structure, organizing code, learning basics
- `kit/web-standards` - Data fetching, forms, API routes, server-side rendering

### Core Features
- `kit/routing` - Navigation, multi-page apps, file structure, API endpoints
- `kit/load` - Data fetching, API calls, database queries, dynamic routes
- `kit/form-actions` - Forms, data submission, authentication, validation
- `kit/page-options` - Prerendering, SSR config, client-side rendering control
- `kit/state-management` - Server-side state, authentication, data persistence
- `kit/remote-functions` - Type-safe client-server communication, CRUD operations

### Deployment
- `kit/building-your-app` - Production builds, deployment preparation
- `kit/adapters` - Deployment platform configuration
- `kit/adapter-auto` - Zero-config deployments
- `kit/adapter-node` - Node.js hosting, Docker deployment
- `kit/adapter-static` - Static site generation, GitHub Pages
- `kit/single-page-apps` - SPA mode, client-only rendering
- `kit/adapter-cloudflare` - Cloudflare Workers/Pages deployment
- `kit/adapter-netlify` - Netlify hosting, serverless functions
- `kit/adapter-vercel` - Vercel hosting, ISR, edge functions

### Advanced Topics
- `kit/advanced-routing` - Dynamic routes, custom 404, route parameters
- `kit/hooks` - Request handling, authentication, middleware patterns
- `kit/errors` - Error handling, custom error pages, error boundaries
- `kit/link-options` - Prefetching, navigation control, data reloading
- `kit/service-workers` - Offline functionality, caching strategies, PWA
- `kit/modules` - App modules, environment variables, configuration
- `kit/assets` - Static assets, image optimization, file handling
- `kit/accessibility` - A11y best practices, screen readers, ARIA
- `kit/seo` - SEO optimization, meta tags, structured data
- `kit/configuration` - Advanced config, custom builds, vite setup
- `kit/packaging` - Creating libraries, npm packages, component sharing
- `kit/performance` - Optimization, code splitting, lazy loading
- `kit/migrating-to-sveltekit-2` - Upgrading from v1 to v2

## Svelte Core Documentation

### Getting Started
- `svelte/introduction` - First Svelte app, reactivity basics, component structure
- `svelte/getting-started` - Installation, first component, development setup
- `svelte/reactivity-fundamentals` - State, computed values, effects, reactive system

### Templating
- `svelte/template-syntax` - Svelte syntax, directives, expressions
- `svelte/text-expressions` - String interpolation, reactive text
- `svelte/if-blocks` - Conditional rendering, if/else/else-if
- `svelte/each-blocks` - List rendering, keyed blocks, iteration
- `svelte/await-blocks` - Async data, loading states, error handling
- `svelte/key-blocks` - Forcing re-creation, animation resets

### Component Basics
- `svelte/component-fundamentals` - Props, events, slots, composition
- `svelte/imports` - Component imports, module scripts, dependencies
- `svelte/props` - Component properties, $props rune, defaults
- `svelte/logic-blocks` - Template logic, control flow
- `svelte/styles` - Component styling, scoped CSS, global styles
- `svelte/nested-components` - Composition, children, hierarchies

### Interactivity
- `svelte/event-handlers` - User interactions, event binding, modifiers
- `svelte/bindings` - Two-way binding, form inputs, element references
- `svelte/class-and-style-directives` - Dynamic styling, conditional classes
- `svelte/actions` - DOM manipulation, third-party integrations
- `svelte/transitions` - Enter/leave animations, custom transitions
- `svelte/animations` - List animations, FLIP technique
- `svelte/easing` - Animation curves, motion design

### State Management
- `svelte/$state` - Reactive state, state rune usage
- `svelte/$derived` - Computed values, reactive derivations
- `svelte/$effect` - Side effects, lifecycle, cleanup
- `svelte/$bindable` - Bindable props, two-way component binding
- `svelte/$inspect` - Debugging state, development tools
- `svelte/$host` - Custom elements, web components

### Advanced Patterns
- `svelte/snippets` - Reusable template fragments, render props
- `svelte/events` - Custom events, event forwarding, bubbling
- `svelte/composition` - Component patterns, slots, delegation
- `svelte/context` - Context API, cross-component state
- `svelte/special-tags` - Built-in tags, dynamic components

### Special Elements
- `svelte/svelte-self` - Recursive components, tree structures
- `svelte/svelte-component` - Dynamic components, runtime selection
- `svelte/svelte-element` - Dynamic elements, runtime HTML
- `svelte/svelte-window` - Window events, global listeners
- `svelte/svelte-document` - Document events, global state
- `svelte/svelte-body` - Body manipulation, global styles
- `svelte/svelte-head` - Head manipulation, meta tags, SEO
- `svelte/svelte-options` - Compiler options, web components

## Module APIs

### Core Modules
- `svelte/svelte` - Main API, lifecycle, context, component types
- `svelte/svelte-reactivity` - Reactive utilities, state management, stores
- `svelte/svelte-reactivity-window` - Window state, viewport tracking
- `svelte/svelte-motion` - Spring/tweened animations, motion design
- `svelte/svelte-transition` - Transition functions, animation utilities
- `svelte/svelte-animate` - FLIP animations, list reordering
- `svelte/svelte-easing` - Easing functions, animation curves
- `svelte/svelte-action` - TypeScript types for actions
- `svelte/svelte-events` - Global event handling, cleanup
- `svelte/svelte-store` - Writable/readable stores, derived state
- `svelte/svelte-server` - SSR utilities, server-side rendering
- `svelte/svelte-compiler` - Compiler API, AST manipulation

### Special APIs
- `svelte/svelte-attachments` - Library development, element manipulation
- `svelte/svelte-legacy` - Migration helpers, legacy component API

## Error References

- `svelte/compiler-errors` - Animation errors, build issues
- `svelte/compiler-warnings` - Accessibility warnings, a11y compliance
- `svelte/runtime-errors` - Runtime debugging, component binding
- `svelte/runtime-warnings` - State proxy debugging, reactivity issues

## Legacy & Migration

- `svelte/v4-migration-guide` - Svelte 3 to 4 upgrade guide
- `svelte/v5-migration-guide` - Svelte 4 to 5, runes migration
- `svelte/faq` - Common questions, troubleshooting, setup

### Legacy Features
- `svelte/legacy-overview` - Understanding deprecated features
- `svelte/legacy-let` - Old reactivity system, let declarations
- `svelte/legacy-reactive-assignments` - $: reactive statements
- `svelte/legacy-export-let` - Old prop system
- `svelte/legacy-$$props-and-$$restProps` - Prop forwarding
- `svelte/legacy-on` - Event handling in Svelte 4
- `svelte/legacy-slots` - Old slot syntax
- `svelte/legacy-$$slots` - Conditional slot rendering
- `svelte/legacy-svelte-fragment` - Named slots wrapper
- `svelte/legacy-svelte-component` - Dynamic components
- `svelte/legacy-svelte-self` - Recursive components
- `svelte/legacy-component-api` - Imperative API
