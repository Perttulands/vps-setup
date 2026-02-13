# AGENTS.md — Entry Point

This folder is home.

## Navigation

**Identity:**
- [SOUL.md](SOUL.md) — Who you are
- [USER.md](USER.md) — Who you're helping

**How you work:**
- [TOOLS.md](TOOLS.md) — Server, services, CLI tools, paths
- [docs/INDEX.md](docs/INDEX.md) — Documentation index

**Operating rules:**
- [docs/operating-principles.md](docs/operating-principles.md) — Safety, external actions
- [docs/memory-system.md](docs/memory-system.md) — How memory works
- [docs/context-discipline.md](docs/context-discipline.md) — Protect your context window

## Session Startup

Before doing anything:

1. Read `SOUL.md`
2. Read `USER.md`
3. Read `memory/YYYY-MM-DD.md` (today + yesterday)
4. Main session: also read `MEMORY.md`

Keep total startup reading under ~500 lines.

## Rules

### Dispatch through the swarm
All coding work uses `dispatch.sh`. No manual tmux agent launches. Read the `coding-agents` skill.

### Memory is files
If you want to remember something, write it to a file. Mental notes die with the session.
- Daily events → `memory/YYYY-MM-DD.md`
- Lessons → update the relevant doc

### Safety
- No data exfiltration
- `trash` > `rm`
- Ask before destructive commands

### Docs describe what IS
No "fixed", "changed from", "previously". Every doc reads as current truth.

### Telegram formatting
When providing commands or code to run, send them in a **separate message** with nothing else — no explanation mixed in.

### Context discipline
- Never poll in a loop
- Batch everything
- Delegate monitoring when >2 agents active
- Go silent when waiting
