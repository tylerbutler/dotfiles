---
name: changelog
description: Create changie changelog fragments for the current branch's changes. Use this skill whenever the user mentions changelogs, changelog entries, changelog fragments, changie fragments, "add a changelog", "add a change entry", or wants to document what changed in a branch or PR — even if they don't say "changie" explicitly. Also trigger when the user says things like "document these changes", "what changed on this branch", or "write up the changes". Requires a `.changie.yaml` in the repo.
---

# Changelog Fragment Creator

Create changie changelog fragments that document the changes on the current branch.

## Prerequisites

This skill only works in repositories that have changie configured. Verify by checking for `.changie.yaml` at the repo root. If it doesn't exist, tell the user and suggest the `changie-setup` skill instead.

## Step 1: Read the changie config

Read `.changie.yaml` to learn:
- **`changesDir`** and **`unreleasedDir`**: where fragments go (typically `.changes/unreleased/`)
- **`kinds`**: the available change categories and their labels
- **`body`**: whether body is block-style, min length, etc.

Also read a couple of existing fragments in the unreleased directory (if any) to match the exact format — field order, body style, time format. Consistency with existing fragments matters more than any template.

## Step 2: Understand what changed

If the user provided enough context about the change (e.g., "add a changelog entry for the new WriteThrough optimization"), use that directly. Skip the diff analysis.

Otherwise, analyze the branch:

1. **Find the base branch**: Run `git merge-base HEAD main` (or `master` if `main` doesn't exist) to find the divergence point.
2. **Get the commit log**: `git log <merge-base>..HEAD --oneline` to see all commits on the branch.
3. **Get the diff summary**: `git diff <merge-base>..HEAD --stat` for an overview of what files changed.
4. **Read commit messages**: The commit messages are your primary source. Conventional commit prefixes (`feat:`, `fix:`, `perf:`, etc.) map directly to changie kinds.
5. **Read the diff** for key commits if the commit messages aren't sufficient to write a clear description.

## Step 3: Identify logical changes

Group the commits into logical changes. Each logical change gets its own fragment. The mapping from conventional commits to changie kinds:

| Commit prefix | Changie kind |
|---------------|-------------|
| `feat:` | Added |
| `feat!:` | Breaking |
| `fix:` | Fixed |
| `perf:` | Performance |
| `refactor:` | Changed |
| `deps:` | Dependencies |
| `security:` | Security |
| `revert:` | Reverted |

Not every commit needs a fragment. Skip:
- `chore:` commits (CI triggers, formatting, removing temp files)
- `docs:` commits (unless the docs change is user-facing and notable)
- `test:` commits (unless they represent a meaningful behavior change)
- Merge commits and conflict resolution commits

Multiple related commits of the same kind can be combined into a single fragment. For example, three `fix:` commits that all fix resource leaks could become one "Fixed" fragment about resource leak fixes — or they could stay separate if they address distinct issues. Use judgment: would a user reading the changelog understand the changes better as one entry or several?

## Step 4: Check for existing fragments

Before creating fragments, list the existing files in the unreleased directory. If a fragment already covers one of the logical changes you identified, skip it — don't create duplicates. Tell the user which changes are already covered.

## Step 5: Write the fragments

For each logical change, create a YAML file in the unreleased directory.

**File naming**: `<Kind>-<YYYYMMDD>-<HHMMSS>.yaml`
- Use the current timestamp
- If multiple fragments share the same kind and second, increment the seconds to avoid collisions

**Fragment format**:
```yaml
kind: <Kind label exactly as it appears in .changie.yaml>
body: |-
    <Title line — concise summary of the change>
    <Blank line, then a paragraph explaining what changed and why. Focus on what users of the library need to know, not implementation details. If the change is simple enough that the title says it all, omit the description.>
time: <ISO 8601 with nanosecond precision and timezone offset>
```

**Writing good fragment bodies:**
- The **title line** (first line of body) should be a concise noun-phrase or sentence fragment, not a full sentence. Think of it as a changelog bullet point. Examples: "WriteThrough mode uses O(1) targeted DETS operations instead of full snapshot", "Fix resource leak when opening tables with invalid DETS data".
- The **description** (lines after the first) explains the before/after, the impact, or the motivation. Write for someone who uses the library but doesn't read the source. Skip if the title is self-explanatory.
- For **Breaking** changes, include before/after code examples showing what the user needs to change.
- Don't start the title with the kind name (e.g., don't write "Fixed: ..." in a Fixed fragment).

## Step 6: Present what you created

After creating the fragments, show the user:
1. A summary of which fragments were created (kind + title)
2. Which changes were skipped (already covered or not changelog-worthy)
3. Any changes you were unsure about — ask the user if they want fragments for those

## Edge cases

- **No `.changie.yaml`**: Stop and tell the user. Suggest `changie-setup`.
- **No commits on branch vs main**: Tell the user there are no changes to document.
- **Detached HEAD or no clear base branch**: Ask the user which branch to compare against.
- **User disagrees with a kind**: Change it. The user knows their project's conventions better than commit prefixes suggest.
