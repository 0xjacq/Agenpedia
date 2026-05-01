# Contributing to Agenpedia

## Schema changes

The wiki schema lives in `AGENTS.md`. To propose a change:

1. Open an issue describing the problem and proposed solution.
2. Bump `schema_version` in `AGENTS.md` frontmatter.
3. Add a `Migration` section to the CHANGELOG entry explaining how existing forks adapt.
4. Open a PR.

Breaking changes (renamed fields, removed types) require a major version bump.

## Skill changes

Skills live in [0xjacq/skills](https://github.com/0xjacq/skills), category `agenpedia`. Contribute skill improvements there.

## Adding harness support

New harness support is handled by `npx skills` — see [vercel-labs/skills](https://github.com/vercel-labs/skills). If your harness is missing from the supported list, open an issue or PR there.
