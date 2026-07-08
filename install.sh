#!/usr/bin/env bash
# claude-recall installer — copies the tool into your Claude Code config dir.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
DEST="$CLAUDE_DIR/recall"
CMDDIR="$CLAUDE_DIR/commands"

echo "Installing claude-recall → $DEST"

command -v python3 >/dev/null 2>&1 || { echo "error: python3 is required." >&2; exit 1; }
if ! command -v rg >/dev/null 2>&1; then
  echo "warning: ripgrep (rg) not found — the exact-match lane will be skipped."
  echo "         install it with:  brew install ripgrep   (macOS)   or   apt install ripgrep"
fi

mkdir -p "$DEST" "$CMDDIR"
cp "$HERE/bin/recall" "$HERE/bin/recall-index" "$DEST/"
chmod +x "$DEST/recall" "$DEST/recall-index"
cp "$HERE/commands/recall.md" "$CMDDIR/recall.md"

echo "Building initial index…"
"$DEST/recall-index" || true

cat <<EOF

✓ claude-recall installed.

  CLI            : $DEST/recall <query>
  Slash command  : /recall <query>        (inside Claude Code)
  Refresh        : automatic on every search (incremental)

  Tip: add "$DEST" to your PATH to call 'recall' from anywhere.
EOF
