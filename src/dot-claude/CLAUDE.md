# Personal Preferences

## Communication
- Be terse and direct by default. Skip preamble and filler.
- When I ask "why" or request more detail, provide thorough context and reasoning.

## Autonomy
- Small, obvious changes: just do it.
- Larger or ambiguous changes: discuss the approach first.
- Never respond to PR comments, Slack messages, or any communication on behalf of the user. Only make the requested code/text fixes. Do not draft responses unless explicitly asked.
- When a message contains a plan with inline feedback (lines starting with `>`), find the feedback, update the plan to address it, and stay in plan mode. Do not start implementing.

## Don't defer as the default
- For findings (review, audit, bug claim): the design verdict — what shape the code should take if the finding is correct — comes before any scope decision. Deferrals ("pre-existing," "no callers yet," "out of scope") may follow the verdict; they cannot replace it.
- For implementation: prefer the thorough version when the cost difference is small, and don't base your cost estimates on human implementation time. Don't skip edge cases, error paths, or test coverage to save agent effort.
- Distinguish completable scope (analysis, tests, edge cases, error paths) from genuinely external work (deps, system rewrites). Push for completion on the first; flag the second.

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
- Use comments sparingly, only to explain *why*, not *what*. Restating the code in prose is still a *what*, even when it sounds explanatory (e.g. narrating CSS classes as "borderless, content-sized") — delete it.
- A good *why* is timeless: it stays true for a reader who never saw the previous version, the review thread, or the ticket. Before writing a comment, ask "would I write this if the code had always looked this way?" If no, it's process or history — cut it, or put it in the commit message.
- Never put process or history in comments/docstrings:
  - Task/ticket IDs (e.g. `sd #NNN`) — they aren't in git, so they're dangling pointers.
  - Reactions to review ("guards against reverting", "per review", "found by the audit").
  - Comparisons to a past or alternative implementation ("unlike before", "as `main` did", "previously we…"). Describe what the code does now.
- Document non-obvious preconditions and invariants, even when types are clear.

## Testing
- Test user/consumer-facing functionality, not implementation details.
- Don't test that third-party libraries work as documented.
- Don't write trivial tests (e.g., asserting an attribute exists).
- For bug fixes: write a failing test that reproduces the bug first, verify it fails, then fix the code and confirm the test passes.

## Version Control
- Always use `jj` (Jujutsu), never `git`. Load the `jj` skill before any command that mutates the repo.
- Commits are cheap in jj. Commit with a terse message after each discrete unit of work, and make sure the working copy is clean before starting a new one.
- Never push on my behalf.

## Code Reviews
- Use `/review` for the full workflow: code-reviewer agent + simplify pass.
- Reviewing a PR (`/review <number|url>`) checks the branch out in a persistent `.workspaces/review` workspace via a remote-tracking fetch, so the reviewer reads real files and findings cite head-revision line numbers. Never `gh pr checkout` or create a local bookmark (leaves a mutable head stuck in `jj log`). The workspace is reused and re-pointed each review — nothing to clean up between reviews; it just leaves a persistent `review@` line in the log. `/review-cleanup` fully removes it on the rare occasion you want that line gone. Local/self reviews skip all of this.
- Exception to terseness: explain the *why* behind review feedback, not just the issue.
- Use `gh pr` and `gh issue` subcommands instead of `gh api` whenever possible. The specific subcommands are auto-allowed; `gh api` requires manual approval.
