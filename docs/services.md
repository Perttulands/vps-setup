# Services Guide

Systemd services for agent coordination and messaging.

## Overview

Two systemd services run persistently on this VPS:

| Service | Port | Purpose |
|---------|------|---------|
| openclaw-gateway | 18500 | Messaging gateway (Telegram, notifications) |
| mcp-agent-mail | 8765 | Agent-to-agent mail coordination |

## OpenClaw Gateway

### Purpose
Handles external messaging and notifications. Agents and scripts can send alerts, status updates, and notifications to Telegram or other channels.

### Service Details
- **Port**: 18500
- **Unit file**: `/etc/systemd/system/openclaw-gateway.service`
- **Config**: `~/.openclaw/openclaw.json`
- **Workspace**: `~/.openclaw/workspace/`

### Management

#### Check status
```bash
systemctl status openclaw-gateway
```

#### Start/stop/restart
```bash
sudo systemctl start openclaw-gateway
sudo systemctl stop openclaw-gateway
sudo systemctl restart openclaw-gateway
```

#### View logs
```bash
journalctl -u openclaw-gateway -f
```

#### Enable/disable autostart
```bash
sudo systemctl enable openclaw-gateway   # start on boot
sudo systemctl disable openclaw-gateway  # don't start on boot
```

### Configuration
Edit `~/.openclaw/openclaw.json` to configure:
- Telegram bot token and chat IDs
- Notification preferences
- Message routing rules

After config changes:
```bash
sudo systemctl restart openclaw-gateway
```

### Usage
Send message from command line:
```bash
openclaw message send --channel telegram --target <chat-id> --message "Agent completed task"
```

Or use the HTTP API on port 18500 (see OpenClaw docs).

## MCP Agent Mail

### Purpose
Enables agent-to-agent messaging and coordination. Agents can send structured messages, track conversations, and coordinate work across sessions.

### Service Details
- **Port**: 8765
- **API endpoint**: `http://127.0.0.1:8765/api/`
- **Unit file**: `/etc/systemd/system/mcp-agent-mail.service`
- **Project dir**: `~/mcp_agent_mail/`
- **Database**: `~/mcp_agent_mail/agent_mail.db` (SQLite)
- **Auth**: Bearer token in `~/mcp_agent_mail/.env`

### Management

#### Check status
```bash
systemctl status mcp-agent-mail
```

#### Start/stop/restart
```bash
sudo systemctl start mcp-agent-mail
sudo systemctl stop mcp-agent-mail
sudo systemctl restart mcp-agent-mail
```

#### View logs
```bash
journalctl -u mcp-agent-mail -f
```

#### Enable/disable autostart
```bash
sudo systemctl enable mcp-agent-mail   # start on boot
sudo systemctl disable mcp-agent-mail  # don't start on boot
```

### Configuration
Edit `~/mcp_agent_mail/.env` for:
- API authentication token
- Port settings (default 8765)
- Database path

After config changes:
```bash
sudo systemctl restart mcp-agent-mail
```

### Usage
Agents connect via MCP (Model Context Protocol). Add to Claude Code config:

```json
{
  "mcpServers": {
    "agent-mail": {
      "command": "mcp-agent-mail",
      "args": ["--port", "8765"],
      "env": {
        "AGENT_MAIL_TOKEN": "your-token-here"
      }
    }
  }
}
```

Or use the HTTP API directly:
```bash
curl http://127.0.0.1:8765/api/messages \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json"
```

### Database Management
Backup database:
```bash
cp ~/mcp_agent_mail/agent_mail.db ~/mcp_agent_mail/agent_mail.db.backup
```

Reset database (nuclear option):
```bash
sudo systemctl stop mcp-agent-mail
rm ~/mcp_agent_mail/agent_mail.db
sudo systemctl start mcp-agent-mail
```

## Installation

### Initial Setup
Service unit files are in this repo at `services/`:
```bash
sudo cp services/openclaw-gateway.service /etc/systemd/system/
sudo cp services/mcp-agent-mail.service /etc/systemd/system/
sudo systemctl daemon-reload
```

