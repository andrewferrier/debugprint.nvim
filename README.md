# debugprint.nvim

![Test status](https://github.com/andrewferrier/debugprint.nvim/actions/workflows/tests.yaml/badge.svg)

## Overview

`debugprint` is a NeoVim plugin that simplifies debugging for those who prefer a
low-tech approach. Instead of using a sophisticated debugger like
[nvim-dap](https://github.com/mfussenegger/nvim-dap), some people prefer using
the 'print' statement to trace the output during execution. With `debugprint`,
you can easily insert appropriate 'print' statements relevant to the language
you're editing. These statements include reference information for quick output
navigation and the ability to output variable values.

`debugprint` supports the following filetypes/programming languages out-of-the-box:

*   `bash`
*   `c`
*   `cmake`
*   `cpp` (C++)
*   `cs` (C#)
*   `dart`
*   `dockerfile`
*   `dosbatch` (DOS/Windows Batch)
*   `fish`
*   `go`
*   `java`
*   `javascript`
*   `lua`
*   `make`
*   `perl`
*   `php`
*   `ps1` (Powershell)
*   `python`
*   `r`
*   `ruby`
*   `rust`
*   `sh` (sh/Bash)
*   `swift`
*   `typescript`
*   `vim`
*   `zsh`

It can also be extended to support more.

## Features

`debugprint` is inspired by
[vim-debugstring](https://github.com/bergercookie/vim-debugstring), but is
updated and refreshed for the NeoVim generation. It has these features:

*   It includes reference information in each 'print line' such as file names,
    line numbers, a monotonic counter, and snippets of other lines to make it easier
    to cross-reference them in output.

*   It can output the value of variables (or in some cases, expressions).

*   It [dot-repeats](https://jovicailic.org/2018/03/vim-the-dot-command/).

*   It can pick up a variable name from under the cursor if it's a supported language
    with Treesitter, or will prompt for the variable name with a sensible default if not.

*   It provides keymappings for visual mode, so you can select a variable
    visually and print it out.

*   It provides keymappings for operator-pending mode, so you can select a
    variable using a motion.

*   It provides a command to delete all debugging lines added to the current buffer.

*   It can optionally move to the inserted line (or not).

*   You can add support for languages it doesn't support out of the box.

## Demo

<div align="center">
  <video src="https://github.com/andrewferrier/debugprint.nvim/assets/107015/e1a8b93b-0c8f-4f02-86e8-cbe1d476940c" type="video/mp4"></video>
</div>

## Installation

**Requires NeoVim 0.8+.**

Optional dependency for NeoVim 0.8 only:
[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter). If this
is not installed, `debugprint` will not find variable names under the cursor and
will always prompt for a variable name. For NeoVim 0.9+, this dependency is
never needed.

Example for [`lazy.nvim`](https://github.com/folke/lazy.nvim):

```lua
return {
    url = "andrewferrier/debugprint.nvim",
    opts = { ... },
    -- Dependency only needed for NeoVim 0.8
    dependencies = {
        "nvim-treesitter/nvim-treesitter"
    },
    -- Remove the following line to use development versions,
    -- not just the formal releases
    version = "*"
}
```

Example for [`packer.nvim`](https://github.com/wbthomason/packer.nvim):

```lua
packer.startup(function(use)

    ...

    use({
        "andrewferrier/debugprint.nvim",
        config = function()
            opts = { ... }
            require("debugprint").setup(opts)
        end,
    })

    ...

end)
```

The sections below detail the allowed options that can appear in the `opts`
object.

Please subscribe to [this GitHub
issue](https://github.com/andrewferrier/debugprint.nvim/issues/25) to be
notified of any breaking changes to `debugprint`.

## Keymappings and Commands

By default, the plugin will create some keymappings and commands for use 'out of
the box'. There are also some function invocations which are not mapped to any
keymappings or commands by default, but could be. This is all shown in the
following table.

| Mode       | Default Keymap / Cmd | Purpose                                                                                             | Equivalent Lua Function                                                                       |
| ---------- | -------------------- | --------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| Normal     | `g?p`                | Insert plain debug line below current line                                                          | `require('debugprint').debugprint()`                                                          |
| Normal     | `g?P`                | Insert plain debug line above current line                                                          | `require('debugprint').debugprint({above = true})`                                            |
| Normal     | `g?v`                | Insert variable debug line below current line. If cursor is on a variable, use it, otherwise prompt | `require('debugprint').debugprint({variable = true})`                                         |
| Normal     | `g?V`                | Insert variable debug line above current line. If cursor is on a variable, use it, otherwise prompt | `require('debugprint').debugprint({above = true, variable = true})`                           |
| Normal     | None                 | Prompt for variable name, insert variable debugging line below the current line                     | `require('debugprint').debugprint({ignore_treesitter = true, variable = true})`               |
| Normal     | None                 | Prompt for variable name, insert variable debugging line above the current line                     | `require('debugprint').debugprint({ignore_treesitter = true, above = true, variable = true})` |
| Visual     | `g?v`                | Insert visually-selected variable debugging line below the current line                             | `require('debugprint').debugprint({variable = true})`                                         |
| Visual     | `g?v`                | Insert visually-selected variable debugging line below the current line                             | `require('debugprint').debugprint({variable = true})`                                         |
| Op-pending | `g?o`                | Locate variable using motion, and insert a variable debugging line below the current line           | `require('debugprint').debugprint({motion = true})`                                           |
| Op-pending | `g?O`                | Locate variable using motion, and insert a variable debugging line above the current line           | `require('debugprint').debugprint({motion = true, above = true})`                             |
| Command    | `:DeleteDebugPrints` | Delete all debug lines added to this buffer                                                         | `require('debugprint').deleteprints()`                                                        |

### Custom Keymappings and Commands

The keymappings are chosen specifically because by default they are
used to convert sections to ROT-13, which most folks don't use. You can disable
the defaults above from being created by setting `create_keymaps` and/or
`create_commands`, and map them yourself to something else if you prefer:

```lua
opts = {
    create_keymaps = false,
    create_commands = false
    ...
}

require("debugprint").setup(opts)

vim.keymap.set("n", "<Leader>d", function()
    -- Note: setting `expr=true` and returning the value are essential
    return require('debugprint').debugprint()
end, {
    expr = true,
})
vim.keymap.set("n", "<Leader>D", function()
    -- Note: setting `expr=true` and returning the value are essential
    return require('debugprint').debugprint({ above = true })
end, {
    expr = true,
})
vim.keymap.set("n", "<Leader>dq", function()
    -- Note: setting `expr=true` and returning the value are essential
    return require('debugprint').debugprint({ variable = true })
end, {
    expr = true,
})
vim.keymap.set("n", "<Leader>Dq", function()
    -- Note: setting `expr=true` and returning the value are essential
    return require('debugprint').debugprint({ above = true, variable = true })
end, {
    expr = true,
})
vim.keymap.set("n", "<Leader>do", function()
    -- Note: setting `expr=true` and returning the value are essential
    -- It's also important to use motion = true for operator-pending motions
    return require('debugprint').debugprint({ motion = true })
end, {
    expr = true,
})

vim.api.nvim_create_user_command("DeleteDebugs", function(opts)
    -- Note: you must set `range=true` and pass through opts for ranges to work
    M.deleteprints(opts)
end, {
    range = true})
end)
...
```

or, to have a keymapping instead for deleting debug lines (this will only affect
the entire buffer, visual and operator-pending modes will not work):

```lua
vim.keymap.set("n", "g?d", function()
    M.deleteprints()
end)
```

## Other Options

`debugprint` supports the following options in its global `opts` object:

| Option              | Default      | Purpose                                                                                                                                      |
| ------------------- | ------------ | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `create_keymaps`    | `true`       | Creates default keymappings - see above                                                                                                      |
| `move_to_debugline` | `false`      | When adding a debug line, moves the cursor to that line                                                                                      |
| `display_counter`   | `true`       | Whether to display/include the monotonically increasing counter in each debug message                                                        |
| `display_snippet`   | `true`       | Whether to include a snippet of the line above/below in plain debug lines                                                                    |
| `filetypes`         | See below    | Custom filetypes - see below                                                                                                                 |
| `ignore_treesitter` | `false`      | Never use treesitter to find a variable under the cursor, always prompt for it - overrides the same setting on `debugprint()` if set to true |
| `print_tag`         | `DEBUGPRINT` | The string inserted into each print statement, which can be used to uniquely identify statements inserted by `debugprint`.                   |

## Add Custom Filetypes

*Note: If you work out a configuration for a filetype not supported
out-of-the-box, it would be really appreciated if you can open an
[issue](https://github.com/andrewferrier/debugprint.nvim/issues/new) to have it
supported out-of-the-box in `debugprint` so others can benefit from it.
Similarly, if you spot any issues with, or improvements to, the language
configurations out-of-the-box, please open an issue also.*

If `debugprint` doesn't support your filetype, you can add it as a custom
filetype in one of two ways:

*   In the `opts.filetypes` object in `setup()`.

*   Using the `require('debugprint').add_custom_filetypes()` method (designed for
    use from `ftplugin/` directories, etc.

In either case, the format is the same. For example, if adding via `setup()`:

```lua
local my_fileformat = {
    left = 'print "',
    right = '"',
    mid_var = "${",
    right_var = '}"',
}

require('debugprint').setup({ filetypes = { my_fileformat, another_of_my_fileformats, ... }})
```

or `add_custom_filetypes()`:

```lua
require('debugprint').add_custom_filetypes({ my_fileformat, ... })
```

Your new file format will be *merged* in with those that already exist. If you
pass in one that already exists, your configuration will override the built-in
configuration.

The keys in the configuration are used like this:

| Type of debug line  | Default keys            | How debug line is constructed                                                                                               |
| ------------------- | ----------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| Plain debug line    | `g?p`/`g?P`             | `my_fileformat.left .. "auto-gen DEBUG string" .. my_fileformat.right`                                                      |
| Variable debug line | `g?v`/`g?V`/`g?o`/`g?O` | `my_fileformat.left .. "auto-gen DEBUG string, variable=" .. my_file_format.mid_var .. variable .. my_fileformat.right_var` |

If it helps to understand these, you can look at the built-in configurations in
[filetypes.lua](lua/debugprint/filetypes.lua).

## Feature Comparison with Other Plugins

(This table is quite wide, you may need to scroll horizontally)

| Feature                                                             | `debugprint.nvim` | [vim-debugstring](https://github.com/bergercookie/vim-debugstring) | [printer.nvim](https://github.com/rareitems/printer.nvim) | [refactoring.nvim](https://github.com/ThePrimeagen/refactoring.nvim) | [vim-printer](https://github.com/meain/vim-printer) | [vim-printf](https://github.com/mptre/vim-printf) | [logsitter](https://github.com/gaelph/logsitter.nvim) |
| ------------------------------------------------------------------- | ----------------- | ------------------------------------------------------------------ | --------------------------------------------------------- | -------------------------------------------------------------------- | --------------------------------------------------- | ------------------------------------------------- | ----------------------------------------------------- |
| Print plain debug lines                                             | :+1:              | :+1:                                                               | :x:                                                       | :+1:                                                                 | :x:                                                 | :x:                                               | :x:                                                   |
| Print variables using current word/heuristic                        | :+1:              | :+1:                                                               | :x:                                                       | :x:                                                                  | :+1:                                                | :+1:                                              | :x:                                                   |
| Print variables using treesitter                                    | :+1:              | :x:                                                                | :x:                                                       | :+1:                                                                 | :x:                                                 | :x:                                               | :x:                                                   |
| Print variables/expressions using prompts                           | :+1:              | :+1:                                                               | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                               | :x:                                                   |
| Print variables using motions                                       | :+1:              | :x:                                                                | :+1:                                                      | :x:                                                                  | :x:                                                 | :x:                                               | :x:                                                   |
| Print variables using visual mode                                   | :+1:              | :x:                                                                | :+1:                                                      | :+1:                                                                 | :+1:                                                | :x:                                               | :x:                                                   |
| Print debug lines above/below current line                          | :+1:              | :x:                                                                | (only via global config)                                  | :x:                                                                  | :+1:                                                | :x:                                               | :x:                                                   |
| Supports [dot-repeat](https://www.vikasraj.dev/blog/vim-dot-repeat) | :+1:              | :+1:                                                               | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                               | :x:                                                   |
| Can control whether to move to inserted lines                       | :+1:              | :x:                                                                | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                               | :x:                                                   |
| Command to clean up all debug lines                                 | :+1:              | :x:                                                                | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                               | :x:                                                   |
| Can put debugprint text into default register                       | :x:               | :x:                                                                | :+1:                                                      | :x:                                                                  | :x:                                                 | :x:                                               | :x:                                                   |
| *Built-in support for:*                                             | -                 | -                                                                  | -                                                         | -                                                                    | -                                                   | -                                                 | -                                                     |
| arduino                                                             | :x:               | :+1:                                                               | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                               | :x:                                                   |
| bash/sh                                                             | :+1:              | :+1:                                                               | :+1:                                                      | :x:                                                                  | :+1:                                                | :x:                                               | :x:                                                   |
| C                                                                   | :+1:              | :+1:                                                               | :x:                                                       | :x:                                                                  | :x:                                                 | :+1:                                              | :x:                                                   |
| C#                                                                  | :+1:              | :+1:                                                               | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                               | :x:                                                   |
| C++                                                                 | :+1:              | :+1:                                                               | :+1:                                                      | :+1:                                                                 | :+1:                                                | :+1:                                              | :x:                                                   |
| CMake                                                               | :+1:              | :+1:                                                               | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                               | :x:                                                   |
| dart                                                                | :+1:              | :x:                                                                | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                               | :x:                                                   |
| Docker                                                              | :+1:              | :+1:                                                               | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                               | :x:                                                   |
| DOS/Windows Batch                                                   | :+1:              | :x:                                                                | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                               | :x:                                                   |
| fish                                                                | :+1:              | :+1:                                                               | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                               | :x:                                                   |
| Fortran                                                             | :x:               | :+1:                                                               | :x:                                                       | :x:                                                                  | :+1:                                                | :x:                                               | :x:                                                   |
| Golang                                                              | :+1:              | :+1:                                                               | :+1:                                                      | :+1:                                                                 | :+1:                                                | :x:                                               | :+1:                                                  |
| Haskell                                                             | :x:               | :+1:                                                               | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                               | :x:                                                   |
| Java                                                                | :+1:              | :+1:                                                               | :+1:                                                      | :+1:                                                                 | :+1:                                                | :x:                                               | :x:                                                   |
| Javascript/Typescript                                               | :+1:              | :+1:                                                               | :+1:                                                      | :+1:                                                                 | :+1:                                                | :x:                                               | :+1:                                                  |
| Kotlin                                                              | :+1:              | :x:                                                                | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                               | :x:                                                   |
| lua                                                                 | :+1:              | :+1:                                                               | :+1:                                                      | :+1:                                                                 | :+1:                                                | :x:                                               | :+1:                                                  |
| GNU Make                                                            | :+1:              | :+1:                                                               | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                               | :x:                                                   |
| Perl                                                                | :+1:              | :x:                                                                | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                               | :x:                                                   |
| PHP                                                                 | :+1:              | :+1:                                                               | :x:                                                       | :+1:                                                                 | :x:                                                 | :x:                                               | :x:                                                   |
| Powershell/ps1                                                      | :+1:              | :x:                                                                | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                               | :x:                                                   |
| Python                                                              | :+1:              | :+1:                                                               | :+1:                                                      | :+1:                                                                 | :+1:                                                | :x:                                               | :x:                                                   |
| R                                                                   | :+1:              | :x:                                                                | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                               | :x:                                                   |
| Ruby                                                                | :+1:              | :+1:                                                               | :x:                                                       | :+1:                                                                 | :x:                                                 | :x:                                               | :x:                                                   |
| Rust                                                                | :+1:              | :+1:                                                               | :+1:                                                      | :x:                                                                  | :+1:                                                | :x:                                               | :x:                                                   |
| Swift                                                               | :+1:              | :x:                                                                | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                               | :x:                                                   |
| VimL                                                                | :+1:              | :+1:                                                               | :+1:                                                      | :x:                                                                  | :+1:                                                | :x:                                               | :x:                                                   |
| zsh                                                                 | :+1:              | :+1:                                                               | :+1:                                                      | :x:                                                                  | :+1:                                                | :x:                                               | :x:                                                   |
| Add custom filetypes (doced/supported)                              | :+1:              | :x:                                                                | :+1:                                                      | :x:                                                                  | :x:                                                 | :+1:                                              | :+1:                                                  |
| Customizable callback formatter                                     | :x:               | :x:                                                                | :+1:                                                      | :x:                                                                  | :x:                                                 | :x:                                               | :x:                                                   |
| Implemented in                                                      | Lua               | VimL                                                               | Lua                                                       | Lua                                                                  | VimL                                                | VimL                                              | Lua                                                   |
