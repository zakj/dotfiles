---
name: review
description: Review changed code for bugs and quality, then simplify. Takes a PR number, file paths, or no args for local changes.
---

Review workflow: get the diff, spawn a code-reviewer agent, then run /simplify on the changed files. Don't narrate each step — just run the tools silently and report findings at the end.

## Step 1: Get the diff

Parse `$ARGUMENTS` to determine the diff source:

- **Number** (e.g., `123`): GitHub PR. Use `gh pr diff $NUM` for the diff.
- **jj revset** (prefixed with `rev`, e.g., `rev @-`, `rev trunk()..@`): Use `jj diff --git -r <revset>` for single revisions or `jj diff --git --from <from> --to <to>` for ranges.
- **File paths**: Local changes scoped to those files. Use `jj diff --from trunk() --git -- <paths>`.
- **Natural language or empty**: Infer what to review from the conversation context. Identify which files were recently changed in this session and use `jj diff --git` scoped to those files. If no conversation context exists, fall back to all local changes via `jj diff --from trunk() --git`.

## Step 2: Detect authorship (PR reviews only)

For PR reviews, run `gh pr view $NUM --json author --jq .author.login` and compare against the current user (`gh api user --jq .login`). Pass this context to the agent:
- Same user → "This is a self-review of your own code."
- Different user → "This is a review of someone else's code."

## Step 3: Review

Spawn a **code-reviewer** agent with the diff and authorship context. Let it produce its full report.

## Step 4: Simplify

Skip this step for non-self-authored GitHub PRs (not our code to simplify).

For local changes and self-authored PRs, determine which files were changed from the diff or args, then run `/simplify` on those files.
