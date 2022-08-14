# debugprint.nvim

## Overview

The gold standard for debugging a program or script is to use a real debugger.
For NeoVim, the 'standard' way to integrate this is to use something like
[nvim-dap](https://github.com/mfussenegger/nvim-dap). However, many folks prefer
a more low-tech approach; the 'print' statement, or the equivalent in a
particular language, to trace the output of a program during execution.
`debugprint` is a NeoVim plugin for them, as it can easily generate 'print'
statements appropriate to the language being edited, which include:

*   A tag string unique to `debugprint`.

*   The filename/line number they are being inserted on.

*   A counter which increases over the duration of a NeoVim session each time a statement is generated.

*   (optionally) A variable (which may be automatically picked up from an identifier/variable name under the cursor).

`debugprint` comes with the generation logic built in for many common
programming languages, and can be extended to support more.

`debugprint` is inspired by
[vim-debugstring](https://github.com/bergercookie/vim-debugstring), which I've
used for several years, but is updated and refreshed for the NeoVim generation.
It provides various improvements:

*   Its configuration system is more 'NeoVim-like' and it is easier to add custom
    languages in your configuration.

*   It [dot-repeats](https://jovicailic.org/2018/03/vim-the-dot-command/) with NeoVim.

*   It can pick up a variable name from under the cursor.

*   It provides keymappings for visual mode, so you can select a variable
    visually and print it out.

*   It provides keymappings for operator-pending mode, so you can select a
    variable using a motion.

*   It indents the lines it inserts more accurately.

*   The output when printing a 'plain' debug line, or a variable, is more
    consistent.

*   Able to optionally move to the inserted line (or not).

## Demo

<div align="center">
  <video src="https://user-images.githubusercontent.com/107015/184187236-34f80a31-9626-4a3b-8d03-0f52752781e6.mp4" type="video/mp4"></video>
</div>

(This demo is not yet updated to show automatically picking up a variable name
from under the cursor, and uses old keybindings - the new ones are `g?p`, `g?P`,
`g?v` and `g?V`).

## Installation

**Requires NeoVim 0.7+.**

Optional dependency:
[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter). If this
is not installed, `debugprint` will not find variable names under the cursor and
will always prompt for a variable name.

Example for [`packer.nvim`](https://github.com/wbthomason/packer.nvim):

```lua
packer.startup(function(use)

    ...

    use({
        "andrewferrier/debugprint.nvim",
        config = function()
            require("debugprint").setup()
        end,
    })

    ...

end)
```

Note that you can add an `opts` object to the setup method:

```lua
opts = { ... }

...
require("debugprint").setup(opts)
...
})
```

The sections below detail the allowed options.

Please subscribe to [this GitHub issue](https://github.com/andrewferrier/debugprint.nvim/issues/25),
especially while `debugprint` is still in active development, to be notified of
any breaking issues.

## Keymappings

By default, the plugin will create some keymappings, which are the standard way
to use it. There are also some function invocations which are not mapped to any
keymappings by default, but could be. This is all shown in the following table.

| Mode             | Keymap          | Purpose                                                                                                                           | Equivalent Lua Function                                                                       |
| ---------------- | --------------- | --------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| Normal           | `g?p`           | Insert a 'plain' debug line appropriate to the filetype just below the current line                                               | `require('debugprint').debugprint()`                                                          |
| Normal           | `g?P`           | The same, but above the current line                                                                                              | `require('debugprint').debugprint({above = true})`                                            |
| Normal           | `g?v`           | Insert a variable debugging line below the current line. If the cursor is on a variable name, use that, otherwise prompt for one. | `require('debugprint').debugprint({variable = true})`                                         |
| Normal           | `g?V`           | The same, but above the current line                                                                                              | `require('debugprint').debugprint({above = true, variable = true})`                           |
| Normal           | None by default | Always prompt for a variable name, and insert a debugging line just below the current line which outputs it                       | `require('debugprint').debugprint({ignore_treesitter = true, variable = true})`               |
| Normal           | None by default | Always prompt for a variable name, and insert a debugging line just above the current line which outputs it                       | `require('debugprint').debugprint({ignore_treesitter = true, above = true, variable = true})` |
| Visual           | `g?v`           | Find the visually select variable name, and insert a debugging line just below the current line which outputs it                  | `require('debugprint').debugprint({variable = true})`                                         |
| Visual           | `g?v`           | Find the visually select variable name, and insert a debugging line just below the current line which outputs it                  | `require('debugprint').debugprint({variable = true})`                                         |
| Operator-pending | `g?o`           | Locate a variable using a motion, and insert a debugging line just above the current line which outputs it                        | `require('debugprint').debugprint({above = true, variable = true})`                           |
| Operator-pending | `g?O`           | Locate a variable using a motion, and insert a debugging line just above the current line which outputs it                        | `require('debugprint').debugprint({above = true, variable = true})`                           |

These keybindings are chosen specifically because by default in NeoVim they are
used to convert sections to ROT-13, which most folks don't use. You can disable
them from being created by setting `create_keymaps`, and map them yourself to
something else if you prefer:

```lua
opts = {
    create_keymaps = false
    ...
}

require("debugprint").setup(opts)

vim.keymap.set("n", "<Leader>d", function()
    require('debugprint').debugprint()
end)
vim.keymap.set("n", "<Leader>D", function()
    require('debugprint').debugprint({ above = true })
end)
vim.keymap.set("n", "<Leader>dq", function()
    require('debugprint').debugprint({ variable = true })
end)
vim.keymap.set("n", "<Leader>Dq", function()
    require('debugprint').debugprint({ above = true, variable = true })
end)
...
```

## Other Options

`debugprint` supports the following options in its global `opts` object:

| Option              | Default      | Purpose                                                                                                                                      |
| ------------------- | ------------ | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `create_keymaps`    | `true`       | Creates default keymappings - see above                                                                                                      |
| `move_to_debugline` | `false`      | When adding a debug line, moves the cursor to that line                                                                                      |
| `filetypes`         | See below    | Custom filetypes - see below                                                                                                                 |
| `ignore_treesitter` | `false`      | Never use treesitter to find a variable under the cursor, always prompt for it - overrides the same setting on `debugprint()` if set to true |
| `print_tag`         | `DEBUGPRINT` | The string inserted into each print statement, which can be used to uniquely identify statements inserted by `debugprint`.                   |

## Add Custom Filetypes

*Note: Since `debugprint.nvim` is still relatively new,
if you work out a configuration for a filetype not listed here, particularly a
standard or common one that NeoVim supports out-of-the-box, it would be really
appreciated if you can open an
[issue](https://github.com/andrewferrier/debugprint.nvim/issues/new) to have it
supported out-of-the-box in `debugprint` so others can benefit from it.
Similarly, if you spot any issues with, or improvements to, the language
configurations out-of-the-box, please open an issue also.*

`debugprint` supports the following filetypes out-of-the-box:

*   `bash`
*   `c`
*   `cpp` (C++)
*   `go`
*   `javascript`
*   `lua`
*   `make`
*   `python`
*   `ruby`
*   `rust`
*   `sh` (Sh/Bash)
*   `typescript`
*   `vim`
*   `zsh`

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

## Planned Future Improvements

*   Provide a semi-automated way to get rid of all debugging lines
    ([issue](https://github.com/andrewferrier/debugprint.nvim/issues/14))

*   Dynamically adapt filetype for embedded languages (e.g. code embedded in
    Markdown)
    ([issue](https://github.com/andrewferrier/debugprint.nvim/issues/9))

## Known Limitations

*   `debugprint` only supports variable names or simple expressions when using
    `g?v`/`g?V` - in particular, it does not make any attempt to escape
    expressions, and may generate invalid syntax if you try to be too clever.
    There's [an issue to look at ways of improving
    this](https://github.com/andrewferrier/debugprint.nvim/issues/20).

## Alternatives / Competitors

*   [refactoring.nvim](https://github.com/ThePrimeagen/refactoring.nvim) -
    similar capabilities to debugprint, supports a slighter smaller set of
    languages. Can remove added statement - this is on the debugprint roadmap.

*   [logsitter](https://github.com/gaelph/logsitter.nvim) - supports a smaller
    set of languages and requires you to set up your own autocmds/keymappings.