Enable and start:
```bash
sudo systemctl enable --now openclaw-gateway mcp-agent-mail
```

### Verify Installation
Check both services are running:
```bash
systemctl status openclaw-gateway
systemctl status mcp-agent-mail
```

Check ports are listening:
```bash
sudo lsof -i :18500  # openclaw-gateway
sudo lsof -i :8765   # mcp-agent-mail
```

## Troubleshooting

### Service won't start
Check logs for errors:
```bash
journalctl -u openclaw-gateway -n 50
journalctl -u mcp-agent-mail -n 50
```

Common issues:
- Port already in use (check with `lsof -i :<port>`)
- Missing config file or invalid JSON
- Missing auth token in `.env`
- Permissions on data directories

### Port conflicts
Find process using the port:
```bash
sudo lsof -i :18500
sudo lsof -i :8765
```

Kill conflicting process if safe:
```bash
sudo kill <PID>
```

Or edit service config to use different port.

### Permissions issues
Ensure correct ownership:
```bash
sudo chown -R $USER:$USER ~/.openclaw/
sudo chown -R $USER:$USER ~/mcp_agent_mail/
```

### Service crashes on startup
Check systemd logs:
```bash
journalctl -xe
```

Restart with verbose logging:
```bash
sudo systemctl restart openclaw-gateway
journalctl -u openclaw-gateway -f
```

## Monitoring

### Health checks
OpenClaw Gateway:
```bash
curl http://localhost:18500/health
```

MCP Agent Mail:
```bash
curl http://localhost:8765/health
```

### Resource usage
```bash
systemctl status openclaw-gateway  # shows CPU/memory
systemctl status mcp-agent-mail
```

Or use `htop` and filter by service name.

### Logs
All logs go to journald. View with `journalctl`:

```bash
# Last 100 lines
journalctl -u openclaw-gateway -n 100

# Follow live
journalctl -u mcp-agent-mail -f

# Since boot
journalctl -u openclaw-gateway -b

# Specific time range
journalctl -u mcp-agent-mail --since "2026-02-12 10:00" --until "2026-02-12 11:00"
```

## Unit File Reference

### openclaw-gateway.service
```ini
[Unit]
Description=OpenClaw Gateway
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=/home/$USER/.openclaw
ExecStart=/home/$USER/.npm-global/bin/openclaw gateway
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

### mcp-agent-mail.service
```ini
[Unit]
Description=MCP Agent Mail
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=/home/$USER/mcp_agent_mail
EnvironmentFile=/home/$USER/mcp_agent_mail/.env
ExecStart=/home/$USER/mcp_agent_mail/venv/bin/python -m agent_mail.server
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

## Security

### Network exposure
Both services listen on `127.0.0.1` (localhost only) by default. Not exposed to internet.

Access from other machines via Tailscale:
- VPS Tailscale IP: your-tailscale-ip
- Example: `curl http://your-tailscale-ip:18500/health` from other Tailscale nodes

### Authentication
- OpenClaw Gateway: configured in `openclaw.json`
- MCP Agent Mail: Bearer token in `.env` file

Protect these files:
```bash
chmod 600 ~/.openclaw/openclaw.json
chmod 600 ~/mcp_agent_mail/.env
```

### Firewall
UFW rules (if enabled):
```bash
sudo ufw allow from 100.64.0.0/10 to any port 18500 comment "OpenClaw from Tailscale"
sudo ufw allow from 100.64.0.0/10 to any port 8765 comment "MCP Agent Mail from Tailscale"
```

## Backup

### Config files
```bash
tar czf ~/backups/services-config-$(date +%Y%m%d).tar.gz \
  ~/.openclaw/openclaw.json \
  ~/mcp_agent_mail/.env
```

### Data
```bash
tar czf ~/backups/agent-mail-data-$(date +%Y%m%d).tar.gz \
  ~/mcp_agent_mail/agent_mail.db
```

### Restore
```bash
tar xzf ~/backups/services-config-20260212.tar.gz -C ~/
sudo systemctl restart openclaw-gateway mcp-agent-mail
```
