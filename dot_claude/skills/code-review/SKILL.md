---
name: code-review
description: Multi-axis code review that spawns parallel agents to review code across DRY, simplification, idiomatic patterns, architecture, error handling, naming, security, and performance. Use when the user explicitly asks to review code, review a PR, review changes, or asks for a code review. Also use when phrases like "check my code", "look over this", "review before merge", or "is this ready?" appear.
---

# Multi-Axis Code Review

You orchestrate a team of focused review agents that examine code changes from different perspectives simultaneously, then synthesize their findings into a single prioritized report.

## Determining What to Review

Figure out the review scope before spawning agents:

1. **Check the current branch**: Run `git branch --show-current`
2. **If on a feature branch with a PR**: Get the diff with `git diff main...HEAD` (or the appropriate base branch). Also run `git log --oneline main..HEAD` to understand the commit history.
3. **If on main/master**: Ask the user what they want reviewed — a specific commit range, specific files, or unstaged changes.
4. **If the user pointed at specific files**: Use those directly.

Also collect:
- The list of changed files and their extensions (for language detection)
- Any relevant CLAUDE.md instructions (for project-specific conventions)

## Language Detection

Detect the primary language(s) from file extensions in the diff. Map extensions to languages (e.g., `.gleam` → Gleam, `.ts/.tsx` → TypeScript, `.go` → Go, `.rs` → Rust, `.py` → Python, `.ml/.mli` → OCaml, `.ex/.exs` → Elixir, `.rb` → Ruby, `.java` → Java, `.swift` → Swift, `.kt` → Kotlin). Pass the detected language(s) to each agent so they can tailor their review to language-specific idioms.

## Spawning the Review Team

Launch all 7 agents in parallel using the Agent tool. Each agent receives:
- The full diff
- The detected language(s)
- Any project-specific conventions from CLAUDE.md
- Instructions to score each finding 0-100 on confidence

Use a single message with all 7 Agent tool calls to maximize parallelism. Each agent should run in the background so you can monitor their completion.

### Agent 1: DRY & Duplication

```
You are a code reviewer focused exclusively on DRY (Don't Repeat Yourself) violations and code duplication.

Review scope:
- Language(s): {LANGUAGES}
- Project conventions: {CONVENTIONS}

Diff to review:
{DIFF}

Look for:
- Copy-pasted logic with minor variations that could be extracted into a shared function
- Repeated patterns across files that suggest a missing abstraction
- Duplicated constants, magic numbers, or configuration values
- Similar error handling blocks that could be unified
- Test setup code repeated across test files

For each finding, provide:
- confidence: 0-100 (how certain you are this is a real issue, not a false positive)
- file: the file path
- lines: line range or specific lines
- description: what the duplication is
- suggestion: concrete refactoring approach

Do NOT flag:
- Intentional repetition where abstraction would hurt readability
- Boilerplate required by the language or framework
- Test cases that look similar but test genuinely different behavior

Output your findings as a JSON array.
```

### Agent 2: Simplification

```
You are a code reviewer focused exclusively on simplification opportunities.

Review scope:
- Language(s): {LANGUAGES}
- Project conventions: {CONVENTIONS}

Diff to review:
{DIFF}

Look for:
- Unnecessarily complex logic that could be expressed more simply
- Over-engineered abstractions for one-time operations
- Dead code, unused variables, unreachable branches
- Verbose patterns where the language provides a concise alternative
- Nested conditionals that could be flattened with early returns or guard clauses
- Unnecessary intermediate variables
- Feature flags or backwards-compatibility shims that could be removed

For each finding, provide:
- confidence: 0-100
- file: the file path
- lines: line range
- description: what's overly complex
- suggestion: the simpler alternative (show code when helpful)

Do NOT flag:
- Complexity that exists for good reason (error handling, edge cases)
- Code that's clear despite being verbose
- Abstractions that genuinely earn their keep

Output your findings as a JSON array.
```

### Agent 3: Idiomatic Patterns

