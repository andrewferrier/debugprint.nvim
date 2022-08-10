# debugprint.nvim

## Purpose

The gold standard for debugging a program or script is to use a real debugger.
For NeoVim, the 'standard' way to integrate this is to use something like
[nvim-dap](https://github.com/mfussenegger/nvim-dap). However, many folks prefer
a more low-tech approach; the 'print' statement, or the equivalent in a
particular language, to trace the output of a program during execution.
`debugprint` is a NeoVim plugin for them, as it can generate 'print' statements
appropriate to the language being edited, which include the filename/line number
they are being inserted on, a counter which increases over the duration of a
NeoVim session each time a statement is generated, as well as optionally
printing out a variable.

`debugprint` is inspired by
[vim-debugstring](https://github.com/bergercookie/vim-debugstring), which I've
used for several years, but is updated and refreshed for the NeoVim generation.
It provides various improvements:

*   Its configuration system is more 'NeoVim-like' and it is easier to add custom
    languages in your configuration.

*   [*To be
    implemented*](https://github.com/andrewferrier/debugprint.nvim/issues/3): It
    dot-repeats with NeoVim.

*   It indents the lines it inserts more accurately.

*   The output when printing a 'plain' debug line, or a variable, is more
    consistent.

*   Able to optionally move to the inserted line (or not).

## Installation

**Requires NeoVim 0.7+.**

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

## Modifying the Default Behaviour

You can add an `opts` object to the setup method:

```lua
opts = { ... }

use({
    "andrewferrier/debugprint.nvim",
    config = function()
        require("debugprint").setup(opts)
    end,
})
```

The sections below detail the allowed options.

### Keymappings

By default, the plugin will create the following keymappings:

| Keymap | Purpose                                                                                              | Equivalent Lua Function                                             |
| ------ | ---------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| `dqp`  | Insert a 'plain' debug line appropriate to the filetype just below the current line                  | `require('debugprint').debugprint()`                                |
| `dqP`  | The same, but above the current line                                                                 | `require('debugprint').debugprint({above = true})`                  |
| `dQP`  | Prompt for a variable name, and insert a debugging line just below the current line which outputs it | `require('debugprint').debugprint({variable = true})`               |
| `dQP`  | The same, but above the current line                                                                 | `require('debugprint').debugprint({above = true, variable = true})` |

These keybindings are chosen not to conflict with any standard Vim keys (or any
common plugins, at least that I'm aware of). You can disable them from being
created by setting `create_keymaps`, and map them yourself to something else if
you prefer:

```lua
opts = {
    create_keymaps = false
    ...
}

require("debugprint").setup(opts)

vim.keymap.set("n", "<Leader>d", function()
    require('debugprint').debugprint()
end)
...
```

### Other Options

<span style="color:red">TODO: `move_to_debugline`</span>

### Add Custom Filetypes

<span style="color:red">TODO</span>

## Known Limitations

*   `debugprint` only supports variable names or simple expressions when
    using `dQp` - in particular, it does not make any attempt to escape
    expressions, and may generate invalid syntax if you try to be too clever.
    There's [an issue to look at ways of improving
    this](https://github.com/andrewferrier/debugprint.nvim/issues/20).
