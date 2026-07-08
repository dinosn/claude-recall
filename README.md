# claude-recall

**Verbatim, local, cross-project search over your [Claude Code](https://claude.com/claude-code) memory notes.**

Claude Code's native memory is *per-project* — notes you save in one repo don't surface when you're working in another. `claude-recall` indexes **every** project's memory notes into one searchable corpus, so you can recall a finding, decision, or fact from any past engagement — returned **byte-for-byte**, never paraphrased.

No cloud. No daemon. No embeddings service. Just `ripgrep` + SQLite FTS5 over the markdown you already have.

```
$ recall heap grooming
# recall: heap grooming   (3 shown / 20 hits | lanes: exact, fts:trigram)

[proj-a]  ~/.claude/projects/-Users-you-work-proj-a/memory/nginx_notes.md:13
    — Pool overflow grooming notes
  >    13│ groom the pool by interleaving 2KB allocs before the overflow write…

# by project: proj-a:3
```

## Why

- **Cross-project.** Native memory is siloed per directory; this searches all of `~/.claude/projects/*/memory/`.
- **Verbatim.** Matched lines are read live from disk and printed exactly — critical when your notes hold precise tokens (IDs, offsets, commit SHAs, version boundaries) that a summarize-then-embed system would paraphrase.
- **Local & private.** Nothing leaves your machine. No network calls anywhere. The only thing written is a local SQLite index; your notes are read-only.
- **Deterministic.** Same corpus + same query → identical, ranked output.
- **Zero-maintenance.** The index auto-refreshes (incrementally) on every search — add notes any day, they're found automatically.

## How it works

Two search lanes, fused with [Reciprocal Rank Fusion](https://en.wikipedia.org/wiki/Learning_to_rank):

1. **`ripgrep` exact** — fixed-string, smart-case scan for precise literals (`CVE-2024-1234`, `0xdeadbeef`, `1.2.3`, `foo->bar`, `path/to/file.c:1337`).
2. **SQLite FTS5 (trigram) BM25** — ranked lexical/fuzzy matching for concept queries.

Results are deduped by file+line, ranked best-first, and printed as `[project] path:line` + the note title + the verbatim source line(s). A `# by project:` footer shows provenance.

## Requirements

- **Python 3.8+** (standard library only — `sqlite3` with FTS5, which ships in modern builds)
- **[ripgrep](https://github.com/BurntSushi/ripgrep)** (`rg`) — for the exact lane (`brew install ripgrep` / `apt install ripgrep`). Optional but recommended; without it only the FTS lane runs.

## Install

### As a Claude Code plugin (recommended)

In Claude Code:

```
/plugin marketplace add dinosn/claude-recall
/plugin install claude-recall@dinosn
```

That's it — the `/recall` command is now available. The index builds itself on first search and auto-refreshes after that. Requires `python3` and (recommended) `ripgrep` on your `PATH`.

### As a standalone CLI (optional)

If you also want the `recall` command in your terminal (outside Claude Code):

```sh
git clone https://github.com/dinosn/claude-recall.git
cd claude-recall
./install.sh
```

This copies the scripts to `~/.claude/recall/`, registers the `/recall` command, and builds the initial index. Add `~/.claude/recall` to your `PATH` to call `recall` from anywhere.

## Usage

**CLI:**
```sh
recall <query>                     # search everything (auto-refreshes first)
recall CVE-2024-1234               # exact token
recall heap grooming               # fuzzy concept
recall RESTORE --project redis     # scope to one project (slug substring)
recall sdsfree --exact             # ripgrep-only, literal
recall <query> --no-refresh        # skip the auto-reindex for a faster read
recall-index                       # (rarely needed) manual full/incremental index
recall-index --rebuild             # force a full rebuild
```

*(After `./install.sh`, the scripts live at `~/.claude/recall/recall` — add that dir to your `PATH`, or call them by full path.)*

**In Claude Code:**
```
/recall heap grooming
```
Same index, same verbatim output.

## Guarantees

- **Local-only:** zero network calls; the sole subprocess is `rg`.
- **Read-only on your notes:** only `~/.claude/recall/recall.db` (+ its WAL/SHM) is ever written.
- **Verbatim:** displayed lines are read live from disk and are byte-exact (UTF-8 with surrogate-escape round-trip).
- **Safe:** the query is passed as literal search text — `ripgrep` is invoked with an argument vector (no shell), and FTS5 `MATCH` terms are quote-escaped and parameterized, so query content can't inject shell or SQL.
- **Deterministic:** stable ranking with explicit tie-breaks.

## Uninstall

```sh
./uninstall.sh
```
Removes the scripts, the `/recall` command, and the local index. **Your memory notes are untouched.**

## License

MIT © Nicolas Krassas ([@dinosn](https://github.com/dinosn))
