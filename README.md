# Massif Skills Marketplace

A curated collection of Claude Code skills for modern web development, specializing in Supabase and Svelte/SvelteKit.

🌐 **Live Marketplace:** [massifnet.work](https://massifnet.work)

## 📦 Available Skills

### 🗄️ Supabase
Comprehensive Supabase development expert covering Edge Functions, database schema management, migrations, PostgreSQL functions, and RLS policies.

**Use for:**
- TypeScript/Deno Edge Functions (npm:/jsr: specifiers)
- Declarative schema management
- SQL formatting and style guide
- Migration creation (YYYYMMDDHHmmss format)
- Database functions with SECURITY INVOKER
- RLS policy implementation

[View Skill](./supabase/skill.md)

---

### 📦 Supabase Storage
Expert guide for Supabase Storage including bucket management, file operations, URL generation, and RLS policies.

**Use for:**
- File uploads/downloads
- Public and private bucket configuration
- Signed URL generation
- Storage RLS policies
- Resumable uploads (tus-js-client, Uppy.js)
- Image transformations

[View Skill](./supabase-storage/skill.md)

---

### 📡 Supabase Realtime
Comprehensive guide for implementing Supabase Realtime features with best practices, scalable patterns, and migration strategies.

**Use for:**
- Real-time messaging and notifications
- Presence tracking
- Live updates
- Collaborative features
- Migrating from postgres_changes to broadcast

[View Skill](./supabase-realtime/skill.md)

---

### 🎨 Svelte Expert
Expert Svelte/SvelteKit development assistant for building components, utilities, and applications.

**Use for:**
- Svelte 5 components with runes
- SvelteKit applications
- Reactive patterns and state management
- Stores, transitions, and animations
- Form handling and validation

[View Skill](./svelte-expert/skill.md)

---

### 🛠️ Skill Creator
Guide for creating effective Claude Code skills that extend capabilities with specialized knowledge, workflows, or tool integrations.

**Use for:**
- Creating new skills
- Updating existing skills
- Structuring skill documentation
- Best practices for skill authoring

[View Skill](./skill-creator/skill.md)

---

## 🚀 Installation

### Using Claude Code CLI

```bash
# Add the marketplace to your Claude Code configuration
claude skill install https://massifnet.work/marketplace.json
```

### Manual Installation

1. Download the `marketplace.json` file
2. Add skills to your `.claude/skills/` directory
3. Skills will be auto-invoked based on context

## 📚 Marketplace Configuration

```json
{
  "name": "massif-skills",
  "owner": {
    "name": "Sveinbjorn Geirsson",
    "email": "sveinbjorn@sveinbjorn.dev"
  },
  "metadata": {
    "description": "Skills for my development stack",
    "version": "1.0.0"
  }
}
```

## 🔗 Links

- **Marketplace:** [massifnet.work](https://massifnet.work)
- **Repository:** [github.com/Raudbjorn/claude](https://github.com/Raudbjorn/claude)
- **Marketplace JSON:** [massifnet.work/marketplace.json](https://massifnet.work/marketplace.json)

## 📝 License

MIT License - Feel free to use and adapt these skills for your own projects.

## 🤝 Contributing

Contributions are welcome! Feel free to submit issues or pull requests.

---

Built with ❤️ using Claude Code and MCP servers