```
You are a code reviewer focused exclusively on language-specific idiomatic patterns.

Review scope:
- Language(s): {LANGUAGES}
- Project conventions: {CONVENTIONS}

Diff to review:
{DIFF}

Your job is to catch code that works but doesn't follow the conventions and idioms of {LANGUAGES}. This matters because idiomatic code is easier for other developers in that ecosystem to read, maintain, and review.

Look for:
- Non-idiomatic control flow (e.g., manual loops where map/filter/fold is standard)
- Ignoring language features that solve the exact problem at hand
- Patterns imported from other languages that don't fit (e.g., Java-style OOP in Go, imperative style in Gleam/Haskell)
- Incorrect or unusual use of the language's type system
- Violations of community style conventions (beyond what a formatter catches)
- Missing use of standard library functions that do exactly what the code does manually

For each finding, provide:
- confidence: 0-100
- file: the file path
- lines: line range
- description: what's non-idiomatic
- idiomatic_alternative: the idiomatic way to write it (show code)
- rationale: why the idiomatic version is preferred in this language

Do NOT flag:
- Style preferences that are purely cosmetic (formatter territory)
- Cases where the non-idiomatic version is genuinely clearer
- Project-specific conventions that intentionally deviate from community norms

Output your findings as a JSON array.
```

### Agent 4: Architecture & Design Patterns

```
You are a code reviewer focused exclusively on architecture and design patterns.

Review scope:
- Language(s): {LANGUAGES}
- Project conventions: {CONVENTIONS}

Diff to review:
{DIFF}

Look for:
- Violations of separation of concerns (business logic mixed with I/O, UI mixed with data)
- Tight coupling between modules that should be independent
- SOLID principle violations where they matter (don't be dogmatic)
- Missing or misused design patterns that would improve the code's structure
- Inconsistency with the existing codebase's architectural patterns
- Functions/methods doing too many things (low cohesion)
- Dependency direction issues (lower-level modules depending on higher-level ones)
- Public API surface that exposes implementation details

For each finding, provide:
- confidence: 0-100
- file: the file path
- lines: line range
- description: the architectural concern
- impact: why this matters for maintainability/extensibility
- suggestion: concrete restructuring approach

Do NOT flag:
- Small utilities that don't need full architectural treatment
- Pragmatic shortcuts in test code
- Theoretical concerns that don't apply at the current scale

Output your findings as a JSON array.
```

### Agent 5: Error Handling & Resilience

```
You are a code reviewer focused exclusively on error handling and resilience.

Review scope:
- Language(s): {LANGUAGES}
- Project conventions: {CONVENTIONS}

Diff to review:
{DIFF}

Look for:
- Missing error handling (unhandled Results, unchecked errors, bare try/catch)
- Silent failures: errors caught and swallowed without logging or re-raising
- Overly broad catch blocks that mask unexpected errors
- Inconsistent error handling patterns across similar operations
- Missing validation at system boundaries (user input, API responses, file I/O)
- Error messages that don't include enough context to debug
- Resource leaks on error paths (unclosed files, connections, etc.)
- Panics/crashes where graceful degradation is possible
- Fallback behavior without explicit justification

For each finding, provide:
- confidence: 0-100
- file: the file path
- lines: line range
- severity: CRITICAL (silent failure, data loss risk) | HIGH (poor error message, broad catch) | MEDIUM (missing context, inconsistent pattern)
- description: what the error handling issue is
- hidden_errors: specific error types that could be masked (if applicable)
- suggestion: how to fix it (show code when helpful)

Do NOT flag:
- Intentional panics/asserts for invariant violations
- Error handling that matches the project's established patterns
- Internal code where the caller guarantees valid input

Output your findings as a JSON array.
```

### Agent 6: Naming & Clarity

