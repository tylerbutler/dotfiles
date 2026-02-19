## Node.js
- Prefer pnpm when working in node projects.

## TypeScript
- Use proper types in place of any wherever possible.
- Prefer `satisfies` to `as` where possible.
- Do not add lint disables to work around type issues.

## Bash
- Prefer using:
  - fd to find
  - sd to sed
  - rg to grep

## Testing
- When asked to fix tests, don't fix some of them and leave others skipped. 
  When asked to fix tests, fix all of the ones requested.

## Git Configuration Rules
- Use conventional commits when committing. 
  - Format: type(scope): description
  - Examples: feat: add user authentication, fix: resolve parsing error, docs: update README
- Keep commit messages brief and don't include attribution.
- DO include commit bodies with brief details.