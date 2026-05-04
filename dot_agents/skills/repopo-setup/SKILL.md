---
name: repopo-setup
description: Configure repopo (repository policy enforcement) for any repository. Use when users want to set up repopo, add repository policies, enforce code standards, validate package.json conventions, check file headers, or standardize repository structure. Works for repos with or without existing Node.js dependencies.
---

# Repopo Configuration Skill

Repopo enforces repository-wide policies. It validates file structure, package.json fields, file headers, and naming conventions.

## Installation

### For repos WITH existing Node.js dependencies

```bash
pnpm add -D repopo
# or: npm install -D repopo / yarn add -D repopo
```

### For repos WITHOUT Node.js dependencies

Create minimal package.json, install repopo, then configure:

```bash
# Initialize package.json if missing
[ -f package.json ] || echo '{"private": true, "type": "module"}' > package.json

# Install repopo
npm install -D repopo
```

**Alternative**: Use npx without installing:
```bash
npx repopo check
```

## Configuration

Create `repopo.config.ts` at repo root:

```typescript
import { makePolicy, type RepopoConfig } from "repopo";
import {
  PackageJsonSorted,
  PackageJsonProperties,
  PackageScripts,
  // ... additional policies from references/policies.md
} from "repopo/policies";

const config: RepopoConfig = {
  // Global exclusions (apply to all policies)
  excludeFiles: ["vendor/", "node_modules/"],

  policies: [
    makePolicy(PolicyDefinition),
    makePolicy(PolicyDefinition, policyConfig),
    makePolicy(PolicyDefinition, policyConfig, { excludeFiles: ["..."] }),
  ],
};

export default config;
```

## Running

```bash
repopo check           # Check policies
repopo check --fix     # Auto-fix where possible
repopo check -v        # Verbose output
repopo list            # List configured policies
```

## Common Configurations

### Minimal (single package)
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
  PackageFolderName,
} from "repopo/policies";

const config: RepopoConfig = {
  excludeFiles: ["packages/vendored/"],
  policies: [
    makePolicy(PackageJsonProperties, {
      verbatim: {
        license: "MIT",
        author: "Your Name <email@example.com>",
        repository: { type: "git", url: "git+https://github.com/..." },
      },
    }),
    makePolicy(PackageJsonSorted),
    makePolicy(PackageScripts, {
      must: ["build", "test", "clean"],
    }),
    makePolicy(PackageFolderName, { stripScopes: ["@yourorg"] }),
  ],
};
export default config;
```

## Available Policies

See [references/policies.md](references/policies.md) for complete policy documentation including:
- Package.json policies (properties, scripts, sorting, license)
- File policies (headers, extensions, binary files)
- Repository policies (license file, gitignore patterns)

## Custom Policies

See [references/custom-policies.md](references/custom-policies.md) for creating custom policies.

## Workflow Integration

### package.json scripts
```json
{
  "scripts": {
    "check:policy": "repopo check",
    "fix:policy": "repopo check --fix"
  }
}
```

### Pre-commit hook (husky)
```bash
npx repopo check
```

### CI/CD (GitHub Actions)
```yaml
- name: Check policies
  run: npx repopo check
```
