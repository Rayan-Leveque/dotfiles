# Global CLAUDE.md

Personal preferences that apply to every project.

## Interaction Style

- **Ask, don't assume**: Before architecture changes, creating new files, or choosing between valid approaches, use AskUserQuestion to present 2-3 options with descriptions.
- **Design decisions**: When multiple valid implementations exist (naming, file structure, module organization), stop and ask which approach I prefer.
- **Clarification prompts**: Whenever a task could be interpreted multiple ways or requires context about my intent, present a choice menu instead of proceeding on assumption.
- **Trigger moments**:
- Choosing between refactoring patterns ("consolidate into one file or split into modules?")
- API design (naming, parameter order, return types)
- Project structure decisions
- Testing strategy (unit vs integration, mocking approach)

Treat AskUserQuestion as a first-class tool — use it liberally when uncertain rather than guessing.

## Delegation

Delegate independent subtasks to subagents and keep working while they run. Intervene if a subagent goes off track or is missing relevant context.

## Documentation

After any substantial change to a codebase (new feature, config change, pipeline update, architecture decision), update the project's local CLAUDE.md **and README** to reflect the current state — including how to run scripts, launch commands, and any changed entry points — so future sessions start with an accurate picture.

When creating or updating a project CLAUDE.md, also ensure it is tracked in the dotfiles repo:
1. If `~/dotfiles/claude/projects/<project_name>/CLAUDE.md` doesn't exist, create it and replace the local file with a symlink pointing to it.
2. If the project is not listed in `~/dotfiles/setup.md`, add it under the `## Projets` section.
3. Commit and push `~/dotfiles` after any such change (`cd ~/dotfiles && git commit -am "..." && git push`).

## Karpathy Guidelines

Behavioral guidelines to reduce common LLM coding mistakes. Use when writing, reviewing, or refactoring code to avoid overcomplication, make surgical changes, surface assumptions, and define verifiable success criteria.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

### 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

### 3. Surgical Changes

**Touch only what you must. Clean up only what you break.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

### 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

## Machine context

@~/.claude/machine.md

