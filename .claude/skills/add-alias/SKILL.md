---
name: add-alias
description: Add a new shell alias to dot_aliae.yaml with proper cross-platform templating
argument-hint: <alias-name> <command>
---

# Add Alias

Add a new alias to `dot_aliae.yaml` following existing patterns.

## Steps

1. Read `dot_aliae.yaml` to understand current structure and grouping
2. Find the appropriate section for the new alias (or create a new section)
3. Add the alias using aliae YAML format
4. Validate YAML syntax
5. Run `chezmoi diff` to preview the change

## Alias Format

Simple alias:
```yaml
- alias: name
  value: command
```

Cross-platform paths (use `{{ .Home }}` instead of `~` or `$HOME`):
```yaml
- alias: myapp
  value: '{{ .Home }}/bin/myapp'
```

OS-conditional:
```yaml
- alias: open
  value: '{{ if eq .OS "darwin" }}open{{ else }}xdg-open{{ end }}'
```

## Arguments

- `$1`: Alias name
- `$2`: Command value (or description of what you want)

## Rules

- Always add to `dot_aliae.yaml`, never to `.zshrc` or `.bashrc`
- Group with related aliases (git aliases together, navigation together, etc.)
- Use aliae template syntax for paths and OS-specific commands
- Keep alias names short and memorable
- Check for conflicts with existing aliases before adding
