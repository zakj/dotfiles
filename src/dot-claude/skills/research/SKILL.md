---
name: research
description: Pre-implementation codebase exploration. Takes a topic to research, spawns parallel Explore agents, and saves findings to a file.
---

Research `$ARGUMENTS` by exploring the codebase from multiple angles, then consolidate findings into a reference file.

## Step 1: Decompose

Break the research topic into 3–5 orthogonal exploration axes. Each axis should cover a distinct aspect (e.g., data flow, configuration, tests, call sites, related patterns).

## Step 2: Explore

Spawn one **Explore** agent per axis, in parallel, with thoroughness "very thorough". Each agent should return concrete facts with file path and function/symbol references.

## Step 3: Consolidate

Deduplicate and organize findings into a single markdown file at `.claude/research/<YYYY-MM-DD>-<slug>.md` in the project root, where `<slug>` is a short kebab-case summary of the topic.

Use this format:

```markdown
# Research: [topic]
- **Query**: [original $ARGUMENTS]
- **Date**: YYYY-MM-DD

## [Axis Name]
1. Concrete fact with `path/to/file.ts:functionName` reference
2. ...

## Key Files
- `path/to/file.ts` — one-line role
```

## Step 4: Report

Tell the user the file path so they can clear context and reference it later.
