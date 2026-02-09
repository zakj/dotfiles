# Personal Preferences

## Communication
- Be terse and direct by default. Skip preamble and filler.
- When I ask "why" or request more detail, provide thorough context and reasoning.

## Autonomy
- Small, obvious changes: just do it.
- Larger or ambiguous changes: discuss the approach first.

## Code Philosophy
- Simplicity first. Prefer explicit over clever, minimize abstractions.
- Write idiomatic code for the language and frameworks in use.
- Follow surrounding conventions pragmatically, but look for opportunities to simplify and make things more idiomatic.
- Strongly prefer well-typed code. Don't add type-ignore directives or suppression comments; fix the underlying types instead.

## Comments & Documentation
- Avoid over-commenting and over-documenting.
- Function names, argument types, and return types should make purpose clear; don't add docstrings that just restate that.
- Use comments sparingly, only to explain *why*, not *what*.

## Testing
- Test user/consumer-facing functionality, not implementation details.
- Don't test that third-party libraries work as documented.
- Don't write trivial tests (e.g., asserting an attribute exists).

## Version Control
- Always use `jj` (Jujutsu), never `git`, for version control commands.
- Commits are cheap in jj. Commit with a terse message after each discrete unit of work.
- Commit message rules:
  - Limit the subject line to 50 characters, capitalizing only the first letter, and using the imperative mood.
  - In the rare case that a subject line is insufficient, wrap the body at 72 characters. Describe what was done and perhaps why, but never how.
- Never push on my behalf.

## Code Reviews
- Always use the code-reviewer agent for PR reviews.
- Exception to terseness: explain the *why* behind review feedback, not just the issue.
