---
description: Verbatim cross-project search over your Claude Code memory notes (local, no network)
argument-hint: <query...> [--project <slug>] [--limit N] [--exact]
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/bin/recall:*)
---

# /recall

Searches every `~/.claude/projects/*/memory/**/*.md` note across ALL projects and returns the EXACT matching lines (never paraphrased), tagged by project for provenance. Runs a local ripgrep-exact lane plus an FTS5 BM25 lane, fused best-first. The index auto-refreshes before each search. Local only, no network.

## Results

!`${CLAUDE_PLUGIN_ROOT}/bin/recall --query-string "$ARGUMENTS"`

## How to present this

- The block above is the raw, verbatim output of the `recall` CLI. **Surface it to the user as-is.** Do NOT re-summarize, re-order, or paraphrase the matched lines — the whole point is byte-exact recall of the user's own notes.
- Each hit is `[project]  /abs/path:line` followed by a title and the source line(s) with context. The `# by project:` footer shows provenance counts.

## Notes

- Scope a query to one project (e.g. exclude client-A notes from a client-B search) with `--project <slug-substring>`, matched case-insensitively against the project slug.
- `--exact` uses only the fixed-string ripgrep lane (precise literals: CVE ids, hex offsets, versions, `foo->bar`).
- `--limit N` caps the number of hits (default 20).
