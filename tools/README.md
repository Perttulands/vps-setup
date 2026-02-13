# Recommended CLI Tools

This directory contains installation scripts for recommended tools that enhance the agentic coding workflow.

## Core Tools

### beads / beads_rust (br)
**Purpose:** Lightweight work tracking and context management

**Why you need it:** Track coding tasks, link them to agent sessions, maintain work history

**Installation:**
```bash
cargo install beads_rust
# Or follow instructions at: https://github.com/your-repo/beads_rust
```

**Usage:**
```bash
br create --title "Add user auth" --priority 1  # Create a task
br list                                          # List all tasks
br show <bead-id>                               # Show task details
br update <bead-id> --status done               # Mark complete
```

### cass
**Purpose:** Agent session search and management

**Why you need it:** Quickly find and navigate to agent tmux sessions

**Installation:**
```bash
# Follow installation instructions for cass
```

**Usage:**
```bash
cass search "authentication"     # Find sessions by keyword
cass list                        # List all active sessions
cass attach <session-name>       # Attach to a session
```

### ntm
**Purpose:** Named tmux manager

**Why you need it:** Manage tmux sessions with meaningful names and contexts

**Installation:**
```bash
# Follow installation instructions for ntm
```

**Usage:**
```bash
ntm new my-session               # Create named session
ntm list                         # List sessions
ntm kill my-session              # Kill session
```

### ubs
**Purpose:** Universal bug scanner

**Why you need it:** Automated static analysis and bug detection

**Installation:**
```bash
# Follow installation instructions for ubs
```

**Usage:**
```bash
ubs /path/to/project             # Scan for bugs
ubs --fix /path/to/project       # Auto-fix issues
```

### dcg
**Purpose:** Destructive command guard

**Why you need it:** Prevent accidental data loss from destructive commands

**Installation:**
```bash
# Follow installation instructions for dcg
```

**Features:**
- Intercepts dangerous commands (rm -rf, git reset --hard, etc.)
- Prompts for confirmation
- Logs all destructive operations
- Configurable allowlists

### rtk (Rust Token Killer)
**Purpose:** Token-optimized CLI proxy for 60-90% token savings

**Why you need it:** Dramatically reduce API costs on repetitive dev operations

**Installation:**
```bash
cargo install rtk
# Or follow instructions at: https://github.com/your-repo/rtk
```

**Usage:**
```bash
rtk gain              # Show token savings analytics
rtk gain --history    # Command usage history with savings
rtk discover          # Analyze missed optimization opportunities
rtk proxy <cmd>       # Execute without filtering (debugging)
```

**Hook integration:** rtk automatically rewrites common commands (git, ls, etc.) via Claude Code hooks for transparent savings.

## Optional Tools

### Tailscale
**Purpose:** VPN mesh networking

**Why you need it:** Secure remote access to your VPS

**Installation:**
```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

### GitHub CLI (gh)
**Purpose:** GitHub operations from the command line

**Installation:**
```bash
# Ubuntu/Debian
sudo apt install gh

# macOS
brew install gh

# Authenticate
gh auth login
```

**Usage:**
```bash
gh pr create --title "Feature X"     # Create pull request
gh issue list                        # List issues
gh pr view 123                       # View PR details
```

### jq
**Purpose:** JSON processing and manipulation

**Installation:**
```bash
# Ubuntu/Debian
sudo apt install jq

# macOS
brew install jq
```

**Usage:**
```bash
cat file.json | jq '.key'            # Extract value
cat file.json | jq -r '.items[]'     # Raw output
```

### tmux
**Purpose:** Terminal multiplexer (required for agent dispatch)

**Installation:**
```bash
# Ubuntu/Debian
sudo apt install tmux

# macOS
brew install tmux
```

## Tool Integration Matrix

| Tool | Used By | Purpose |
|------|---------|---------|
| br | Swarm system | Work tracking, bead IDs |
| tmux | dispatch.sh | Agent session management |
| jq | All scripts | JSON processing |
| cass | Manual | Session discovery |
| ntm | Manual | Named session management |
| ubs | verify.sh | Bug scanning |
| rtk | Claude Code | Token reduction |
| dcg | All agents | Safety guard |

## Installation Scripts

Create installation scripts in this directory for tools that require complex setup:

```bash
tools/
├── README.md           # This file
├── install-beads.sh    # Install beads_rust
├── install-cass.sh     # Install cass
└── install-ubs.sh      # Install ubs
```

## Verification

After installing tools, verify they're available:

```bash
command -v br && echo "✓ beads_rust installed"
command -v cass && echo "✓ cass installed"
command -v ntm && echo "✓ ntm installed"
command -v ubs && echo "✓ ubs installed"
command -v rtk && echo "✓ rtk installed"
command -v dcg && echo "✓ dcg installed"
```

---

**The right tools make all the difference.**
