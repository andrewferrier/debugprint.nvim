# Copilot Instructions for debugprint.nvim

Welcome to debugprint.nvim! This document provides essential information for AI coding agents to work efficiently with this repository.

## Project Overview

debugprint.nvim is a NeoVim plugin that simplifies debugging by automatically inserting language-specific debug print statements. It supports 40+ file types out-of-the-box and provides features like:

- Automatic insertion of debug statements with file names, line numbers, and counters
- Variable value printing using Treesitter
- Commands to delete, comment, or search debug statements
- Highlighting of inserted debug lines
- Support for custom filetypes

**Technology Stack:**

- Language: Lua (NeoVim plugin)
- Target: NeoVim 0.10+
- Dependencies: plenary.nvim (testing), mini.nvim (optional highlighting), nvim-treesitter (optional variable detection)

## Repository Structure

```text
lua/debugprint/           # Main plugin source code
├── init.lua             # Main entry point, debugprint() function
├── setup.lua            # Plugin setup, keymaps, and commands
├── filetypes.lua        # Built-in filetype configurations
├── filetype_config.lua  # Filetype configuration logic
├── options.lua          # Default plugin options
├── types.lua            # Type definitions
├── counter.lua          # Counter persistence logic
├── highlight.lua        # Line highlighting integration
├── printtag_operations.lua  # Delete/comment/search operations
├── health.lua           # Health check command
└── utils/               # Utility modules

tests/                   # Test suite
├── run.lua             # Test runner
├── debugprint.lua      # Test setup
├── support.lua         # Test utilities
└── specs/              # Test specifications

doc/                    # Generated Vim help documentation
.github/workflows/      # CI/CD workflows
```

## Lua Best Practices

### Code Formatting

**CRITICAL:** All Lua code MUST be formatted using `stylua` with the project's configuration:

```toml
# .stylua.toml
indent_type = "Spaces"
indent_width = 4
column_width = 80
```

**Before committing any Lua code:**

```bash
stylua --check lua/ tests/  # Check formatting
stylua lua/ tests/          # Auto-format code
```

The CI pipeline will fail if code is not properly formatted. There are no exceptions.

### Code Quality Tools

The project uses multiple linters and type checkers:

1. **luacheck** - Static analyzer for Lua
   - Configuration: `.luacheckrc` (allows `vim` global)
   - Run: `luacheck lua/`

2. **selene** - Modern Lua linter
   - Configuration: `selene.toml` and `vim.toml`
   - Run: `selene lua/ tests/`

3. **nvim-typecheck** - Lua type checking for NeoVim
   - Checks type annotations in `lua/` directory
   - Uses `.luarc.jsonc` for configuration

### Lua Coding Standards

1. **Use type annotations** - Add `---@type`, `---@param`, `---@return` annotations for better type safety and documentation

   ```lua
   ---@param opts debugprint.FunctionOptionsInternal
   ---@param fileconfig debugprint.FileTypeConfig
   ---@return string
   local get_debugline_textcontent = function(opts, fileconfig)
       -- ...
   end
   ```

2. **Module pattern** - Use the standard Lua module pattern:

   ```lua
   local M = {}
   
   M.some_function = function()
       -- ...
   end
   
   return M
   ```

3. **Local variables** - Prefer `local` variables and functions to minimize global scope pollution

4. **Vim globals** - The `vim` global is allowed and expected (configured in `.luacheckrc`)

5. **String formatting** - Use `string.format()` for complex strings or Lua string concatenation for simple cases

6. **Error handling** - Use `pcall()` for operations that might fail and provide meaningful error messages via `vim.notify()`

## Commit Message Convention

