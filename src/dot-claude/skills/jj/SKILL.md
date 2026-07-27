---
name: jj
description: Jujutsu (jj) reference — command flags, revsets, recovery, and the editor traps. Load before any command that mutates a jj repo.
---

# jj

## Never spawn an editor

`ui.editor` is a terminal editor and `ui.diff-editor` is jj's builtin TUI. Neither can be driven from a tool call, so every mutating command must be fully specified on the command line.

| Command | Safe form |
| --- | --- |
| commit | `jj commit -m "msg"` — prefer over `describe`; advances `@` in one step. On an already-described `@` it **replaces** that description: see "Before editing files" |
| describe | `jj describe -r <rev> -m "msg"` — never `--edit` |
| new | `jj new -m "msg"` |
| split | `jj split -r <rev> -m "msg" <paths>` — filesets required; never `-i`/`--tool`/`--editor` |
| squash | `jj squash -u` — never `-m`, which discards the destination's description |

For any mutating command not listed, assume its default opens an editor and check `--help` before running it. If one does open, the command stalls until it times out and the result is ambiguous — check `jj op log` to see whether it landed before retrying.

## Messages

50-character subject, imperative, only the first letter capitalized. A body is rare; wrap it at 72. Describe what and why, never how.

## Concurrent edits

Zak rearranges jj history while I'm working, and does so routinely. When something looks unexpected — `@` moved, commit IDs changed, an unfamiliar parent, a stale working copy — his concurrent work is the likelier cause than my own last command. Don't narrate a theory in which I broke it.

Ask him what he did. Never run `jj undo` or `jj op restore` to "fix" surprising history: his operations are in that same log, and restoring past them throws his work away. `jj op log` shows what actually happened — read it before forming a theory. A stale working copy just needs `jj workspace update-stale`.

## Recovery

My own operations are logged and reversible, so prefer attempting one over asking permission for it.

```
jj undo              # reverse the last operation
jj op log            # inspect past state
jj op restore <id>   # return to it — rewinds Zak's operations too, so ask first
```

## Model

Reflexes carried over from git that produce wrong jj commands:

- The working copy **is** a commit (`@`, parent `@-`). There is no staging area; edits are snapshotted on the next jj command.
- Change IDs survive rewrites, commit IDs do not. Reference change IDs.
- Bookmarks are not branches and do not advance on commit. `jj bookmark set <name> -r @` before pushing.
- Revsets select revisions: `@-`, `trunk()..@`, `::@`, `empty()`, `mine()`.

## Before editing files

Edits land in whatever `@` currently is. If `@` already has a description, editing **amends that commit**, and a later `jj commit -m` then *replaces* its description — two logical changes fused under the second message, silently. Knowing that `@` is a commit does not prevent this; checking does.

Run `jj new` before starting a new logical change. When unsure what `@` is:

    jj log -r @ --no-graph -T 'if(description, "DESCRIBED — jj new first", "scratch — safe to edit")'

`jj commit -m` leaves `@` empty, so back-to-back commits are safe. The trap is editing after `jj describe -r @`, after `jj new -m "msg"` followed by `jj restore`, or on any `@` reached via `jj edit <rev>`.

Recovery, if it already happened: the pre-amend commit id survives in `jj op log` and stays reachable by id even when hidden. Reset `@` with `jj restore --from <pre-amend-id>`, then `jj new -m "..."` and `jj restore --from <fused-id>` to re-lay the second change as its own commit.

## Useful

- `jj diff --git` — the default word-level diff is ambiguous.
- `jj restore --from @- <path>` — drop one path from `@` without splitting.
- `jj absorb` — distribute changes into whichever ancestors last touched those lines.
- `jj log -r @ --no-graph -T 'empty'` — `true` means the working copy is clean.
- After any history reconstruction (squash rebuild, split, resurrect), prove the tree is unchanged: `jj diff --from <old-tip> --to @ --stat` must report zero changes. Old commit ids stay reachable after rewrites, so this works even once they're hidden.
- Commands work from any directory in the repo. Don't `cd` to the root.

## Boundaries

- Never push. Confirm before any other irreversible remote operation.
- Delegate workspace operations to the `workspace-manager` agent — it owns the naming and directory conventions.
