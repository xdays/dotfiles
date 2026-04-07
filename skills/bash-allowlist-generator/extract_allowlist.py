#!/usr/bin/env python3
"""
Analyze Claude Code session transcripts and extract non-destructive Bash command patterns
for use in settings.json permissions.allow.

Usage:
  python3 extract_allowlist.py [--projects-dir DIR] [--output json|text]
"""

import json
import os
import glob
import re
import argparse
from collections import defaultdict, Counter

DESTRUCTIVE_TERMS = {
    # Generic operations
    'delete', 'destroy', 'apply', 'update', 'patch', 'scale', 'create', 'drop',
    'truncate', 'remove', 'kill', 'stop', 'terminate', 'disable', 'drain', 'evict',
    'cordon', 'uncordon', 'rollout', 'restart', 'reset', 'replace',
    'merge', 'rebase', 'install', 'upgrade', 'uninstall', 'import', 'attach',
    'detach', 'reboot', 'modify', 'add', 'edit', 'exec', 'set', 'taint',
    'label', 'annotate', 'expose', 'put', 'write', 'format', 'init', 'plan',
    'cp', 'mv', 'rm', 'chmod', 'chown', 'mkdir', 'rmdir', 'start', 'autostart',
    'clone', 'boot', 'launch', 'provision', 'deploy',
    # Git-specific destructive
    'push', 'commit', 'checkout', 'pull', 'fetch', 'restore', 'stash',
    'cherry-pick', 'bisect', 'tag', 'remote',
    # helm/terraform
    'run', 'template',
}

DESTRUCTIVE_PREFIXES = (
    'delete-', 'create-', 'put-', 'add-', 'attach-', 'detach-',
    'modify-', 'remove-', 'terminate-', 'stop-', 'start-', 'reboot-', 'disable-',
)

# Tools where subcommands matter
SUBCMD_TOOLS = {
    'kubectl', 'aws', 'gcloud', 'helm', 'terraform', 'terragrunt',
    'docker', 'git', 'gh', 'eksctl', 'argocd', 'flux',
    'vault', 'consul', 'nomad', 'virsh', 'kops',
}


def collect_executed_commands(projects_dir):
    """Parse all JSONL files and return commands that were successfully executed."""
    tool_uses = {}
    executed_ids = set()

    files = glob.glob(os.path.join(projects_dir, "**/*.jsonl"), recursive=True)
    for f in files:
        try:
            with open(f) as fh:
                for line in fh:
                    try:
                        obj = json.loads(line)
                        msg = obj.get('message', {})
                        if not isinstance(msg, dict):
                            continue
                        content = msg.get('content', [])
                        if not isinstance(content, list):
                            continue

                        if msg.get('role') == 'assistant':
                            for item in content:
                                if (isinstance(item, dict)
                                        and item.get('type') == 'tool_use'
                                        and item.get('name') == 'Bash'):
                                    tid = item.get('id')
                                    cmd = item.get('input', {}).get('command', '')
                                    if tid and cmd:
                                        tool_uses[tid] = cmd

                        elif msg.get('role') == 'user':
                            for item in content:
                                if isinstance(item, dict) and item.get('type') == 'tool_result':
                                    tid = item.get('tool_use_id')
                                    if tid and not item.get('is_error') and tid in tool_uses:
                                        executed_ids.add(tid)
                    except Exception:
                        pass
        except Exception:
            pass

    return [tool_uses[tid] for tid in executed_ids]


def is_destructive(sub):
    """Return True if sub indicates a destructive operation."""
    if not sub:
        return False
    if sub in DESTRUCTIVE_TERMS:
        return True
    if any(sub.startswith(p) for p in DESTRUCTIVE_PREFIXES):
        return True
    # Check compound words like 'net-start', 'vol-clone', 'autostart'
    for part in re.split(r'[-_]', sub):
        if part in DESTRUCTIVE_TERMS:
            return True
    return False


