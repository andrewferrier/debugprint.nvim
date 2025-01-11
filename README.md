```text
▗▄▄▄ ▗▄▄▄▖▗▄▄▖ ▗▖ ▗▖ ▗▄▄▖▗▄▄▖ ▗▄▄▖ ▗▄▄▄▖▗▖  ▗▖▗▄▄▄▖
▐▌  █▐▌   ▐▌ ▐▌▐▌ ▐▌▐▌   ▐▌ ▐▌▐▌ ▐▌  █  ▐▛▚▖▐▌  █
▐▌  █▐▛▀▀▘▐▛▀▚▖▐▌ ▐▌▐▌▝▜▌▐▛▀▘ ▐▛▀▚▖  █  ▐▌ ▝▜▌  █
▐▙▄▄▀▐▙▄▄▖▐▙▄▞▘▝▚▄▞▘▝▚▄▞▘▐▌   ▐▌ ▐▌▗▄█▄▖▐▌  ▐▌  █
```

![Test status](https://github.com/andrewferrier/debugprint.nvim/actions/workflows/tests.yaml/badge.svg)
![GitHub License](https://img.shields.io/github/license/andrewferrier/debugprint.nvim)
<a href="https://dotfyle.com/plugins/andrewferrier/debugprint.nvim">
<img src="https://dotfyle.com/plugins/andrewferrier/debugprint.nvim/shield?style=flat" alt="debugprint dotfyle shield"/>
</a>

## Overview

`debugprint` is a NeoVim plugin that simplifies debugging [for those who prefer a low-tech approach](https://www.polymonster.co.uk/blog/printf-debugging-is-ok).
Instead of using a sophisticated debugger like
[nvim-dap](https://github.com/mfussenegger/nvim-dap), some people prefer using a
'print'-like statement to trace the output during execution. With `debugprint`,
you can insert these statements, including the values of variables, relevant to
the language you're editing.

## Features

`debugprint` is inspired by
[vim-debugstring](https://github.com/bergercookie/vim-debugstring); updated for
the NeoVim generation. It:

- Supports 38 filetypes/programming languages out-of-the-box, including
  Python, JavaScript/TypeScript, Java, C/C++ and
  [more](#feature-comparison-with-similar-plugins). [It can also be extended to
  support other languages or customize existing ones](SHOWCASE.md).

- Includes reference information in each 'print line' such as file names, line
  numbers, a counter (which persists between NeoVim sessions), and snippets of
  other lines to make it easier to cross-reference them in output. Each of these
  can be optionally disabled [globally](#other-options) or [on a per-filetype
  basis](SHOWCASE.md#setting-display_-options-on-per-filetype-basis).

- Will highlight inserted lines to make them easier to find in your code
  (depends on [mini.hipatterns](https://github.com/echasnovski/mini.hipatterns)).

- Can output the value of variables (or in some cases, expressions) - it will
  detect a variable name under the cursor for some languages using Treesitter, or
  will prompt with a sensible default. It understands Treesitter embedded
  languages (e.g. JavaScript-in-HTML).

- Provides [keymappings](#keymappings-and-commands) for normal, insert,
  visual, and operator-pending modes. Supports
  [dot-repeat](https://jovicailic.org/2018/03/vim-the-dot-command/).

- Supports direct writing to NeoVim registers for batch insert of debugprint
  lines.

- Provides [commands](#keymappings-and-commands) to delete debugging lines added to the current buffer or
  comment/uncomment those lines.

- Can optionally move to the inserted line (or not).

## Demo

<div align="center">
  <video src="https://github.com/andrewferrier/debugprint.nvim/assets/107015/e1a8b93b-0c8f-4f02-86e8-cbe1d476940c" type="video/mp4"></video>
</div>

## Installation

**Requires NeoVim 0.9+.**

Example for [`lazy.nvim`](https://github.com/folke/lazy.nvim):

```lua
return {
    "andrewferrier/debugprint.nvim",

    -- opts = { … },

    dependencies = {
        "echasnovski/mini.nvim" -- Needed for :ToggleCommentDebugPrints(NeoVim 0.9 only)
                                -- and line highlighting (optional)
    },

    lazy = false, -- Required to make line highlighting work before debugprint is first used
    version = "*", -- Remove if you DON'T want to use the stable version
}
```

(Examples for other package managers
[here](SHOWCASE.md#using-package-managers-other-than-lazynvim).)

The sections below detail the allowed options that can appear in the `opts`
object. There is also a showcase of example and advanced debugprint
configurations [here](SHOWCASE.md) which can be dropped into your configuration
files to further enhance your use of debugprint.

Please subscribe to [this GitHub
issue](https://github.com/andrewferrier/debugprint.nvim/issues/25) to be
notified of any breaking changes to `debugprint`.

## Keymappings and Commands

By default, the plugin will create some keymappings and commands for use 'out of
the box'. There are also some function invocations which are not mapped to any
keymappings or commands by default, but could be. This is all shown in the
following table.

| Mode       | Default Key / Cmd           | Purpose                                                                         | Above/Below Line |
| ---------- | --------------------------- | ------------------------------------------------------------------------------- | ---------------- |
| Normal     | `g?p`                       | Plain debug                                                                     | Below            |
| Normal     | `g?P`                       | Plain debug                                                                     | Above            |
| Normal     | `g?v`                       | Variable debug                                                                  | Below            |
| Normal     | `g?V`                       | Variable debug                                                                  | Above            |
| Normal     | None                        | Variable debug (always prompt for variable)                                     | Below            |
| Normal     | None                        | Variable debug (always prompt for variable)                                     | Above            |
| Normal     | None                        | Delete debug lines in buffer                                                    | -                |
| Normal     | None                        | Comment/uncomment debug lines in buffer                                         | -                |
| Insert     | `Ctrl-G p`                  | Plain debug                                                                     | In-place         |
| Insert     | `Ctrl-G v`                  | Variable debug (always prompt for variable)                                     | In-place         |
| Visual     | `g?v`                       | Variable debug                                                                  | Below            |
| Visual     | `g?V`                       | Variable debug                                                                  | Above            |
| Op-pending | `g?o`                       | Variable debug                                                                  | Below            |
| Op-pending | `g?O`                       | Variable debug                                                                  | Above            |
| Command    | `:DeleteDebugPrints`        | Delete debug lines in buffer                                                    | -                |
| Command    | `:ToggleCommentDebugPrints` | Comment/uncomment debug lines in buffer                                         | -                |
| Command    | `:ResetDebugPrintsCounter`  | Reset debug print persistent counter (only for built-in counter implementation) | -                |

Each of the keymappings (except for insert mode) can also be prefixed with a
register, see the [showcase](SHOWCASE.md#register-usage) for an example of how
to use this to insert debugprint lines in batches.

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
                variable_below_alwaysprompt = "",
                variable_above_alwaysprompt = "",
                textobj_below = "g?o",
                textobj_above = "g?O",
                toggle_comment_debug_prints = "",
                delete_debug_prints = "",
            },
            insert = {
                plain = "<C-G>p",
                variable = "<C-G>v",
            },
            visual = {
                variable_below = "g?v",
                variable_above = "g?V",
            },
        },
        commands = {
            toggle_comment_debug_prints = "ToggleCommentDebugPrints",
            delete_debug_prints = "DeleteDebugPrints",
            reset_debug_prints_counter = "ResetDebugPrintsCounter",
        },
        -- … Other options
    },
}
```

You only need to include the keys / commands which you wish to override, others
will default as shown above. Setting any key or command to `""` or `false` will
skip it.

The default keymappings are chosen specifically because ordinarily in NeoVim
they are used to convert sections to ROT-13, which most folks don't use.

## Mapping Deprecation

> [!WARNING]
> *Note*: as of version 2.0.0, the old mechanism of configuring keymaps/commands
> which specifically allowed for mapping directly to
> `require('debugprint').debugprint(...)` is no longer officially supported or
> documented. This is primarily because of [confusion](https://github.com/andrewferrier/debugprint.nvim/issues/44#issuecomment-1896405231) which arose over how to do
> this mapping. Existing mappings performed this way are likely to continue to
> work for some time. You should, however, migrate over to the new method outlined
> above. If this doesn't give you the flexibility to map how you wish for some
> reason, please open an
> [issue](https://github.com/andrewferrier/debugprint.nvim/issues/new).

## Other Options

`debugprint` supports the following options in its global `opts` object:

| Option                 | Default                                        | Purpose                                                                                                                                                                                                                                                                                        |
| ---------------------- | ---------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `move_to_debugline`    | `false`                                        | When adding a debug line, moves the cursor to that line                                                                                                                                                                                                                                        |
| `display_location`     | `true`                                         | Include the filename and linenumber of the line being debugged in the debug message                                                                                                                                                                                                            |
| `display_counter`      | `true`                                         | Include the increasing integer counter in the debug message. (If you want to customize this counter, or make it non-persistent, see instructions in the [showcase](SHOWCASE.md#restoring-non-persistent-display_counter-counter) for an example).                                              |
| `display_snippet`      | `true`                                         | Include a snippet of the line above/below in the debug message (plain debug lines only) for context                                                                                                                                                                                            |
| `notify_for_registers` | `true`                                         | If set to false, disables the notifications that occur when debugprint lines are inserted or appended to registers                                                                                                                                                                             |
| `highlight_lines`      | `true`                                         | Apply highlighting to debugprint lines. See [showcase](SHOWCASE.md#highlighting-lines) for more information on customization and limitations                                                                                                                                                   |
| `filetypes`            | See ([the code](lua/debugprint/filetypes.lua)) | Custom filetypes - see [showcase](SHOWCASE.md)                                                                                                                                                                                                                                                 |
| `print_tag`            | `DEBUGPRINT`                                   | The string inserted into each print statement, which can be used to uniquely identify statements inserted by `debugprint`. If you set this to `''` (the empty string), no print tag will be included, but this will disable the ability to delete, comment, or highlight print statements via `debugprint` |

## Known Limitations

- `debugprint` does not handle deleting reformatted debug lines where a
  formatter has split them across multiple lines. If you want to be able to easily
  delete your debug lines using `DeleteDebugPrints` or similar, don't format your
  file between inserting them and running this command. See [this
  issue](https://github.com/andrewferrier/debugprint.nvim/issues/119) for
  discussion on this.

## Feature Comparison with Similar Plugins

(This table is quite wide, you may need to scroll horizontally)

| Feature                                                             | `debugprint.nvim`         | [timber.nvim](https://github.com/Goose97/timber.nvim) | [nvim-chainsaw](https://github.com/chrisgrieser/nvim-chainsaw) | [printer.nvim](https://github.com/rareitems/printer.nvim) | [refactoring.nvim](https://github.com/ThePrimeagen/refactoring.nvim) | [vim-printer](https://github.com/meain/vim-printer) | [logsitter](https://github.com/gaelph/logsitter.nvim) |
| ------------------------------------------------------------------- | ------------------------- | ----------------------------------------------------- | -------------------------------------------------------------- | --------------------------------------------------------- | -------------------------------------------------------------------- | --------------------------------------------------- | ----------------------------------------------------- |
| Include line numbers in log lines                                   | :+1:                      | :+1: (via user config)                                | :+1: (via user config)                                         | :+1:                                                      | :+1:                                                                 | :x:                                                 | :+1:                                                  |
| Include other location information in log lines                     | :+1:                      | :x:                                                   | :+1: (via user config)                                         | :+1:                                                      | :+1:                                                                 | :x:                                                 | :+1:                                                  |
| Persistent location counter between NeoVim sessions                 | :+1:                      | :x:                                                   | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Print plain debug lines                                             | :+1:                      | :+1: (via user config)                                | :+1:                                                           | :x:                                                       | :+1:                                                                 | :x:                                                 | :x:                                                   |
| Print variables using treesitter                                    | :+1:                      | :+1:                                                  | :+1:                                                           | :x:                                                       | :+1:                                                                 | :x:                                                 | :x:                                                   |
| Use treesitter to locate log targets                                | (some languages)          | :+1:                                                  | :+1:                                                           | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Use treesitter to intelligently insert log lines                    | :x:                       | :+1:                                                  | :+1:                                                           | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Enter variables/expressions using prompts                           | :+1:                      | :x:                                                   | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Fallback to variables using current word/heuristic                  | :+1:                      | :x:                                                   | :+1:                                                           | :x:                                                       | :x:                                                                  | :+1:                                                | :x:                                                   |
| Print variables using motions/operator                              | :+1:                      | :+1:                                                  | :x:                                                            | :+1:                                                      | :x:                                                                  | :x:                                                 | :x:                                                   |
| Add plain or variable debug lines in insert mode                    | :+1:                      | :x:                                                   | :x:                                                            | :x::                                                      | :x:                                                                  | :x:                                                 | :x:                                                   |
| Add variable debug lines in visual mode                             | :+1:                      | :+1:                                                  | :+1:                                                           | :+1:                                                      | :+1:                                                                 | :+1:                                                | :x:                                                   |
| Print assertions                                                    | :x:                       | :+1: (via user config)                                | :+1:                                                           | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Print stack traces                                                  | :x:                       | :+1: (via user config)                                | :+1:                                                           | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Add time-tracking logic                                             | :x:                       | :+1: (via user config)                                | :+1:                                                           | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Add debugging breakpoints                                           | :x:                       | :+1: (via user config)                                | :+1:                                                           | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Print debug lines above/below current line                          | :+1:                      | :+1:                                                  | :x:                                                            | (via global config)                                       | :x:                                                                  | :+1:                                                | :x:                                                   |
| Supports [dot-repeat](https://www.vikasraj.dev/blog/vim-dot-repeat) | :+1:                      | :+1:                                                  | :+1:                                                           | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Can control whether to move to inserted lines                       | :+1:                      | :x:                                                   | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Clean up/delete all debug lines in buffer                           | :+1:                      | :+1:                                                  | :+1:                                                           | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Comment/uncomment all debug lines in buffer                         | :+1:                      | :+1:                                                  | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Comment/uncomment all debug lines in selected range                 | :+1:                      | :x:                                                   | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Can put debugprint text into register                               | :+1:                      | :x:                                                   | :x:                                                            | :+1:                                                      | :x:                                                                  | :x:                                                 | :x:                                                   |
| Extra visual emphasis of log statements                             | :+1: Highlights inserted lines | :+1: Flashes to highlight lines on insertion               | :+1: status line counter, signcolumn, line-highlight, scrollbar     | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Can insert logs in batches                                          | :+1: (using registers)    | :+1:                                                  | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Log watcher mechanism                                               | :x:                       | :+1:                                                  | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Completely customizable log lines                                   | :x:                       | :+1:                                                  | :+1:                                                           | :+1:                                                      | :x:                                                                  | :x:                                                 | :x:                                                   |
| *Built-in support for:*                                             | -                         | -                                                     | -                                                              | -                                                         | -                                                                    | -                                                   | -                                                     |
| [Apex](https://github.com/xixiaofinland/sf.nvim) (Salesforce)       | :+1:                      | :x:                                                   | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| AppleScript                                                         | :+1:                      | :x:                                                   | :+1:                                                           | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| bash/sh                                                             | :+1:                      | :x:                                                   | :+1:                                                           | :+1:                                                      | :x:                                                                  | :+1:                                                | :x:                                                   |
| C                                                                   | :+1:                      | :x:                                                   | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| C#                                                                  | :+1:                      | :x:                                                   | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| C++                                                                 | :+1:                      | :x:                                                   | :x:                                                            | :+1:                                                      | :+1:                                                                 | :+1:                                                | :x:                                                   |
| CMake                                                               | :+1:                      | :x:                                                   | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Cobol                                                               | :+1:                      | :x:                                                   | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| dart                                                                | :+1:                      | :x:                                                   | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Docker                                                              | :+1:                      | :x:                                                   | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| DOS/Windows Batch                                                   | :+1:                      | :x:                                                   | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Elixir                                                              | :+1:                      | :+1:                                                  | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| fish                                                                | :+1:                      | :x:                                                   | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Fortran                                                             | :+1:                      | :x:                                                   | :x:                                                            | :x:                                                       | :x:                                                                  | :+1:                                                | :x:                                                   |
| Golang                                                              | :+1:                      | :+1:                                                  | :+1:                                                           | :+1:                                                      | :+1:                                                                 | :+1:                                                | :+1:                                                  |
| Haskell                                                             | :+1:                      | :x:                                                   | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Java                                                                | :+1:                      | :x:                                                   | :x:                                                            | :+1:                                                      | :+1:                                                                 | :+1:                                                | :x:                                                   |
| Javascript/Typescript                                               | :+1:                      | :+1:                                                  | :+1:                                                           | :+1:                                                      | :+1:                                                                 | :+1:                                                | :+1:                                                  |
| Kotlin                                                              | :+1:                      | :x:                                                   | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| lean                                                                | :+1:                      | :x:                                                   | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Lisp                                                                | :+1:                      | :x:                                                   | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| lua                                                                 | :+1:                      | :+1:                                                  | :+1:                                                           | :+1:                                                      | :+1:                                                                 | :+1:                                                | :+1:                                                  |
| GNU Make                                                            | :+1:                      | :x:                                                   | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Perl                                                                | :+1:                      | :x:                                                   | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| PHP                                                                 | :+1:                      | :x:                                                   | :x:                                                            | :x:                                                       | :+1:                                                                 | :x:                                                 | :x:                                                   |
| Powershell/ps1                                                      | :+1:                      | :x:                                                   | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Python                                                              | :+1:                      | :x:                                                   | :+1:                                                           | :+1:                                                      | :+1:                                                                 | :+1:                                                | :x:                                                   |
| R                                                                   | :+1:                      | :x:                                                   | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| React                                                               | :+1:                      | :x:                                                   | :+1:                                                           | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Ruby                                                                | :+1:                      | :+1:                                                  | :+1:                                                           | :x:                                                       | :+1:                                                                 | :x:                                                 | :x:                                                   |
| Rust                                                                | :+1:                      | :+1:                                                  | :+1:                                                           | :+1:                                                      | :x:                                                                  | :+1:                                                | :x:                                                   |
| Swift                                                               | :+1:                      | :x:                                                   | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Svelte                                                              | :+1:                      | :x:                                                   | :+1:                                                           | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| tcl                                                                 | :+1:                      | :x:                                                   | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| VimL (vimscript)                                                    | :+1:                      | :x:                                                   | :x:                                                            | :+1:                                                      | :x:                                                                  | :+1:                                                | :x:                                                   |
| Vue                                                                 | :+1:                      | :x:                                                   | :+1:                                                           | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| Zig                                                                 | :+1:                      | :x:                                                   | :x:                                                            | :x:                                                       | :x:                                                                  | :x:                                                 | :x:                                                   |
| zsh                                                                 | :+1:                      | :x:                                                   | :+1:                                                           | :+1:                                                      | :x:                                                                  | :+1:                                                | :x:                                                   |
| [Add custom filetypes](SHOWCASE.md)                                 | :+1:                      | :+1:                                                  | :+1:                                                           | :+1:                                                      | :x:                                                                  | :x:                                                 | :+1:                                                  |
| Implemented in                                                      | Lua                       | Lua                                                   | Lua                                                            | Lua                                                       | Lua                                                                  | VimL                                                | Lua                                                   |

There is also [a similar table in the nvim-chainsaw documentation](https://github.com/chrisgrieser/nvim-chainsaw?tab=readme-ov-file#comparison-with-similar-plugins).

Other similar plugins (less popular or unmaintained):

- [my-neovim-pluglist](https://yutkat.github.io/my-neovim-pluginlist/debugger_repl.html#print-debug)
- [vim-debugstring](https://github.com/bergercookie/vim-debugstring)
- [vim-printf](https://github.com/mptre/vim-printf)
