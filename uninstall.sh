#!/usr/bin/env bash
# claude-recall uninstaller — removes the tool and its local index.
# Your memory notes under ~/.claude/projects/*/memory/ are NOT touched.
set -euo pipefail

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
DEST="$CLAUDE_DIR/recall"
CMDDIR="$CLAUDE_DIR/commands"

rm -f "$DEST/recall" "$DEST/recall-index" \
      "$DEST/recall.db" "$DEST/recall.db-wal" "$DEST/recall.db-shm"
rm -f "$CMDDIR/recall.md"
rmdir "$DEST" 2>/dev/null || true

echo "✓ claude-recall removed. Your memory notes were left untouched."