def parse_first_cmd_tokens(cmd):
    """
    Extract (base, sub1, sub2) from the first meaningful segment of a command.
    Returns None if not a SUBCMD_TOOL or unparseable.
    """
    # Take first line, first pipe/semicolon/&& segment
    first = re.split(r'[|;&]', cmd.split('\n')[0])[0].strip()
    tokens = first.split()
    if not tokens:
        return None

    # Skip leading env var assignments (VAR=val)
    i = 0
    while i < len(tokens):
        tok = tokens[i]
        if '=' in tok and not tok.startswith('-'):
            name = tok.split('=')[0]
            if re.match(r'^[A-Z_][A-Z0-9_]*$', name):
                i += 1
                continue
        break

    if i >= len(tokens):
        return None

    base = os.path.basename(tokens[i])
    if base not in SUBCMD_TOOLS:
        return None

    # Collect up to 2 non-flag subcommand tokens
    subs = []
    j = i + 1
    while j < len(tokens) and len(subs) < 2:
        tok = tokens[j]
        if tok.startswith('-'):
            break
        if not re.match(r'^[a-zA-Z0-9_-]+$', tok):
            break
        subs.append(tok)
        j += 1

    sub1 = subs[0] if len(subs) > 0 else ''
    sub2 = subs[1] if len(subs) > 1 else ''
    return base, sub1, sub2


def extract_raw_patterns(commands):
    """
    For each SUBCMD_TOOL, collect {(sub1, sub2): count} from executed commands.
    Filters out destructive patterns.
    """
    tool_patterns = defaultdict(Counter)

    for cmd in commands:
        parsed = parse_first_cmd_tokens(cmd)
        if not parsed:
            continue
        base, sub1, sub2 = parsed

        if not sub1:
            continue
        if is_destructive(sub1) or is_destructive(sub2):
            continue

        tool_patterns[base][(sub1, sub2)] += 1

    return tool_patterns


