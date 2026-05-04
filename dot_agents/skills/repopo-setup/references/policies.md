# Repopo Built-in Policies

Import all policies from `"repopo/policies"`.

## Package.json Policies

### PackageJsonSorted
Enforce sorted package.json keys. **Auto-fixable**.
```typescript
makePolicy(PackageJsonSorted)
```

### PackageJsonProperties
Enforce specific fields have exact values. **Auto-fixable**.
```typescript
makePolicy(PackageJsonProperties, {
  verbatim: {
    license: "MIT",
    author: "Name <email@example.com>",
    bugs: "https://github.com/org/repo/issues",
    repository: { type: "git", url: "git+https://github.com/org/repo.git" },
  },
})
```

### PackageJsonRepoDirectoryProperty
Validate `repository.directory` field matches folder location. **Partial auto-fix**.
```typescript
makePolicy(PackageJsonRepoDirectoryProperty)
```

### PackageScripts
Comprehensive script validation. **Partial auto-fix** (for `must` and `exact` with defaults).
```typescript
makePolicy(PackageScripts, {
  // Scripts that must exist (auto-fixable with default values)
  must: ["build", "test", "clean"],
  // Or with default values for auto-fix:
  must: [{ build: "tsc" }, { test: "vitest" }],

  // Scripts that must exist AND match exactly
  exact: { clean: "rimraf dist", format: "prettier --write ." },

  // Only one script from each group can exist
  mutuallyExclusive: [["test:unit", "test:vitest"]],

  // If script X exists, scripts Y/Z must also exist
  conditionalRequired: [{
    ifPresent: "test",
    requires: [{ "test:coverage": "vitest run --coverage" }],
  }],

  // Script body must contain substrings
  scriptMustContain: { lint: ["eslint", "--fix"] },
})
```

### PackageEsmType
Ensure `type` field is set correctly for ESM/CommonJS. **Auto-fixable**.
```typescript
makePolicy(PackageEsmType, {
  requiredType: "module",  // or "commonjs"
  detectFromExports: true, // auto-detect from exports field
  excludePackages: ["legacy-pkg"],
  onDetectionFailure: "warn", // or "error"
})
```

### PackageFolderName
Ensure folder name matches package name.
```typescript
makePolicy(PackageFolderName, {
  stripScopes: ["@myorg", "@internal"],
})
```

### PackageAllowedScopes
Enforce allowed npm scopes.
```typescript
makePolicy(PackageAllowedScopes, {
  allowedScopes: ["@myorg"],
  unscopedPackages: ["utils", "config"],
})
```

### PackagePrivateField
Enforce `"private": true/false` on specific packages. **Auto-fixable**.
```typescript
makePolicy(PackagePrivateField, {
  mustBePrivate: ["packages/internal-*"],
  unmatchedPackages: "ignore", // or "fail"
})
```

### PackageLicense
Ensure license field exists.
```typescript
makePolicy(PackageLicense)
```

### PackageReadme
Ensure README exists (optionally with title matching).
```typescript
makePolicy(PackageReadme)
```

### PackageTestScripts
Ensure test scripts follow patterns.
```typescript
makePolicy(PackageTestScripts)
```

## File Header Policies

### JsTsFileHeaders
Enforce headers in JS/TS files.
```typescript
makePolicy(JsTsFileHeaders, {
  header: "// Copyright 2025 Your Company\n// SPDX-License-Identifier: MIT\n",
})
```

### HtmlFileHeaders
Enforce headers in HTML files.
```typescript
makePolicy(HtmlFileHeaders, {
  header: "<!-- Copyright 2025 Your Company -->",
})
```

## Code Quality Policies

### NoJsFileExtensions
Prevent ambiguous `.js` files (require `.mjs` or `.cjs`).
```typescript
makePolicy(NoJsFileExtensions, undefined, {
  excludeFiles: ["**/bin/*.js", ".lighthouserc.js"],
})
```

## Repository Policies

### LicenseFileExists
Ensure LICENSE file exists.
```typescript
makePolicy(LicenseFileExists)
```

### NoLargeBinaryFiles
Prevent large binary files.
```typescript
makePolicy(NoLargeBinaryFiles)
```

### NoPrivateWorkspaceDependencies
Prevent private packages as dependencies.
```typescript
makePolicy(NoPrivateWorkspaceDependencies)
```

### RequiredGitignorePatterns
Ensure gitignore contains required patterns. **Auto-fixable**.
```typescript
makePolicy(RequiredGitignorePatterns, {
  patterns: [
    { pattern: "node_modules/", comment: "Node dependencies" },
    { pattern: ".env", comment: "Environment secrets" },
    { pattern: "dist/", comment: "Build output" },
  ],
})
```

## External Policies

### SortTsconfigsPolicy (from sort-tsconfig)
Ensure sorted tsconfig.json files.
```typescript
import { SortTsconfigsPolicy } from "sort-tsconfig";
makePolicy(SortTsconfigsPolicy)
```

## Policy Configuration

Each `makePolicy()` call accepts up to 3 arguments:

```typescript
makePolicy(
  PolicyDefinition,      // Required: The policy to use
  policyConfig?,         // Optional: Policy-specific configuration
  settings?: {           // Optional: Execution settings
    excludeFiles?: (string | RegExp)[]  // Files to skip for this policy
  }
)
```

## Global Exclusions

Exclude files from ALL policies:

```typescript
const config: RepopoConfig = {
  excludeFiles: [
    "vendor/",
    "node_modules/",
    /\.generated\./,
  ],
  policies: [...]
};
```
