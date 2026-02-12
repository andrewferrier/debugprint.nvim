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
- Target: NeoVim (maintains compatibility with stable, stable - 1, and nightly)
- Dependencies: plenary.nvim (testing), mini.nvim (optional highlighting), nvim-treesitter (optional variable detection)

## Repository Structure

```text
lua/debugprint/         # Main plugin source code
tests/                  # Test suite
doc/                    # Generated Vim help documentation
.github/workflows/      # CI/CD workflows
```

## Lua Best Practices

### Code Formatting

**CRITICAL:** All Lua code MUST be formatted using `stylua` with the project's configuration (see `.stylua.toml`).

**Before committing any Lua code:**

```bash
stylua --check lua/ tests/  # Check formatting
stylua lua/ tests/          # Auto-format code
```

The CI pipeline will fail if code is not properly formatted. There are no exceptions.

### Code Quality Tools

**IMPORTANT:** Ensure these are run on any pull requests submitted for review.

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

### CI Test Matrix

Tests run against multiple NeoVim versions and OS:

- NeoVim: all versions supported by the plugin
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

## Documentation

### Vim Help Documentation

- Written in `doc/debugprint.txt`
- Auto-generated via `panvimdoc` GitHub Action
- Uses special comment markers for generation
- Generated on every push to main branch

### Other documentation

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