def group_patterns(tool_patterns):
    """
    Apply grouping rules per (tool, sub1):

    1. Collect all sub2 values for each (tool, sub1).
    2. If sub2 values share a common prefix of ≥4 chars ending in '-':
       → emit one 'tool sub1 prefix:*' entry
    3. Remaining sub2 values (no shared prefix):
       - If 2+ distinct sub2 values → emit 'tool sub1:*' ONLY if sub1 is inherently
         read-only (i.e., sub2 values all represent reads). Otherwise keep individual.
       - Single sub2 → emit 'tool sub1 sub2:*'
    4. sub2='' → emit 'tool sub1:*'
    """
    result = []

    for tool in sorted(tool_patterns.keys()):
        counts = tool_patterns[tool]

        # Group by sub1
        sub1_map = defaultdict(Counter)  # sub1 -> {sub2: count}
        for (sub1, sub2), count in counts.items():
            sub1_map[sub1][sub2] += count

        for sub1 in sorted(sub1_map.keys()):
            sub2_counter = sub1_map[sub1]
            total = sum(sub2_counter.values())
            all_sub2 = list(sub2_counter.keys())

            # Case 1: no sub2 present
            if all_sub2 == ['']:
                result.append((f"{tool} {sub1}", total))
                continue

            # Separate empty-sub2 from non-empty
            has_empty = '' in sub2_counter
            non_empty = [s for s in all_sub2 if s]

            if not non_empty:
                result.append((f"{tool} {sub1}", total))
                continue

            # Find groups by first hyphen-separated prefix (e.g. 'describe-vpcs' → 'describe-')
            # This groups all 'describe-*' and 'list-*' variants together.
            prefix_groups = defaultdict(list)
            ungrouped = []

            for s in non_empty:
                if '-' in s:
                    # Use the first hyphen-delimited segment as the grouping prefix
                    prefix = s.split('-')[0] + '-'
                    if len(prefix) >= 3:
                        prefix_groups[prefix].append(s)
                        continue
                ungrouped.append(s)

            # Merge prefix groups: only keep prefixes with 2+ members
            solo_from_prefix = []
            for prefix, members in sorted(prefix_groups.items()):
                if len(members) >= 2:
                    count_sum = sum(sub2_counter[m] for m in members)
                    result.append((f"{tool} {sub1} {prefix}:*", count_sum))
                else:
                    solo_from_prefix.extend(members)

            # Remaining ungrouped items
            remaining = ungrouped + solo_from_prefix
            if has_empty:
                remaining.append('')

            if len(remaining) >= 2:
                # Multiple ungrouped sub2 values with no shared prefix.
                # Group at sub1 level only for tools/subcommands where sub1 is inherently read-only
                # (e.g. 'kubectl get', 'gcloud compute addresses', 'helm list').
                READ_ONLY_SUB1 = {
                    # kubectl — all these subcommands are inherently read-only
                    ('kubectl', 'get'), ('kubectl', 'describe'), ('kubectl', 'logs'),
                    ('kubectl', 'config'), ('kubectl', 'wait'), ('kubectl', 'api-resources'),
                    # git — these subcommands never modify state
                    ('git', 'diff'), ('git', 'log'), ('git', 'show'),
                    ('git', 'status'), ('git', 'branch'),
                    # helm read-only subcommands
                    ('helm', 'show'), ('helm', 'list'),
                    # gcloud — only projects/config are fully read-only;
                    # 'compute' is NOT included here because 'gcloud compute stop/delete' were seen
                }
                if (tool, sub1) in READ_ONLY_SUB1:
                    count_sum = sum(sub2_counter.get(s, 0) for s in remaining)
                    result.append((f"{tool} {sub1}:*", count_sum))
                else:
                    # Keep individual — sub1 level is too broad for this tool
                    for s in sorted(remaining):
                        count_val = sub2_counter.get(s, 0)
                        if s:
                            result.append((f"{tool} {sub1} {s}", count_val))
                        else:
                            result.append((f"{tool} {sub1}", count_val))
            elif len(remaining) == 1:
                s = remaining[0]
                count_val = sub2_counter.get(s, 0)
                if s:
                    result.append((f"{tool} {sub1} {s}", count_val))
                else:
                    result.append((f"{tool} {sub1}", count_val))

    return sorted(result, key=lambda x: (x[0].split()[0], x[0]))


def format_allowlist(patterns):
    """Format patterns as Bash() permission entries."""
    entries = []
    for pattern, _count in patterns:
        # Strip trailing ':*' that may have been appended during grouping
        core = pattern[:-2] if pattern.endswith(':*') else pattern
        entries.append(f"Bash({core}:*)")
    return entries


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        '--projects-dir',
        default=os.path.expanduser('~/.claude/projects'),
        help='Claude Code projects directory (default: ~/.claude/projects)',
    )
    parser.add_argument(
        '--output',
        choices=['json', 'text'],
        default='text',
        help='Output format (default: text)',
    )
    args = parser.parse_args()

    print(f"Scanning: {args.projects_dir}", flush=True)
    commands = collect_executed_commands(args.projects_dir)
    print(f"Executed Bash commands found: {len(commands)}", flush=True)

    tool_patterns = extract_raw_patterns(commands)
    grouped = group_patterns(tool_patterns)
    allowlist = format_allowlist(grouped)

    if args.output == 'json':
        print(json.dumps(allowlist, indent=2))
    else:
        print("\n# Suggested permissions.allow entries:")
        prev_tool = None
        for entry in allowlist:
            # Extract tool name for grouping blank lines
            m = re.match(r'Bash\((\S+)', entry)
            tool = m.group(1).split()[0] if m else ''
            if tool != prev_tool:
                print()
                prev_tool = tool
            print(f'  "{entry}",')


if __name__ == '__main__':
    main()
