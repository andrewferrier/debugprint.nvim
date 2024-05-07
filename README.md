# debugprint.nvim

![Test status](https://github.com/andrewferrier/debugprint.nvim/actions/workflows/tests.yaml/badge.svg)

## Overview

`debugprint` is a NeoVim plugin that simplifies debugging for those who prefer a
low-tech approach. Instead of using a sophisticated debugger like
[nvim-dap](https://github.com/mfussenegger/nvim-dap), some people prefer using a
'print' statement to trace the output during execution. With `debugprint`, you
can insert 'print' statements, with debug information pre-populated, relevant to
the language you're editing. These statements include reference information for
quick output navigation and the ability to output variable values.

`debugprint` supports 30 filetypes/programming languages out-of-the-box,
including Python, JavaScript/TypeScript, Java, C/C++ and more. See [the
comparison table](#feature-comparison-with-other-plugins) for the full list. It
can also be extended to support other languages.

## Features

`debugprint` is inspired by
[vim-debugstring](https://github.com/bergercookie/vim-debugstring), but is
updated and refreshed for the NeoVim generation. It has these features:

*   It includes reference information in each 'print line' such as file names,
    line numbers, a monotonic counter, and snippets of other lines to make it easier
    to cross-reference them in output.

*   It can output the value of variables (or in some cases, expressions).

*   It [dot-repeats](https://jovicailic.org/2018/03/vim-the-dot-command/).

*   It can detect a variable name under the cursor if it's a supported Treesitter-based
    language, or will prompt for the variable name with a sensible default if not.

*   It knows which filetype you are working with when embedded inside another
    filetype, e.g. JavaScript-in-HTML, using Treesitter magic.

*   In addition to normal mode, it provides keymappings for visual and operator-pending
    modes, so you can select variables visually and using motions respectively.

*   It provides commands to delete all debugging lines added to the current buffer
    as well as comment/uncomment those lines.

*   It can optionally move to the inserted line (or not).

*   You can add support for languages it doesn't support out of the box.

*   It's [MIT Licensed](LICENSE.txt).

## Demo

<div align="center">
  <video src="https://github.com/andrewferrier/debugprint.nvim/assets/107015/e1a8b93b-0c8f-4f02-86e8-cbe1d476940c" type="video/mp4"></video>
</div>

## Installation

**Requires NeoVim 0.8+.**

Example for [`lazy.nvim`](https://github.com/folke/lazy.nvim):

```lua
return {
    "andrewferrier/debugprint.nvim",
    opts = { … },
    dependencies = {
        "echasnovski/mini.nvim", -- Needed to enable :ToggleCommentDebugPrints for NeoVim <= 0.9
        "nvim-treesitter/nvim-treesitter" -- Needed to enable treesitter for NeoVim 0.8
    },
    -- Remove the following line to use development versions,
    -- not just the formal releases
    version = "*"
}
```

Example for [`packer.nvim`](https://github.com/wbthomason/packer.nvim):

```lua
packer.startup(function(use)
    …
    use({
        "andrewferrier/debugprint.nvim",
        config = function()
            opts = { … }
            require("debugprint").setup(opts)
        end,
        requires = {
            "echasnovski/mini.nvim", -- Needed to enable :ToggleCommentDebugPrints for NeoVim <= 0.9
            "nvim-treesitter/nvim-treesitter" -- Needed to enable treesitter for NeoVim 0.8
        }
    })
    …
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

| Mode       | Default Key / Cmd           | Purpose                                     | Above/Below Line |
| ---------- | --------------------------- | ------------------------------------------- | ---------------- |
| Normal     | `g?p`                       | Plain debug                                 | Below            |
| Normal     | `g?P`                       | Plain debug                                 | Above            |
| Normal     | `g?v`                       | Variable debug                              | Below            |
| Normal     | `g?V`                       | Variable debug                              | Above            |
| Normal     | None                        | Variable debug (always prompt for variable) | Below            |
| Normal     | None                        | Variable debug (always prompt for variable) | Above            |
| Normal     | None                        | Delete debug lines in buffer                | -                |
| Normal     | None                        | Comment/uncomment debug lines in buffer     | -                |
| Visual     | `g?v`                       | Variable debug                              | Below            |
| Visual     | `g?V`                       | Variable debug                              | Above            |
| Op-pending | `g?o`                       | Variable debug                              | Below            |
| Op-pending | `g?O`                       | Variable debug                              | Above            |
| Command    | `:DeleteDebugPrints`        | Delete debug lines in buffer                | -                |
| Command    | `:ToggleCommentDebugPrints` | Comment/uncomment debug lines in buffer     | -                |

The keys and commands outlined above can be specifically overridden using the
`keymaps` and `commands` objects inside the `opts` object used above during
configuration of debugprint. For example, if configuring via `lazy.nvim`, it
might look like this:

```lua
return {
    "andrewferrier/debugprint.nvim",
    opts = {
        keymaps = {
            normal = {
                plain_below = "g?p",
                plain_above = "g?P",
                variable_below = "g?v",
                variable_above = "g?V",
                variable_below_alwaysprompt = nil,
                variable_above_alwaysprompt = nil,
                textobj_below = "g?o",
                textobj_above = "g?O",
                toggle_comment_debug_prints = nil,
                delete_debug_prints = nil,
            },
            visual = {
                variable_below = "g?v",
                variable_above = "g?V",
            },
        },
        commands = {
            toggle_comment_debug_prints = "ToggleCommentDebugPrints",
            delete_debug_prints = "DeleteDebugPrints",
        },
    },
    -- The 'keys' and 'cmds' sections of this configuration are only needed if
    -- you want to take advantage of `lazy.nvim` lazy-loading.
    keys = {
        { "g?p", mode = 'n' },
        { "g?P", mode = 'n' },
        { "g?v", mode = 'n' },
        { "g?V", mode = 'n' },
        { "g?o", mode = 'n' },
        { "g?O", mode = 'n' },
        { "g?v", mode = 'x' },
        { "g?V", mode = 'x' },
    },
    cmd = {
        "ToggleCommentDebugPrints",
        "DeleteDebugPrints",
    },
    version = "*"
}
```

You only need to include the keys / commands which you wish to override, others
will default as shown above. Setting any key or command to `nil` will skip it.

The default keymappings are chosen specifically because ordinarily in NeoVim
they are used to convert sections to ROT-13, which most folks don't use.

## Mapping Deprecation

*Note*: as of version 2.0.0, the old mechanism of configuring keymaps/commands
which specifically allowed for mapping directly to
`require('debugprint').debugprint(...)` is no longer officially supported or
documented. This is primarily because of confusion which arose over how to do
this mapping. Existing mappings performed this way are likely to continue to
work for some time. You should, however, migrate over to the new method outlined
above. If this doesn't give you the flexibility to map how you wish for some
reason, please open an
[issue](https://github.com/andrewferrier/debugprint.nvim/issues/new).

## Other Options

`debugprint` supports the following options in its global `opts` object:

| Option              | Default      | Purpose                                                                                                                                |
| ------------------- | ------------ | -------------------------------------------------------------------------------------------------------------------------------------- |
| `move_to_debugline` | `false`      | When adding a debug line, moves the cursor to that line                                                                                |
| `display_counter`   | `true`       | Whether to display/include the increasing integer counter in each debug message. Can also be set to a function to customize, see below |
| `display_snippet`   | `true`       | Whether to include a snippet of the line above/below in plain debug lines                                                              |
| `filetypes`         | See below    | Custom filetypes - see below                                                                                                           |
| `print_tag`         | `DEBUGPRINT` | The string inserted into each print statement, which can be used to uniquely identify statements inserted by `debugprint`.             |

### Customizing Counter Logic

`display_counter` can also be set to a custom callback function to implement
custom counter logic. In this case you are responsible for implementing your own
counter. For example, this logic will implement essentially the same as the
default counter:

```lua
local counter = 0

local counter_func = function()
    counter = counter + 1
    return '[' .. tostring(counter) .. ']'
end

debugprint.setup({display_counter = counter_func})
```

## Add Custom Filetypes

*Note: If you work out a configuration for a filetype not supported
out-of-the-box, it would be appreciated if you can open an
[issue](https://github.com/andrewferrier/debugprint.nvim/issues/new) to have it
supported out-of-the-box in `debugprint` so others can benefit. Similarly, if
you spot any issues with, or improvements to, the language configurations
out-of-the-box, please open an issue also.*

If `debugprint` doesn't support your filetype, you can add it as a custom
filetype in one of two ways:

*   In the `opts.filetypes` object in `setup()`.

*   Using the `require('debugprint').add_custom_filetypes()` method (designed for
    use from `ftplugin/` directories, etc.

In either case, the format is the same. For example, if adding via `setup()`:

```lua
local my_fileformat = {
    left = 'print "',
    left_var = 'print "', -- `left_var` is optional, for 'variable' lines only; `left` will be used if it's not present
    right = '"',
    mid_var = "${",
    right_var = '}"',
}

require('debugprint').setup({ filetypes = { ["filetype"] = my_fileformat, ["another_filetype"] = another_of_my_fileformats, ... }})
```

or `add_custom_filetypes()`:

```lua
require('debugprint').add_custom_filetypes({ my_fileformat, ... })
```

Your new file format will be *merged* in with those that already exist. If you
pass in one that already exists, your configuration will override the built-in
configuration.

The keys in the configuration are used like this:

| Debug line type     | Default keys            | How debug line is constructed                                                                                                                           |
| ------------------- | ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Plain debug line    | `g?p`/`g?P`             | `my_fileformat.left .. "auto-gen DEBUG string" .. my_fileformat.right`                                                                                  |
| Variable debug line | `g?v`/`g?V`/`g?o`/`g?O` | `my_fileformat.left_var (or my_fileformat.left) .. "auto-gen DEBUG string, variable=" .. my_file_format.mid_var .. variable .. my_fileformat.right_var` |

If it helps to understand these, you can look at the built-in configurations in
[filetypes.lua](lua/debugprint/filetypes.lua).

## Feature Comparison with Similar Plugins

(This table is quite wide, you may need to scroll horizontally)

| Feature                                                             | `debugprint.nvim` | [nvim-chainsaw](https://github.com/chrisgrieser/nvim-chainsaw) | [printer.nvim](https://github.com/rareitems/printer.nvim) | [refactoring.nvim](https://github.com/ThePrimeagen/refactoring.nvim) | [vim-printer](https://github.com/meain/vim-printer) | [logsitter](https://github.com/gaelph/logsitter.nvim) |
| ------------------------------------------------------------------- | ----------------- | -------------------------------------------------------------- | --------------------------------------------------------- | -------------------------------------------------------------------- | --------------------------------------------------- | ----------------------------------------------------- |
| Auto-generation of debug line, incl. locator info                   | :+1:              | :x:                                                            | :+1:                                                      | :+1:                                                                 | :x:                                                 | :+1:                                                  |
| Print plain debug lines                                             | :+1:              | :+1:                                                           | :x:                                                       | :+1:                                                                 | :x:                                                 | :x:                                                   |
| Print variables using current word/heuristic                        | :+1:              | :+1:                                                           | :x:                                                       | :x:                                                                  | :+1:                                                | :x:                                                   |
| Print variables using treesitter                                    | :+1:              | :+1:                                                           | :x:                                                       | :+1:                                                                 | :x:                                                 | :x:                                                   |
| Print variables/expressions using prompts                           | :+1:              | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Print variables using motions                                       | :+1:              | :x:                                                            | :+1:                                                      | :x:                                                                  | :x:                                                 | :x:                                                   |
| Print variables using visual mode                                   | :+1:              | :+1:                                                           | :+1:                                                      | :+1:                                                                 | :+1:                                                | :x:                                                   |
| Print assertions                                                    | :x:               | :+1:                                                           | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Print stack traces                                                  | :x:               | :+1:                                                           | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Add time-tracking logic                                             | :x:               | :+1:                                                           | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Add debugging breakpoints                                           | :x:               | :+1:                                                           | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Print debug lines above/below current line                          | :+1:              | :x:                                                            | (via global config)                                       | :x:                                                                  | :+1:                                                | :x:                                                   |
| Supports [dot-repeat](https://www.vikasraj.dev/blog/vim-dot-repeat) | :+1:              | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Can control whether to move to inserted lines                       | :+1:              | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Clean up all debug lines                                            | :+1:              | :+1:                                                           | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Comment/uncomment all debug lines                                   | :+1:              | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Can put debugprint text into default register                       | :x:               | :x:                                                            | :+1:                                                      | :x:                                                                  | :x:                                                 | :x:                                                   |
| *Built-in support for:*                                             | -                 | -                                                              | -                                                         | -                                                                    | -                                                   | -                                                     |
| AppleScript                                                         | :+1:              | :+1:                                                           | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| bash/sh                                                             | :+1:              | :+1:                                                           | :+1:                                                      | :x:                                                                  | :+1:                                                | :x:                                                   |
| C                                                                   | :+1:              | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| C#                                                                  | :+1:              | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| C++                                                                 | :+1:              | :x:                                                            | :+1:                                                      | :+1:                                                                 | :+1:                                                | :x:                                                   |
| CMake                                                               | :+1:              | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| dart                                                                | :+1:              | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Docker                                                              | :+1:              | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| DOS/Windows Batch                                                   | :+1:              | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Elixir                                                              | :+1:              | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| fish                                                                | :+1:              | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Fortran                                                             | :+1:              | :x:                                                            | :x:                                                       | :x:                                                                  | :+1:                                                | :x:                                                   |
| Golang                                                              | :+1:              | :x:                                                            | :+1:                                                      | :+1:                                                                 | :+1:                                                | :+1:                                                  |
| Haskell                                                             | :+1:              | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Java                                                                | :+1:              | :x:                                                            | :+1:                                                      | :+1:                                                                 | :+1:                                                | :x:                                                   |
| Javascript/Typescript                                               | :+1:              | :+1:                                                           | :+1:                                                      | :+1:                                                                 | :+1:                                                | :+1:                                                  |
| Kotlin                                                              | :+1:              | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| lean                                                                | :+1:              | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| lua                                                                 | :+1:              | :+1:                                                           | :+1:                                                      | :+1:                                                                 | :+1:                                                | :+1:                                                  |
| GNU Make                                                            | :+1:              | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Perl                                                                | :+1:              | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| PHP                                                                 | :+1:              | :x:                                                            | :x:                                                       | :+1:                                                                 | :x:                                                 | :x:                                                   |
| Powershell/ps1                                                      | :+1:              | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Python                                                              | :+1:              | :+1:                                                           | :+1:                                                      | :+1:                                                                 | :+1:                                                | :x:                                                   |
| R                                                                   | :+1:              | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Ruby                                                                | :+1:              | :+1:                                                           | :x:                                                       | :+1:                                                                 | :x:                                                 | :x:                                                   |
| Rust                                                                | :+1:              | :+1:                                                           | :+1:                                                      | :x:                                                                  | :+1:                                                | :x:                                                   |
| Swift                                                               | :+1:              | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| VimL (vimscript)                                                    | :+1:              | :x:                                                            | :+1:                                                      | :x:                                                                  | :+1:                                                | :x:                                                   |
| zsh                                                                 | :+1:              | :x:                                                            | :+1:                                                      | :x:                                                                  | :+1:                                                | :x:                                                   |
| Add custom filetypes (doced/supported)                              | :+1:              | :+1:                                                           | :+1:                                                      | :x:                                                                  | :x:                                                 | :+1:                                                  |
| Customizable callback formatter                                     | :x:               | :x:                                                            | :+1:                                                      | :x:                                                                  | :x:                                                 | :x:                                                   |
| Implemented in                                                      | Lua               | Lua                                                            | Lua                                                       | Lua                                                                  | VimL                                                | Lua                                                   |

Other unmaintained plugins (last updated more than 3 years ago):

*   [vim-debugstring](https://github.com/bergercookie/vim-debugstring)
*   [vim-printf](https://github.com/mptre/vim-printf)
