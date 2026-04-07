---
name: bash-allowlist-generator
description: Use when building or updating the Bash permissions.allow list in ~/.claude/settings.json, or when asked to analyze session transcripts for approved commands
---

# Bash Allowlist Generator

## Overview

Analyzes all Claude Code session transcripts to extract non-destructive Bash command patterns and produces a `permissions.allow` list for `~/.claude/settings.json`.

## When to Use

- User asks to build/update the Bash allowlist
- Reducing manual approval prompts for read-only CLI operations
- After adding new projects or tools that generated new command patterns

## Workflow

### 1. Locate and run the extraction script

```bash
SCRIPT=$(find ~/.claude/plugins -name "extract_allowlist.py" 2>/dev/null | head -1)
python3 "$SCRIPT"
# JSON output for piping:
python3 "$SCRIPT" --output json
# Custom projects dir:
python3 "$SCRIPT" --projects-dir ~/.claude/projects
```

### 2. Review output with user

Show the grouped patterns before writing. Key decisions:
- Are any groupings too broad?
- Are there `--profile` / `--context` flag variants that won't match?

### 3. Add `permissions` block to settings.json

```json
{
  "permissions": {
    "allow": [
      "Bash(kubectl get:*)",
      "Bash(aws ec2 describe-:*)"
    ]
  }
}
```

## Grouping Rules

| Situation | Result |
|-----------|--------|
| 2+ commands share `tool sub1 describe-` prefix | `tool sub1 describe-:*` |
| 2+ commands share `tool sub1` with varied sub2 | `tool sub1:*` |
| Single command | `tool sub1 sub2:*` |
| Parent level has mixed read/write ops | Keep individual (don't group up) |

**Example:** `kubectl get pods` + `kubectl get nodes` → `kubectl get:*` (all `kubectl get` are read-only)

**Counter-example:** `gcloud compute instances list` + `gcloud compute instances stop` seen → do NOT group as `gcloud compute instances:*`

## Exclusion Rules

The script excludes these subcommand terms as destructive:
`delete, destroy, apply, update, patch, scale, create, drop, remove, kill, stop, terminate, disable, drain, evict, cordon, uncordon, rollout, restart, reset, replace, push, merge, rebase, install, upgrade, uninstall, import, attach, detach, reboot, modify, add, edit, run, exec, set, taint, label, annotate, expose, put, write, format, init, plan, cp, mv, rm, chmod, chown, mkdir, rmdir, start, autostart, clone, boot, launch, provision, deploy`

Also excludes sub2 tokens starting with: `delete-, create-, put-, add-, attach-, detach-, modify-, remove-, terminate-, stop-, start-, reboot-, disable-`

## Known Limitations

**Flag-prefixed commands won't match:**
- `aws --profile myprofile ec2 describe-*` → does NOT match `Bash(aws ec2 describe-:*)`
- `kubectl --context prod get pods` → does NOT match `Bash(kubectl get:*)`
- These commands will still require manual approval

**Virsh via env var / ssh:**
- Commands run as `export LIBVIRT_DEFAULT_URI=... && virsh ...` start with `export`, not `virsh`
- Add them manually if needed

**Manual additions for flag patterns (example):**
```json
"Bash(aws --profile loop-staging ec2 describe-:*)",
"Bash(aws --profile loop-prod ec2 describe-:*)"
```

## Quick Reference

```bash
# Check what's currently allowed
cat ~/.claude/settings.json | python3 -m json.tool | grep -A50 '"allow"'

# Locate the script
SCRIPT=$(find ~/.claude/plugins -name "extract_allowlist.py" 2>/dev/null | head -1)

# Dry-run to see patterns without writing
python3 "$SCRIPT"

# Rerun after new sessions to pick up newly approved commands
python3 "$SCRIPT" --output json
```
