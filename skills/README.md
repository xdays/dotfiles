# xdays-skills

Personal Claude Code skills plugin by xdays.

## Skills

### bash-allowlist-generator

Analyzes Claude Code session transcripts to extract non-destructive Bash command patterns and generates a `permissions.allow` list for `~/.claude/settings.json`.

Useful for reducing repetitive approval prompts for read-only CLI operations (kubectl, aws, gcloud, etc.).

## Installation

This repo is configured as a Claude Code marketplace (`xdays-claude-plugins`). Add it and install skills:

```
/plugin marketplace add xdays/dotfiles
/plugin install bash-allowlist-generator@xdays-claude-plugins
```
