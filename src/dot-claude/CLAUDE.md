# Personal Preferences

## Communication
- Be terse and direct by default. Skip preamble and filler.
- When I ask "why" or request more detail, provide thorough context and reasoning.

## Autonomy
- Small, obvious changes: just do it.
- Larger or ambiguous changes: discuss the approach first.
- Never respond to PR comments, Slack messages, or any communication on behalf of the user. Only make the requested code/text fixes. Do not draft responses unless explicitly asked.

## Tools
- Use the Read tool (with `offset`/`limit`) to read files or subsets of files. Never use Bash (cat, head, tail, sed) for file reading.

## Code Philosophy
- Simplicity first. Prefer explicit over clever, minimize abstractions.
- Write idiomatic code for the language and frameworks in use.
- Follow surrounding conventions pragmatically, but look for opportunities to simplify and make things more idiomatic.
- Prefer declarative over imperative. Express intent through data, structure, and platform features rather than manual control flow and procedural wiring.
- Strongly prefer well-typed code. Don't add type-ignore directives or suppression comments; fix the underlying types instead.
- When implementing UI components, always use the framework's built-in patterns or platform APIs first (native HTML APIs like popover) before reaching for custom CSS hacks or complex abstractions.

## Comments & Documentation
- Avoid over-commenting and over-documenting.
- Function names, argument types, and return types should make purpose clear; don't add docstrings that just restate that.
- Use comments sparingly, only to explain *why*, not *what*.

## Testing
- Test user/consumer-facing functionality, not implementation details.
- Don't test that third-party libraries work as documented.
- Don't write trivial tests (e.g., asserting an attribute exists).
- For bug fixes: write a failing test that reproduces the bug first, verify it fails, then fix the code and confirm the test passes.

## Version Control
- Always use `jj` (Jujutsu), never `git`, for version control commands.
- Commits are cheap in jj. Commit with a terse message after each discrete unit of work.
- Commit message rules:
  - Limit the subject line to 50 characters, capitalizing only the first letter, and using the imperative mood.
  - In the rare case that a subject line is insufficient, wrap the body at 72 characters. Describe what was done and perhaps why, but never how.
- Before starting a new unit of work, ensure the working copy is clean: `jj log -r @ --no-graph -T 'empty'` returns `true` if clean. If dirty, `jj commit` or `jj new` first.
- Always pass `-m` to jj commands (commit, squash, describe, etc.) to avoid opening an editor. Prefer `jj commit -m` over `jj describe -m` to advance the working copy in one step.
- Always use `jj diff --git` for readable unified diffs. The default word-level format is ambiguous.
- jj works from anywhere in the repo — don't `cd` to the root before running commands.
- Never push on my behalf.

## Task Tracking
- If a `.beans/` directory exists in the project, run `beans prime` at session start and follow its guidance for task tracking.
- Prefer `beans` over TodoWrite or markdown checklists when `.beans/` is present.
- When completing a task from the beans tracker, always mark the bean as complete before moving to the next one. Do not skip task management bookkeeping.

## Code Reviews
- Always use the code-reviewer agent for PR reviews.
- Exception to terseness: explain the *why* behind review feedback, not just the issue.
- Use `gh pr` and `gh issue` subcommands instead of `gh api` whenever possible. The specific subcommands are auto-allowed; `gh api` requires manual approval.
