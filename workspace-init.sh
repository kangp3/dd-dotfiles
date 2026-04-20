#!/usr/bin/env bash
# workspace-init.sh — run once after workspace creation to complete Claude Code setup.
#
# Secrets are NOT available during install.sh, so plugin installation and
# settings.json setup must happen here instead.
#
# Usage: ~/dotfiles/workspace-init.sh

set -euo pipefail

DOTFILES="$HOME/dotfiles"

echo "=== Claude Code workspace init ==="

# 1. Write workspace-appropriate settings.json.
#    Overwrites the basic config installed by the claude-code devcontainer feature
#    but preserves apiKeyHelper (included in claude-settings.workspace.json).
cp "$DOTFILES/claude-settings.workspace.json" "$HOME/.claude/settings.json"
echo "✓ Wrote ~/.claude/settings.json"

# 2. Install Claude plugins.
#    All marketplace sources are now registered in settings.json (written above).
echo "Installing plugins..."
claude plugin install superpowers@superpowers-dev || true
claude plugin install trajectory-capture@trajectory-cc-plugin || true
claude plugin install trajectory-visualize@trajectory-cc-plugin || true
echo "✓ Plugins installed"

# 3. Ensure hooks are executable.
#    install.sh symlinks .claude/hooks/* from dotfiles to ~/.claude/hooks/.
chmod +x "$HOME/.claude/hooks/"* 2>/dev/null || true
echo "✓ Hooks are executable"

# 4. Sync nb-be team skills from dd-source.
SYNC_SCRIPT="$HOME/dd/dd-source/domains/notebooks/.claude/skills/sync-skills/sync-claude-skills.sh"
if [[ -x "$SYNC_SCRIPT" ]]; then
    "$SYNC_SCRIPT"
    echo "✓ Skills synced"
else
    echo "⚠ Skill sync script not found — run after dd-source is cloned: $SYNC_SCRIPT"
fi

echo ""
echo "Done. Restart claude to pick up the new settings and plugins."