**MANDATORY:** All commits MUST follow the [Conventional Commits](https://www.conventionalcommits.org/) specification. This is strictly enforced and non-negotiable.

### Required Format

```text
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Allowed Types

- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes only
- `chore:` - Maintenance tasks, dependencies, tooling
- `test:` - Test additions or modifications
- `refactor:` - Code refactoring without feature/fix changes
- `perf:` - Performance improvements
- `ci:` - CI/CD configuration changes
- `style:` - Code style changes (formatting, whitespace)
- `revert:` - Revert previous commits

### Breaking Changes

Use `!` after type/scope or add `BREAKING CHANGE:` in footer:

```text
feat!: drop legacy commands - closes #200
```

### Examples from Project History

```bash
feat: Add actionlint test
fix: use more appropriate snacks picker
fix: More echasnovski → nvim-mini
chore(main): release 7.1.0
chore: Auto generate Vim docs
test: 'main' branch has become default
docs: update plugin references in README.md
```

### Release Process

- The project uses `release-please` for automated releases
- Conventional commits are parsed to determine version bumps (semver)
- `feat:` → minor version bump
- `fix:` → patch version bump
- `feat!:` or `BREAKING CHANGE:` → major version bump
- Other types don't trigger releases

## Testing

### Running Tests

```bash
make test
# or
nvim --headless --clean -u tests/run.lua
```

### Test Structure

- Tests use a custom test framework (not busted)
- Test files are in `tests/specs/` with descriptive names
- Tests are loaded automatically by `tests/run.lua`
- `tests/support.lua` provides test utilities

### Writing Tests

Example test structure:

```lua
local debugprint = require("debugprint")
local support = require("tests.support")

describe("feature name", function()
    before_each(function()
        debugprint.setup()
    end)

    after_each(support.teardown)

    it("should do something", function()
        local filename = support.init_file({
            "line1",
            "line2",
        }, "lua", 1, 0)
        
        support.feedkeys("g?p")
        
        support.check_lines({
            "line1",
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (after line1)')",
            "line2",
        })
        
        assert.equals(support.get_notify_message(), nil)
    end)
end)
```

### Test Naming Convention

Test files in `specs/` use numeric prefixes for ordering:

- `00-setup.lua` - Setup tests
- `05-basic.lua` - Basic functionality
- `10-basic_with_custom_keys.lua` - Basic with customization
- `counter.lua`, `display-options.lua`, etc. - Feature-specific tests

### CI Test Matrix

Tests run against multiple NeoVim versions and OS:

- NeoVim: v0.10.4, stable, nightly
- OS: Ubuntu, macOS

## CI/CD Pipeline

### Workflow Jobs

The `.github/workflows/tests.yaml` runs these checks:

1. **actionlint** - Validates GitHub Actions workflow files
2. **stylua** - Enforces code formatting
3. **luacheck** - Lua static analysis
4. **selene** - Modern Lua linting
5. **typecheck** - Type checking for Lua code
6. **unit_test** - Runs test suite across matrix of NeoVim versions and OS

### Pre-commit Hooks

The project uses pre-commit hooks (`.pre-commit-config.yaml`):

- Check for large files
- Gitleaks (secret detection)
- StyLua formatting
- Markdownlint
- Luacheck
- llscheck (Lua language server check)

### Making Changes

**Always run these before committing:**

```bash
# Format code
stylua lua/ tests/

# Run linters
luacheck lua/
selene lua/ tests/

# Run tests (requires NeoVim installed)
make test
```

**All CI checks must pass before merging.** The CI enforces:

- Code formatting (no automatic fixes)
- Linter compliance
- Type checking compliance
- All tests passing

## Common Patterns

### Adding a New Filetype

Add to `lua/debugprint/filetypes.lua`:

```lua
M.filetypes = {
    -- ...
    newlang = {
        left = 'print("',
        right = '")',
        mid_var = '", ',
        right_var = ")",
    },
}
```

For languages with Treesitter support, add `find_treesitter_variable` function.

### Custom Display Options

Filetype configs can override global display options:

```lua
newlang = {
    -- ... print format ...
    display_counter = false,     -- Disable counter for this filetype
    display_location = true,     -- Show file:line
    display_snippet = false,     -- Don't show code snippet
}
```

### Dynamic Filetype Configs

Use a function for dynamic configuration:

```lua
newlang = function(opts)
    return {
        left = calculate_left(),
        right = calculate_right(),
        -- ...
    }
end
```

## Documentation

### Vim Help Documentation

- Written in `doc/debugprint.txt`
- Auto-generated via `panvimdoc` GitHub Action
- Uses special comment markers for generation
- Generated on every push to main branch

### README and SHOWCASE

- `README.md` - User-facing documentation, installation, features
- `SHOWCASE.md` - Advanced usage examples and customization patterns
- `CHANGELOG.md` - Generated by release-please (don't edit manually)

**Markdown Linting:**

- Uses markdownlint (`.markdownlintrc`)
- `CHANGELOG.md` is excluded from linting

## Troubleshooting Common Issues

### Issue: stylua check fails in CI

**Error:** Code is not formatted according to stylua configuration

**Solution:**

```bash
cd /path/to/debugprint.nvim
stylua lua/ tests/
git add -u
git commit -m "style: format code with stylua"
```

### Issue: luacheck warnings

**Error:** Undefined or unused variables

**Solution:**

- Fix undefined variables by adding proper requires or local declarations
- Remove unused variables or prefix with `_` if intentionally unused
- Add `---@diagnostic disable-next-line: <diagnostic>` if it's a false positive

### Issue: selene errors

**Error:** Selene finds code quality issues

**Solution:**

- Review selene documentation for the specific diagnostic
- Fix the underlying issue (prefer this)
- Use `--[[ allow(<diagnostic>) ]]` sparingly for false positives

### Issue: Tests fail with treesitter errors

**Error:** Treesitter parser not found

**Explanation:** Tests automatically install required parsers in CI but may need manual setup locally.

**Solution:**

```lua
-- In NeoVim command line
:TSInstall lua javascript python  -- Install needed parsers
```

### Issue: Type checking fails

**Error:** Type annotations incorrect or missing

**Solution:**

- Add missing `---@type`, `---@param`, `---@return` annotations
- Check `lua/debugprint/types.lua` for type definitions
- Ensure type names match defined types exactly

### Issue: Pre-commit hooks fail

**Error:** Git commit is rejected by pre-commit hooks

**Solution:**

```bash
# Run all pre-commit hooks manually
pre-commit run --all-files

# Or fix specific issues
stylua lua/ tests/           # Fix formatting
luacheck lua/                # Fix lint issues
markdownlint README.md       # Fix markdown issues
```

## Key Files Reference

- `.stylua.toml` - Code formatting configuration (indent: 4 spaces, width: 80)
- `.luacheckrc` - Luacheck configuration (allows vim global)
- `selene.toml` - Selene linter configuration
- `.luarc.jsonc` - Lua language server and type checking config
- `.pre-commit-config.yaml` - Pre-commit hooks configuration
- `Makefile` - Contains `make test` command
- `.editorconfig` - Editor configuration for consistent formatting
- `.github/workflows/tests.yaml` - CI/CD pipeline definition
- `.github/workflows/release-please.yml` - Automated release workflow
- `.github/workflows/panvimdoc.yaml` - Auto-generates Vim help docs

## Notes for AI Agents

1. **Always format Lua code with stylua** - This is the #1 cause of CI failures
2. **Always use conventional commits** - Release automation depends on this
3. **Type annotations are important** - Help with maintenance and type checking
4. **Test your changes** - Run `make test` if NeoVim is available
5. **Check existing patterns** - Look at `lua/debugprint/filetypes.lua` for filetype examples
6. **Respect the module structure** - Keep utilities in `utils/`, types in `types.lua`
7. **Line width is 80 characters** - Enforced by stylua
8. **4 spaces for indentation** - Enforced by stylua
9. **Don't edit CHANGELOG.md** - It's auto-generated by release-please
10. **Don't edit doc/debugprint.txt** - It's auto-generated by panvimdoc

## Getting Help

- Check `README.md` for user documentation
- Check `SHOWCASE.md` for advanced customization examples
- Look at existing test files in `tests/specs/` for patterns
- Review similar filetypes in `lua/debugprint/filetypes.lua`
- Check GitHub issues for similar problems or feature requests

## Quick Start Checklist

- [ ] Read the README.md to understand what the plugin does
- [ ] Review lua/debugprint/filetypes.lua to understand filetype configurations
- [ ] Check .stylua.toml for formatting rules
- [ ] Understand that conventional commits are mandatory
- [ ] Know that stylua formatting is mandatory
- [ ] Run `stylua lua/ tests/` before committing
- [ ] Run `luacheck lua/` before committing
- [ ] Run `make test` if adding/changing functionality (requires NeoVim)
- [ ] Write tests for new features in tests/specs/
- [ ] Use proper type annotations for all functions
- [ ] Follow the existing code patterns and structure
