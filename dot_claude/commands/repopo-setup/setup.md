---
description: Configure repopo (repository policy enforcement) for any repository, with or without existing Node.js dependencies.
---

# Repopo Setup

Configure repopo to enforce repository policies (package.json validation, file headers, naming conventions).

## Context Discovery

First, gather context about the repository:
- Check for existing package.json: !`[ -f package.json ] && cat package.json | head -50 || echo "No package.json"`
- Check for existing repopo config: !`[ -f repopo.config.ts ] && cat repopo.config.ts || echo "No existing config"`
- Repository structure: !`ls -la`
- Is this a monorepo? !`ls -d packages/ apps/ 2>/dev/null || echo "Single package"`

## Your Task

Based on the context above:

1. **Determine repository type**: monorepo, single package, or non-Node.js project

2. **Install repopo** (if not already installed):
   - For existing Node.js projects: Add via pnpm/npm/yarn
   - For non-Node.js projects: Create minimal package.json first

3. **Ask the user** which policies they want to configure:
   - **Package.json policies**: sorted keys, required properties, script validation
   - **File policies**: headers, no .js files, no large binaries
   - **Repository policies**: LICENSE file, gitignore patterns

4. **Generate repopo.config.ts** with selected policies

5. **Add npm scripts** to package.json for easy execution

6. **Run initial check** to verify configuration works

## Available Policies

### Package.json Policies
- `PackageJsonSorted` - Sort keys (auto-fixable)
- `PackageJsonProperties` - Enforce fields: license, author, repository (auto-fixable)
- `PackageScripts` - Required/optional scripts
- `PackageEsmType` - Enforce ESM/CommonJS type
- `PackageFolderName` - Match folder to package name
- `PackageAllowedScopes` - Restrict npm scopes
- `PackagePrivateField` - Enforce private: true/false
- `PackageLicense` - Require license field
- `PackageReadme` - Require README

### File Policies
- `NoJsFileExtensions` - Require .mjs/.cjs (not .js)
- `JsTsFileHeaders` - Enforce file headers
- `HtmlFileHeaders` - HTML file headers

### Repository Policies
- `LicenseFileExists` - Require LICENSE file
- `NoLargeBinaryFiles` - Prevent large binaries
- `RequiredGitignorePatterns` - Enforce gitignore entries (auto-fixable)

## Example Configurations

### Minimal
```typescript
import { makePolicy, type RepopoConfig } from "repopo";
import { PackageJsonSorted, PackageLicense } from "repopo/policies";

const config: RepopoConfig = {
  policies: [
    makePolicy(PackageJsonSorted),
    makePolicy(PackageLicense),
  ],
};
export default config;
```

### Monorepo
```typescript
import { makePolicy, type RepopoConfig } from "repopo";
import {
  PackageJsonProperties,
  PackageJsonSorted,
  PackageScripts,
} from "repopo/policies";

const config: RepopoConfig = {
  excludeFiles: ["packages/vendored/"],
  policies: [
    makePolicy(PackageJsonProperties, {
      verbatim: {
        license: "MIT",
        author: "Name <email>",
        repository: { type: "git", url: "git+https://github.com/org/repo.git" },
      },
    }),
    makePolicy(PackageJsonSorted),
    makePolicy(PackageScripts, {
      must: ["build", "test"],
    }),
  ],
};
export default config;
```

### Non-Node.js Project (minimal enforcement)
```typescript
import { makePolicy, type RepopoConfig } from "repopo";
import { LicenseFileExists, RequiredGitignorePatterns } from "repopo/policies";

const config: RepopoConfig = {
  policies: [
    makePolicy(LicenseFileExists),
    makePolicy(RequiredGitignorePatterns, {
      patterns: [
        { pattern: ".env", comment: "Environment secrets" },
      ],
    }),
  ],
};
export default config;
```

## Installation Commands

**With pnpm (preferred):**
```bash
pnpm add -D repopo
```

**Without existing package.json:**
```bash
echo '{"private": true, "type": "module"}' > package.json
npm install -D repopo
```

**Running:**
```bash
npx repopo check         # Check policies
npx repopo check --fix   # Auto-fix violations
npx repopo list          # Show configured policies
```
