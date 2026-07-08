---
description: Verbatim cross-project search over your Claude memory notes (local, no network)
argument-hint: <query...> [--project <slug>] [--limit N] [--exact]
allowed-tools: Bash(~/.claude/recall/recall:*), Bash(~/.claude/recall/recall-index:*)
---

# /recall

Searches every `~/.claude/projects/*/memory/**/*.md` note across ALL projects and returns the EXACT matching lines (never paraphrased), tagged by project for provenance. Runs a local ripgrep-exact lane plus an FTS5 BM25 lane, fused best-first. Local only, no network.

## Results

!`~/.claude/recall/recall --query-string "$ARGUMENTS"`

## How to present this

- The block above is the raw, verbatim output of the `recall` CLI. **Surface it to the user as-is.** Do NOT re-summarize, re-order, or paraphrase the matched lines — the whole point is byte-exact recall of the user's own notes.
- Each hit is `[project]  /abs/path:line` followed by a title and the source line(s) with context. The `# by project:` footer shows provenance counts.
- If the output says `no index at ...`, run `~/.claude/recall/recall-index` (via the Bash tool) to build it, then retry.
- If results look stale (a note was just edited), refresh with `~/.claude/recall/recall-index` (idempotent, incremental) and re-run.

## Notes

- Scope a query to one project (e.g. exclude client-A notes from a client-B search) with `--project <slug-substring>`, matched case-insensitively against the project slug.
- `--exact` uses only the fixed-string ripgrep lane (precise literals: CVE ids, hex offsets, versions, `foo->bar`).
- `--limit N` caps the number of hits (default 20).
