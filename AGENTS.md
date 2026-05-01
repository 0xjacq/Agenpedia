---
schema_version: 1
template_name: Agenpedia
template_repo: https://github.com/0xjacq/Agenpedia
skills_dependency: "0xjacq/skills (category: agenpedia)"
---

# Agenpedia — Wiki Schema

This file governs all agent behavior when reading, writing, and maintaining
the wiki. It is co-evolved: start minimal, refine with usage.

## Directory Structure

```
your-project/          # Project root (git repo)
├── raw/                # Immutable source documents (NOT in Obsidian vault)
│   ├── _ingested/      # Sources already processed into wiki pages
│   ├── _skipped/       # Sources triaged as low-value by ingest-batch
│   ├── assets/         # Images and binary attachments
│   └── *.md / *.pdf    # Raw sources (web clips, PDFs, notes)
├── wiki/               # Obsidian vault root
│   ├── .obsidian/      # Obsidian config (auto-generated)
│   ├── index.md        # Page catalog grouped by type
│   ├── log.md          # Append-only operation journal
│   └── *.md            # Wiki pages
├── AGENTS.md           # This file — wiki schema
└── .gitignore          # Excludes workspace files, OS files
```

The Obsidian vault root is `wiki/`, not the project root. `raw/` is
not visible in Obsidian — it is managed by the agent and the human via
the filesystem. All wikilinks are between `wiki/` pages only.
References to raw sources in frontmatter use plain relative paths from
the project root (e.g. `raw/filename.md`), not wikilinks.

All paths in this schema are relative to the project root. `wiki/` is
flat: no subdirectories, no nested folders. The agent never creates
folders inside `wiki/`.

## Raw/ Write Policy

- The agent **can** create new files in `raw/`. Sources arrive in
  many ways:
  - Human drops files manually (web clips, PDFs, notes)
  - Human pastes text in chat → agent saves it as a `.md` in `raw/`
  - Agent fetches a URL and saves the content to `raw/`
  - Agent does web search and saves results to `raw/`
- Once a file exists in `raw/`, it is **immutable** — never edit
  or delete it.

## Page Types & Frontmatter

Every wiki page in `wiki/` has YAML frontmatter:

```yaml
---
type: entity | concept | synthesis
origin: query              # optional — set on synthesis pages born from a query
date: YYYY-MM-DD
sources:
  - "raw/source-file.md"
aliases: []
tags: []
---
```

| Type | Purpose | Created by |
|------|---------|------------|
| entity | Describes a person, org, tool, or named thing | Ingest (auto-created) |
| concept | Explains an idea, technique, or principle | Ingest (auto-created) |
| synthesis | Distills and connects ideas from one or more sources into a cohesive page. Ranges from single-source distillation to multi-source thematic analysis. | Ingest or Query |

**Entity vs. concept**: If it has a proper name (a person, org, product,
tool), it's an entity. If it's an idea that can be explained without
naming a specific product, it's a concept.

## Naming Conventions

- **Wiki pages**: lowercase, hyphen-separated, descriptive
  - `transformer-architecture.md`, `andrej-karpathy.md`, `attention-mechanism.md`
- **Raw sources**: original or descriptive filename, kept as-is after commit
- **Assets**: stored in `raw/assets/`, referenced in wiki page body via
  relative path from project root (e.g. `raw/assets/image.png`)

## Language Policy

- Wiki pages are written in **English**.
- Raw sources stay in their original language (never translated).
- Page filenames are always in English, lowercase, hyphenated
  (this is a naming convention, not a language choice).

## Workflows

Wiki workflows are implemented as skills installed via `npx skills`.

| Skill | Purpose | Example |
|-------|---------|---------|
| `ingest` | Ingest a source into the wiki (file, URL, text, or topic) | "Ingest raw/article.md" |
| `ingest-batch` | Triage and batch-ingest uncovered raw sources | "Batch ingest new sources" |
| `query` | Query the wiki with a natural language question | "What is attention?" |
| `lint` | Check wiki health and fix structural issues | "Run a wiki health check" |

A pre-commit hook is available at `scripts/hooks/pre-commit-lint.sh`.
Install it by running: `git config core.hooksPath scripts/hooks`

## Cross-Reference Rules

- Use `[[wikilinks]]` for links between wiki pages (Obsidian syntax)
- Wikilinks are **wiki-to-wiki only** — all targets must be pages in `wiki/`
- Links must be **bidirectional**: if page A links to page B, page B should link back
- Entity and concept pages accumulate links from every source that mentions them
- Raw source references go in frontmatter `sources` field as **plain paths**
  (e.g. `raw/filename.md`), never as wikilinks

## Index Format (`wiki/index.md`)

```markdown
# Wiki Index

## Entities
- [[entity-name]] — One-line description

## Concepts
- [[concept-name]] — One-line description

## Syntheses
- [[synthesis-name]] — One-line description
```

**Invariant**: Every wiki page has exactly one index entry. No page
exists without an entry. No entry exists without a page.

Entries are sorted alphabetically within each section.

## Log Format (`wiki/log.md`)

```markdown
# Wiki Log

## [YYYY-MM-DD] type | title
Brief description of what happened.
```

- **Types**: `ingest`, `query`, `lint`, `schema-update`
- **Order**: Reverse chronological (newest at top, below the `# Wiki Log` heading)
- **Insert-at-top-only**: new entries go below the heading, above all
  previous entries. Existing entries are never edited or deleted

---

## Skills

Skills are installed from [0xjacq/skills](https://github.com/0xjacq/skills), category `agenpedia`.

```bash
# Install all wiki skills (auto-detects your coding agent)
npx skills add https://github.com/0xjacq/skills/tree/main/skills/agenpedia --all

# Target a specific agent
npx skills add https://github.com/0xjacq/skills/tree/main/skills/agenpedia -a claude-code
npx skills add https://github.com/0xjacq/skills/tree/main/skills/agenpedia -a gemini-cli
npx skills add https://github.com/0xjacq/skills/tree/main/skills/agenpedia -a opencode
npx skills add https://github.com/0xjacq/skills/tree/main/skills/agenpedia -a kilo
npx skills add https://github.com/0xjacq/skills/tree/main/skills/agenpedia -a pi
npx skills add https://github.com/0xjacq/skills/tree/main/skills/agenpedia -a codex
```

## Configured Tools

Project owners: fill in the right column to tell the agent which concrete tool to use for each role.

| Role | Description | Set by project to |
|------|-------------|-------------------|
| `web-search` | Perform web searches (topic search, fact-checking) | _(e.g., Exa MCP, Brave MCP, or harness built-in WebSearch)_ |
| `web-fetch` | Fetch and read a URL | _(e.g., Exa MCP, or harness built-in WebFetch)_ |
| `deep-thinking` | Extended / deep reasoning | _(e.g., extended thinking on Claude, or no-op on harnesses that lack it)_ |

---

When the wiki exceeds ~100 pages, consider adding local markdown
search (e.g., qmd) as a complement to index.md navigation.
