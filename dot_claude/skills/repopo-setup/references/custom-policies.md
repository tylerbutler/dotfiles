# Creating Custom Repopo Policies

## Basic Custom Policy

```typescript
import { makePolicyDefinition, type PolicyHandler } from "repopo";
import * as fs from "node:fs/promises";
import * as path from "node:path";

const handler: PolicyHandler = async ({ file, root, resolve }) => {
  const absolutePath = path.join(root, file);
  const content = await fs.readFile(absolutePath, "utf-8");

  if (content.includes("TODO")) {
    if (resolve) {
      // Auto-fix logic (optional)
      const fixed = content.replace(/\/\/.*TODO.*\n/g, "");
      await fs.writeFile(absolutePath, fixed);
      return {
        name: "NoTodoComments",
        file,
        resolved: true,
        errorMessages: ["Removed TODO comments"],
      };
    }
    return {
      name: "NoTodoComments",
      file,
      autoFixable: true,
      errorMessages: ["File contains TODO comments"],
      manualFix: "Remove or address TODO comments",
    };
  }

  return true; // Passes
};

export const NoTodoComments = makePolicyDefinition({
  name: "NoTodoComments",
  description: "Prevents TODO comments in source files",
  match: /\.(ts|js|mjs|cjs)$/,
  handler,
});
```

## Package.json Policy Generator

For policies that validate package.json:

```typescript
import { generatePackagePolicy } from "repopo";

export const RequireVersion = generatePackagePolicy(
  "RequireVersion",
  async ({ content, resolve, config }) => {
    if (content.version === "0.0.0") {
      return {
        name: "RequireVersion",
        file: "package.json",
        errorMessages: ["Version must not be 0.0.0"],
        autoFixable: false,
      };
    }
    return true;
  }
);
```

## Policy with Configuration

```typescript
import { makePolicyDefinition, type PolicyHandler } from "repopo";

interface MaxFileSizeConfig {
  maxBytes: number;
}

const handler: PolicyHandler<MaxFileSizeConfig> = async ({
  file,
  root,
  config,
}) => {
  const absolutePath = path.join(root, file);
  const stats = await fs.stat(absolutePath);

  if (stats.size > config.maxBytes) {
    return {
      name: "MaxFileSize",
      file,
      autoFixable: false,
      errorMessages: [
        `File exceeds ${config.maxBytes} bytes (${stats.size} bytes)`,
      ],
    };
  }
  return true;
};

export const MaxFileSize = makePolicyDefinition<MaxFileSizeConfig>({
  name: "MaxFileSize",
  description: "Enforce maximum file size",
  match: /.*/,
  handler,
  defaultConfig: { maxBytes: 1_000_000 },
});
```

## Handler Context

The handler receives:

```typescript
interface PolicyHandlerContext<C> {
  file: string;      // Relative path from repo root
  root: string;      // Absolute path to repo root
  resolve: boolean;  // True if --fix flag was passed
  config: C;         // Policy configuration
}
```

## Return Types

```typescript
// Pass
return true;

// Fail (not auto-fixable)
return {
  name: "PolicyName",
  file: string,
  autoFixable: false,
  errorMessages: string[],
  manualFix?: string,
};

// Fail (auto-fixable)
return {
  name: "PolicyName",
  file: string,
  autoFixable: true,
  errorMessages: string[],
};

// Fixed (when resolve=true)
return {
  name: "PolicyName",
  file: string,
  resolved: true,
  errorMessages: string[],
};
```

## Using Custom Policies

```typescript
// repopo.config.ts
import { makePolicy, type RepopoConfig } from "repopo";
import { NoTodoComments, MaxFileSize } from "./policies/custom.js";

const config: RepopoConfig = {
  policies: [
    makePolicy(NoTodoComments),
    makePolicy(MaxFileSize, { maxBytes: 500_000 }),
  ],
};

export default config;
```
