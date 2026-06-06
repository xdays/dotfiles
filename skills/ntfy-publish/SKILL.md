---
name: ntfy-publish
description: Use when sending push notifications via ntfy.sh, publishing to ntfy topics, or configuring ntfy message headers (priority, tags, actions, attachments, delays, templates, authentication).
---

# ntfy Publish Reference

## Overview

ntfy.sh is a simple pub/sub notification service. POST to `https://ntfy.sh/<topic>` to send a push notification. Topics are created on first use — topic name acts as a password, so use an unpredictable name.

## Quick Publish

```bash
# Minimal
curl -d "Backup done" ntfy.sh/mytopic

# With title and priority
curl -H "Title: Alert" -H "Priority: high" -d "Disk full" ntfy.sh/mytopic

# JSON body
curl -H "Content-Type: application/json" \
  -d '{"topic":"mytopic","message":"Done","title":"Job","priority":4}' \
  ntfy.sh
```

## Headers Quick Reference

| Feature | Header | Aliases | Example |
|---------|--------|---------|---------|
| Title | `X-Title` | `Title`, `t` | `Backup complete` |
| Priority | `X-Priority` | `Priority`, `p` | `high` or `4` |
| Tags | `X-Tags` | `Tags`, `ta` | `warning,skull` |
| Click URL | `X-Click` | `Click` | `https://example.com` |
| Icon | `X-Icon` | `Icon` | `https://example.com/icon.png` |
| Attach URL | `X-Attach` | `Attach`, `a` | `https://example.com/file.zip` |
| Filename | `X-Filename` | `Filename`, `f` | `backup.zip` |
| Delay | `X-Delay` | `Delay`, `At`, `In` | `30m`, `tomorrow 9am` |
| Markdown | `X-Markdown` | `Markdown`, `md` | `yes` |
| Email | `X-Email` | | `user@example.com` |
| Actions | `X-Actions` | | see below |

## Priority Levels

| Value | Name | Behavior |
|-------|------|----------|
| `1` | min | No sound/vibration |
| `2` | low | Silent |
| `3` | default | Standard sound+vibration |
| `4` | high | Extended vibration, pop-over |
| `5` | max/urgent | Intense vibration, prominent pop-over |

## Tags & Emojis

Tags that match emoji shortcodes (e.g. `warning`, `tada`, `white_check_mark`) are shown as emojis. Others appear as plain text labels.

```bash
curl -H "Tags: warning,backup" -d "Backup failed" ntfy.sh/mytopic
```

## Action Buttons (up to 3)

Format: `<type>, <label>, <target>[, options]`

```bash
# View URL
-H "Actions: view, Open Dashboard, https://grafana.example.com"

# HTTP action (e.g. acknowledge alert)
-H "Actions: http, Acknowledge, https://api.example.com/ack, method=POST, body=id=123"

# Copy to clipboard
-H "Actions: copy, Copy Token, supersecret123"

# Multiple actions (semicolon-separated)
-H "Actions: view, Open, https://example.com; http, Ack, https://api.example.com/ack, method=POST"
```

## Attachments

```bash
# Upload local file (max 15 MB, expires after 3h)
curl -T backup.zip -H "Filename: backup.zip" ntfy.sh/mytopic

# Reference external URL (no size/expiry limits)
curl -H "Attach: https://example.com/report.pdf" -d "Report ready" ntfy.sh/mytopic
```

## Scheduled Delivery

```bash
# Relative delay
curl -H "Delay: 30m" -d "Reminder" ntfy.sh/mytopic
curl -H "At: tomorrow 9am" -d "Stand-up time" ntfy.sh/mytopic

# Absolute timestamp
curl -H "Delay: 1639194738" -d "Scheduled alert" ntfy.sh/mytopic
```

Min: 10 seconds. Max: 3 days. Cancel with `DELETE ntfy.sh/mytopic/<message-id>`.

## Authentication

```bash
# Basic auth
curl -u "user:pass" -d "Hello" ntfy.sh/mytopic

# Access token
curl -H "Authorization: Bearer tk_yourtoken" -d "Hello" ntfy.sh/mytopic

# Query params
curl -d "Hello" "ntfy.sh/mytopic?user=alice&pass=secret"
```

## Markdown

```bash
curl -H "Markdown: yes" \
  -d "**Bold** and _italic_ and \`code\`" ntfy.sh/mytopic
```

## JSON Payload (all fields)

```json
{
  "topic": "mytopic",
  "message": "Backup complete",
  "title": "Server Alert",
  "priority": 4,
  "tags": ["warning", "server"],
  "click": "https://example.com",
  "icon": "https://example.com/icon.png",
  "attach": "https://example.com/backup.zip",
  "filename": "backup.zip",
  "delay": "30m",
  "email": "user@example.com",
  "markdown": true,
  "actions": [
    {"action": "view", "label": "Open", "url": "https://example.com"},
    {"action": "http", "label": "Ack", "url": "https://api.example.com/ack", "method": "POST"}
  ]
}
```

## Self-Hosted

Replace `ntfy.sh` with your server URL. Config at `/etc/ntfy/server.yml`. Custom templates in `/etc/ntfy/templates/`.

## Common Mistakes

- **Predictable topic names**: Anyone who knows the topic can subscribe. Use random strings for sensitive notifications.
- **Large attachments**: Local uploads expire after 3 hours and are capped at 15 MB. Use `X-Attach` for permanent external files.
- **Action format**: Multiple actions use semicolons as separators in the header, but commas within each action definition.