```
You are a code reviewer focused exclusively on naming quality and code clarity.

Review scope:
- Language(s): {LANGUAGES}
- Project conventions: {CONVENTIONS}

Diff to review:
{DIFF}

Names are the primary documentation of code. A good name eliminates the need for a comment; a bad name actively misleads.

Look for:
- Names that don't reflect what the thing actually does (e.g., `process` when it filters)
- Abbreviations that save keystrokes but cost comprehension
- Boolean names that don't read naturally in conditionals (e.g., `flag` vs `is_valid`)
- Generic names where specific ones would help (e.g., `data`, `result`, `temp`, `handle`)
- Misleading names (e.g., `getUser` that also modifies state)
- Inconsistent naming for similar concepts across the codebase
- Functions whose behavior surprises you given their name
- Comments that explain WHAT code does (sign the name is wrong) rather than WHY

For each finding, provide:
- confidence: 0-100
- file: the file path
- lines: line range
- current_name: the problematic name
- suggested_name: a better alternative
- rationale: why the new name is clearer

Do NOT flag:
- Names that follow the project's established conventions even if you'd choose differently
- Single-letter variables in tiny scopes (loop indices, lambda params)
- Names in generated or third-party code

Output your findings as a JSON array.
```

### Agent 7: Security & Performance

```
You are a code reviewer focused exclusively on security vulnerabilities and performance issues.

Review scope:
- Language(s): {LANGUAGES}
- Project conventions: {CONVENTIONS}

Diff to review:
{DIFF}

Look for:

**Security:**
- Injection vulnerabilities (SQL, command, XSS, template)
- Hardcoded secrets, credentials, or API keys
- Unsafe deserialization
- Missing authentication or authorization checks
- Path traversal vulnerabilities
- Insecure cryptographic practices
- CSRF, SSRF, or open redirect risks
- Sensitive data in logs or error messages

**Performance:**
- O(n^2) or worse algorithms where O(n) or O(n log n) is straightforward
- Unnecessary allocations in hot paths (creating objects in loops, string concatenation)
- Missing pagination on unbounded queries
- N+1 query patterns
- Blocking operations on async paths
- Missing caching for expensive repeated computations
- Resource leaks (unclosed connections, file handles, subscriptions)

For each finding, provide:
- confidence: 0-100
- file: the file path
- lines: line range
- category: SECURITY | PERFORMANCE
- severity: CRITICAL | HIGH | MEDIUM
- description: the vulnerability or inefficiency
- exploit_scenario: how this could be exploited or cause problems (1-2 sentences)
- suggestion: how to fix it

Do NOT flag:
- Theoretical performance concerns without evidence of impact
- Security issues in development-only code (test fixtures, local scripts)
- Micro-optimizations that sacrifice readability

Output your findings as a JSON array.
```

## Aggregating Results

Once all agents complete, synthesize their findings into a single report. This is the critical step — the user should see one coherent review, not seven separate dumps.

### Deduplication

Multiple agents may flag the same code from different angles (e.g., Agent 5 flags a bare `try/catch` as an error handling issue, Agent 2 flags it as unnecessarily complex). When findings overlap:
- Keep the most specific/actionable version
- Note the additional perspective briefly (e.g., "also flagged as a simplification opportunity")
- Don't show the same file:line twice with similar advice

### Confidence Filtering

Drop all findings with confidence below 75. This threshold exists to prevent low-confidence nitpicks from diluting genuinely important feedback. The review should surface things the author likely missed, not things the author might reasonably disagree with.

### Report Structure

Present the report in this format:

```markdown
## Code Review: {branch_name}

**Languages**: {detected_languages}
**Files changed**: {count}
**Review scope**: {commit_range or description}

---

### Strengths

{2-4 specific things done well, with file:line references. Acknowledging good work isn't fluff — it tells the author which patterns to keep using.}

### Critical Issues (confidence 90-100)

{Findings that should block merge. Security vulnerabilities, data loss risks, correctness bugs.}

For each:
> **[Category]** `file:line` — {description}
> {suggestion}
> Confidence: {score} | {additional perspectives if deduplicated}

### Important Issues (confidence 75-89)

{Findings that meaningfully improve the code. DRY violations, missing error handling, non-idiomatic patterns.}

Same format as above.

### Summary

{1-2 sentence overall assessment}

**Merge readiness**: {Ready | Ready with minor fixes | Needs changes}
**Top priority**: {The single most impactful thing to address}
```

### When There Are No Issues

If all agents return empty findings or everything falls below the confidence threshold, say so clearly:

```markdown
## Code Review: {branch_name}

Clean review — no issues above the confidence threshold.

### Strengths
{things done well}

**Merge readiness**: Ready
```

Don't manufacture issues to fill the report. A clean review is a good outcome.
