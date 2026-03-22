# Personal Preferences

## Communication
- Be terse and direct by default. Skip preamble and filler.
- When I ask "why" or request more detail, provide thorough context and reasoning.

## Autonomy
- Small, obvious changes: just do it.
- Larger or ambiguous changes: discuss the approach first.
- Never respond to PR comments, Slack messages, or any communication on behalf of the user. Only make the requested code/text fixes. Do not draft responses unless explicitly asked.
- When a message contains a plan with inline feedback (lines starting with `>`), find the feedback, update the plan to address it, and stay in plan mode. Do not start implementing.

## Tools
- Use the Read tool (with `offset`/`limit`) to read files or subsets of files. Never use Bash (cat, head, tail, sed) for file reading.

## Code Philosophy
- Simplicity first. Prefer explicit over clever. Don't abstract prematurely, but extract when a pattern has proven itself across multiple uses.
- Write idiomatic code. Follow surrounding conventions pragmatically, but look for opportunities to simplify.
- Prefer declarative over imperative. Express intent through data, structure, and platform features rather than manual control flow and procedural wiring.
- Decompose complex logic into small, pure functions with explicit inputs and outputs. Keep side effects at the edges — confine I/O and mutation to orchestration layers.
- Strongly prefer well-typed code. Don't add type-ignore directives or suppression comments; fix the underlying types instead.
- Design data models to make wrong states unrepresentable. Minimize optional fields, compose independent concepts rather than flattening, use distinct types to prevent misuse.
- For UI components, prefer the framework's built-in patterns and platform APIs (e.g., native popover) over custom CSS hacks or complex abstractions.

## Comments & Documentation
- Avoid over-commenting and over-documenting.
- Function names, argument types, and return types should make purpose clear; don't add docstrings that just restate that.
- Use comments sparingly, only to explain *why*, not *what*.
- Document non-obvious preconditions and invariants, even when types are clear.

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
- Never spawn an interactive editor. Always pass `-m` to `jj commit`, `jj describe`, and `jj new`. Prefer `jj commit -m` over `jj describe -m` to advance the working copy in one step.
- `jj split` requires filesets to avoid spawning an interactive diff editor. Always pass file paths: `jj split -r <rev> -m "message" <filesets>`. Never use `--interactive` or `--tool` flags.
- For `jj squash`: never pass `-m` (it overwrites the destination description). Always pass `-u` (`--use-destination-message`) to keep the destination description and avoid spawning an editor.
- Always use `jj diff --git` for readable unified diffs. The default word-level format is ambiguous.
- jj works from anywhere in the repo — don't `cd` to the root before running commands.
- Never push on my behalf.

## Code Reviews
- Use `/review` for the full workflow: code-reviewer agent + simplify pass.
- Exception to terseness: explain the *why* behind review feedback, not just the issue.
- Use `gh pr` and `gh issue` subcommands instead of `gh api` whenever possible. The specific subcommands are auto-allowed; `gh api` requires manual approval.
