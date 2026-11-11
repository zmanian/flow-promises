# flow-promises (standalone)

The `flow-promises` skill from pstack, with its `statechart` checker bundled, so it installs as one folder. See `flow-promises/PROVENANCE.md` for the source commit and the changes.

## Install

```sh
ln -s "$PWD/flow-promises" ~/.claude/skills/flow-promises
```

Then run `/flow-promises`. The skill keeps upstream's `disable-model-invocation: true`, so Claude only runs it when you type the command. Delete that line from `SKILL.md` to let Claude pick it up by itself.

## What it runs

`flow-promises/scripts/check FLOW.qnt [--config FILE] [--view FILE] [--out DIR]`

| Tool | Version | Used for | If missing |
| --- | --- | --- | --- |
| Node | 22.18+ or 23.6+ (or Bun 1.1.5+, Deno 2+) | runs `statechart.ts` and `render.mjs` | error |
| Quint | 0.33.0 | Quint to TLA+ | `npx --yes @informalsystems/quint@0.33.0` |
| Java | 21+ for Quint, 11+ for TLC | Apalache and TLC | `mise install java@temurin-25` |
| TLC | `tla2tools.jar` 1.7.4, sha256 pinned in `statechart/scripts/run.ts` | model checking | `mise install`, or set `TLA2TOOLS` and `JAVA` |
| Pele | 1.9.0 | Mermaid to SVG | `npm install` into `~/.cache/flow-promises/` |

Without mise, put a JDK on `PATH` and set `TLA2TOOLS=/path/to/tla2tools.jar` and `JAVA=/path/to/java`.

## Check that it stays standalone

```sh
tools/check-standalone.sh
```

It fails if a link or script path leaves the skill folder or still names the pstack tree.
