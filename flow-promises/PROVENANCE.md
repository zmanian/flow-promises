# Provenance

Extracted from pstack by Lauren Tan (MIT, see `LICENSE`):

- Repo: https://github.com/bkase/plugins
- Commit: `6f35f6ae6b3581c499bdfcae080932b4ffa7e281` (2026-11-02), pstack 0.15.36
- Sources: `pstack/skills/flow-promises`, `pstack/skills/statechart`, `pstack/skills/principle-experience-first`

## Changes from upstream

- `statechart` is vendored under `statechart/` as a helper, not a separate skill. Its `SKILL.md` is now `statechart/GUIDE.md` without frontmatter, so this folder has one `SKILL.md`.
- `scripts/check` and `scripts/render.mjs` point at `../statechart/` instead of `../../statechart/`.
- `principle-experience-first` is copied to `references/experience-first.md`.
- Mentions of the `/statechart` command now link to `statechart/GUIDE.md`.
- The link to `create-formal-verification-skill` points at upstream. That skill is optional and not bundled.
- The Claude Code adapter line is dropped. Neither skill uses the Cursor tool names it maps.
- `statechart/scripts/test/` (3.7 MB corpus, needs `fast-check`) is left out, and `package.json` keeps only `"type": "module"`. To run the tests, copy `test/` back from upstream at the commit above.
