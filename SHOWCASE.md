# debugprint.nvim Configuration Showcase

Out of the box, `debugprint` provides a standard set of language configurations, but you may want to customize it or do something a bit different. This showcase is designed to collect together useful advanced tips, tricks, and changes to the `debugprint` configuration which may be useful.

## Modifying or Adding Filetypes

*Note: If you add a configuration for a filetype not supported out-of-the-box, or any issues or improvements for the ones that are, it would be appreciated if you can open an [issue](https://github.com/andrewferrier/debugprint.nvim/issues/new) to have it supported in `debugprint` so others can benefit.*

If `debugprint` doesn't support your filetype, you can add it as a custom filetype in one of two ways:

- In the `opts.filetypes` object in `setup()`.

- Using the `require('debugprint').add_custom_filetypes()` method (designed for use from `ftplugin/` directories, etc.)

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

Your new file format will be *merged* in with those that already exist. If you pass in a filetype with the same name as one that already exists, your configuration will override the built-in configuration.

The keys in the configuration are used like this:

| Debug line type     | Default keys            | How debug line is constructed                                                                                                                           |
| ------------------- | ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Plain debug line    | `g?p`/`g?P`             | `my_fileformat.left .. "auto-gen DEBUG string" .. my_fileformat.right`                                                                                  |
| Variable debug line | `g?v`/`g?V`/`g?o`/`g?O` | `my_fileformat.left_var (or my_fileformat.left) .. "auto-gen DEBUG string, variable=" .. my_file_format.mid_var .. variable .. my_fileformat.right_var` |

To see some examples, you can look at the [built-in configurations](lua/debugprint/filetypes.lua).

For more advanced use, there is also the fields `location` in the filetype configuration, but this is currently undocumented and unsupported for custom use.

### Dynamically creating filetype configurations

It is also possible to dynamically create filetype configurations by specifying filetype configurations as callback functions that pass back the contents of the table above, rather than the contents of the table directly. For example:

```lua
local my_fileformat = function(opts)
    -- Do some dynamic stuff to calculate my_left, my_right, my_mid_var etc...

    return {
        left = my_left,
        right = my_right,
        mid_var = my_mid_var,
        right_var = my_right
    }
end

require('debugprint').setup({ filetypes = { ["filetype"] = my_fileformat }})
```

The function you specify is invoked each time that a debug line is inserted. In the example above, `opts` is of type `DebugprintFileTypeFunctionParams`. This can be found documented in `lua/debugprint/types.lua`. This type is not stable and the contents are not guaranteed to stay the same between versions, although we'll try not to remove fields from it.

Further documentation on this technique is not provided as this is an advanced approach and is left for the user.

### Customizing Treesitter Variable Detection with Query Files

For some languages, `debugprint` uses Neovim's Treesitter integration to intelligently detect the variable under the cursor for variable debug lines. This detection is driven by Treesitter query files, which define patterns for different language grammars.

By default, `debugprint` looks for a query file named `debugprint.scm` within the `queries/<lang>/` directory for the active filetype's language. Some of these `debugprint.scm` files are supplied with and built into `debugprint.nvim`. For example, [this file](queries/c/debugprint.scm) is used for C files.

In these query files, patterns are defined to capture specific nodes in the Treesitter parse tree. The `@variable` capture is crucial: `debugprint` specifically looks for nodes captured as `@variable` to identify what it should consider a variable.

If there is no query file for a particular filetype, `debugprint` will fallback to the nearest detected Treesitter node, or failing that, it will prompt the user for a variable name, using intelligent defaults.

You can provide your own `debugprint.scm` query files to customize how `debugprint` detects variables for any language. These files should be placed in your Neovim configuration's runtime path (e.g. `~/.config/nvim`) under `queries/<lang>/debugprint.scm`. For instance, to customize variable detection for Java, you would create `queries/java/debugprint.scm`.

## Use `console.info()` rather than `console.warn()` for JavaScript/TypeScript

`debugprint` uses `console.warn()` by default for these languages ([explanation here](https://github.com/andrewferrier/debugprint.nvim/issues/72#issuecomment-1902469694)). However, some folks don't like this. You can change it to use `console.info()` instead like this:

```lua
local js_like = {
    left = 'console.info("',
    right = '")',
    mid_var = '", ',
    right_var = ")",
}

return {
    "andrewferrier/debugprint.nvim",
    opts = {
        filetypes = {
            ["javascript"] = js_like,
            ["javascriptreact"] = js_like,
            ["typescript"] = js_like,
            ["typescriptreact"] = js_like,
        },
    },
}
```

## Use `wat-inspector` to fully dump objects in Python

You can use the package [wat-inspector](https://pypi.org/project/wat-inspector/) to fully dump contents of objects when printing variables in Python. Use configuration that looks like this (you will need to `pip install wat-inspector`):

```lua
return {
    "andrewferrier/debugprint.nvim",
    opts = {
        filetypes = {
            ["python"] = {
                left_var = "print('",
                mid_var = "'); __import__('wat').wat(",
                right_var = ')',
            },
        },
    },
}
```

## Setting `display_*` options on per-filetype basis

The three `display_*` options [supported on a global basis](README.md#other-options) by `debugprint` can also be overridden on a per-filetype basis so you can show and hide differently for different filetypes. Filetypes without these set (which is the default for all filetypes) will continue to use the values set globally. Pass them into the `setup()` method or the `add_custom_filetypes()` method like this:

```lua
require('debugprint').setup({ filetypes = { ["filetype"] = { display_counter = false }}})
```

or

```lua
require('debugprint').add_custom_filetypes({ ["filetype"] = { display_counter = false }, … })
```

## Adding Timestamps to Debug Lines

When `display_timestamp = true` is set in your `setup()` configuration, `debugprint` will include a dynamically-generated local timestamp at the beginning of each debug line. The timestamp format is `hh:mm:ss.sss` (ISO-8601 time-only, with millisecond precision).

```lua
require('debugprint').setup({ display_timestamp = true })
```

This is supported out-of-the-box for a few common filetypes. For unsupported languages, the timestamp is silently omitted. For some languages, you may need to add dependencies or imports for the timestamp to work. This is left as an exercise for the user.

`display_timestamp` can also be set per-filetype using the same override mechanism as the other `display_*` options:

```lua
require('debugprint').setup({ filetypes = { ["lua"] = { display_timestamp = false } } })
```

### Adding Timestamp Support for Custom Filetypes

To add timestamp support to a custom or tweaked filetype, make `left` (and optionally `left_var`, `right`, `mid_var`, or `right_var`) a function instead of a plain string. The function receives a `debugprint.ConfigOpts` table with a `display_timestamp` boolean field, and returns the appropriate string:

```lua
local my_fileformat = {
    left = function(opts)
        if opts.display_timestamp then
            return 'myprint(my_timestamp_expr() + ": " + "'
        end
        return 'myprint("'
    end,
    right = '")',
    mid_var = '" + ',
    right_var = ')',
}
```

## Restoring non-persistent `display_counter` counter

In older versions, `debugprint` used a `display_counter` which was only local to a particular NeoVim session

```lua
local counter = 0

local counter_func = function()
    counter = counter + 1
    return '[' .. tostring(counter) .. ']'
end

debugprint.setup({display_counter = counter_func})
```

You can also set `display_counter` to any other function you wish.

## Using package managers other than lazy.nvim

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
            "nvim-mini/mini.nvim",         -- Optional: Needed for line highlighting (full mini.nvim plugin)
                                            -- ... or ...
            "nvim-mini/mini.hipatterns",   -- Optional: Needed for line highlighting ('fine-grained' hipatterns plugin)

            "ibhagwan/fzf-lua",              -- Optional: If you want to use the `:Debugprint search` command with fzf-lua
            "nvim-telescope/telescope.nvim", -- Optional: If you want to use the `:Debugprint search` command with telescope.nvim
            "folke/snacks.nvim",             -- Optional: If you want to use the `:Debugprint search` command with snacks.nvim
        }
    })
    …
end)
```

Example for [`mini.deps`](https://github.com/nvim-mini/mini.nvim):

```lua
add({
    source = 'andrewferrier/debugprint.nvim',
    depends = {
        "nvim-mini/mini.nvim",         -- Optional: Needed for line highlighting (full mini.nvim plugin)
                                        -- ... or ...
        "nvim-mini/mini.hipatterns",   -- Optional: Needed for line highlighting ('fine-grained' hipatterns plugin)

        "ibhagwan/fzf-lua",              -- Optional: If you want to use the `:Debugprint search` command with fzf-lua
        "nvim-telescope/telescope.nvim", -- Optional: If you want to use the `:Debugprint search` command with telescope.nvim
        "folke/snacks.nvim",             -- Optional: If you want to use the `:Debugprint search` command with snacks.nvim
    }
})
```

## Register Usage

Each of the standard keymappings (except the ones for insert mode) can be [prefixed with a register](https://neovim.io/doc/user/change.html#registers) in the same way as the standard 'y' (yank), 'd' (delete) keys, etc. When doing this, the content that would normally be inserted into the buffer is instead set into the register (lowercase register names) or appended to the register (uppercase register name). This means you can 'capture' several debugprint lines into a register, than insert them elsewhere in the buffer. This is particularly useful for 'variable' debugprint lines.

For example, given this buffer:

```lua
foo = 123
bar = 456
```

You can put your cursor on `foo`, and type `"ag?v`. Then put your cursor on `bar`, and type `"Ag?v`. Then you can move to the end of the buffer and type `"ap`. The end result will look like this:

```lua
foo = 123
bar = 456
print('DEBUGPRINT[1]: filename.lua:1: foo=' .. vim.inspect(foo))
print('DEBUGPRINT[2]: filename.lua:2: bar=' .. vim.inspect(bar))
```

The notifications that happen when you add content to a register can be disabled with the global [`notify_for_registers` option](README.md#other-options), should you wish.

## Highlighting Lines

By default, if and only if you have [mini.hipatterns](https://github.com/nvim-mini/mini.hipatterns) installed, `debugprint` will highlight lines that are inserted (strictly, it is highlighting lines that include the `print_tag` value). If you don't like this behaviour, you can disable it by setting the global `highlight_lines` option to `false`:

```lua
return {
    "andrewferrier/debugprint.nvim",
    opts = {
        highlight_lines = false
    }
}
```

You can customize the color of the highlighting used by customizing the `DebugPrintLine` highlight group (if you use a colorscheme plugin it may have a different way of customizing colours):

```lua
vim.api.nvim_set_hl(0, 'DebugPrintLine', { fg = "#ff0000", bg = "#333333" })
```

Note that if you use `lazy.nvim` or some other plugin manager that uses lazy-loading to load `debugprint`, the line highlighting will not work until you have used `debugprint` the first time (called `setup()`) and reloaded the current file. Switching off lazy-loading for `debugprint` is recommended.
