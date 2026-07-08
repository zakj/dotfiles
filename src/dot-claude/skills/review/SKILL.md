---
name: review
description: Review changed code for bugs and quality, then simplify. Takes a PR number or URL, file paths, or no args for local changes.
---

Review workflow: get the diff, spawn a code-reviewer agent, then run /simplify on the changed files. Don't narrate each step — just run the tools silently and report findings at the end.

## Step 1: Get the diff

Parse `$ARGUMENTS` to determine the diff source:

- **Number or GitHub PR URL** (e.g., `123` or `https://github.com/<owner>/<repo>/pull/123`): GitHub PR. `gh` accepts either form directly. Resolve the number once with `gh pr view <arg> --json number --jq .number` (used below as `$NUM`), then check the branch out in the review workspace (see "Step 1a") and use `gh pr diff <arg>` for the diff.
- **jj revset** (prefixed with `rev`, e.g., `rev @-`, `rev trunk()..@`): Use `jj diff --git -r <revset>` for single revisions or `jj diff --git --from <from> --to <to>` for ranges.
- **File paths**: Local changes scoped to those files. Use `jj diff --from 'trunk()' --git -- <paths>`.
- **Natural language or empty**: Infer what to review from the conversation context. Identify which files were recently changed in this session and use `jj diff --git` scoped to those files. If no conversation context exists, fall back to all local changes via `jj diff --from 'trunk()' --git`.

Only PRs (number or URL) use the workspace. Every other case reviews the local working copy directly — no workspace, no fetch.

## Step 1a: PR workspace setup (PR arg only)

Give the reviewer the exact PR revision as real files, without polluting `jj log`. **Never `gh pr checkout` or create a local bookmark** — a local (mutable) bookmark leaves the whole PR chain stuck as a visible head. Fetching as a remote-tracking bookmark keeps it immutable and hidden.

1. Metadata: `gh pr view $NUM --json headRefName,isCrossRepository,headRepositoryOwner`
2. Fetch the head as an immutable remote-tracking bookmark:
   - Same-repo (`isCrossRepository: false`): `jj git fetch -b <headRefName>` → `<headRefName>@origin`
   - Fork (`isCrossRepository: true`): add a throwaway remote, then fetch:
     - `jj git remote add pr-$NUM https://github.com/<headRepositoryOwner>/<repo>.git`
     - `jj git fetch --remote pr-$NUM -b <headRefName>` → `<headRefName>@pr-$NUM`
3. Ensure the review workspace exists (it's permanent and reused across reviews):
   - Ignore it locally without touching the team's tracked `.gitignore`: if `.workspaces/` isn't in `.git/info/exclude`, append it. (jj honors `.git/info/exclude`.)
   - If `jj workspace list` already has a `review` entry, it's ready — skip to step 4 and re-point it.
   - Otherwise create it: `mkdir -p .workspaces` (jj won't create the parent), then `jj workspace add .workspaces/review`.
   - If the add fails with "Destination path exists and is not an empty directory", a stale dir was left by an interrupted run. Move it aside and retry: `mv .workspaces/review "$(mktemp -d)/"` then `jj workspace add .workspaces/review`.
4. Point the workspace at the PR head — this auto-abandons the previous (empty) `review@`. jj selects the workspace from the cwd, so run this inside it:
   - `(cd "$(jj workspace root)/.workspaces/review" && jj new '<headRefName>@<remote>')`
   - If jj reports the review workspace is stale, run `jj workspace update-stale` from inside it first.
5. The PR tree now lives at `<repo-root>/.workspaces/review`. Note that absolute path — it's what you hand the reviewer in Step 3.

The workspace is left in place after the review — the next PR review reuses and re-points it, so there's nothing to clean up between reviews. It costs a persistent `review@` line (plus its labeled PR head) in `jj log`. Only mention `/review-cleanup` if the user wants those lines gone entirely.

## Step 2: Detect authorship (PR reviews only)

For PR reviews, run `gh pr view $NUM --json author --jq .author.login` and compare against the current user (`gh api user --jq .login`). Pass this context to the agent:
- Same user → "This is a self-review of your own code."
- Different user → "This is a review of someone else's code."

## Step 3: Review

Spawn a **my-code-reviewer** agent with the diff and authorship context. Let it produce its full report.

For PR reviews, also pass the absolute path to `.workspaces/review` and instruct the agent: **that directory is the exact PR revision — read, grep, and glob only within it, never the main working tree.** This is what keeps findings anchored to real head-revision line numbers you can drop straight onto the PR.

## Step 4: Simplify

Skip this step for non-self-authored GitHub PRs (not our code to simplify).

For local changes and self-authored PRs, determine which files were changed from the diff or args, then run `/simplify` on those files.
