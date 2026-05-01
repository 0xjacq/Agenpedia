# Changelog

All notable schema changes are documented here. Skill changes are tracked in [0xjacq/skills CHANGELOG](https://github.com/0xjacq/skills/blob/main/CHANGELOG.md).

Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
Schema versioning: `schema_version` in `AGENTS.md` frontmatter.

## [1.0.0] — 2026-05-01

### Added
- Initial schema: `entity`, `concept`, `synthesis` page types
- `raw/` immutable source policy with `_ingested/`, `_skipped/`, `assets/` layout
- Bidirectional `[[wikilinks]]` convention
- `wiki/index.md` and `wiki/log.md` format
- `AGENTS.md` as canonical instruction file with `CLAUDE.md` / `GEMINI.md` pointer stubs
- `Configured Tools` section for harness-neutral tool references
- `scripts/hooks/pre-commit-lint.sh` opt-in wikilink checker
