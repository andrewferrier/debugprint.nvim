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

You can use the packages [wat-inspector](https://pypi.org/project/wat-inspector/) to fully dump contents of objects when printing variables in Python. Use configuration that looks like this (you will need to `pip install wat-inspector` and then `import wat` in your script):

```lua
return {
    "andrewferrier/debugprint.nvim",
    opts = {
        filetypes = {
            ["python"] = {
                left_var = "print('",
                mid_var = "'); wat(",
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

## Use lazy-loading with lazy.nvim

`debugprint` can be configured, when using [lazy.nvim](https://github.com/folke/lazy.nvim) as a plugin manager, to lazy load itself. Use configuration that looks like this:

```lua
return {
    "andrewferrier/debugprint.nvim",

    -- opts = { … },

    -- The 'keys' and 'cmds' sections of this configuration will need to be adjusted if you
    -- customize the keys/commands.

    keys = {
        { "g?", mode = 'n' },
        { "g?", mode = 'x' },
        { "<C-G>", mode = 'i' },
    },
    cmd = {
        "ToggleCommentDebugPrints",
        "DeleteDebugPrints",
    },
}
```

## Restoring non-persistent `display_counter` counter

In older versions, `debugprint` used a `display_counter` which was only local to a particular NeoVim session; it was reset when exiting NeoVim and wasn't common between NeoVim sessions in different terminals. If you don't like the new 'persistent' counter, you can restore this old behaviour by setting a custom `display_counter`. This will recreate the old logic:

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
            "echasnovski/mini.nvim" -- Needed for :ToggleCommentDebugPrints (not needed for NeoVim 0.10+)
        }
    })
    …
end)
```

Example for [`mini.deps`](https://github.com/echasnovski/mini.nvim):

```lua
add({
    source = 'andrewferrier/debugprint.nvim',
    depends = { 'echasnovski/mini.nvim' }, -- Needed for :ToggleCommentDebugPrints (not needed for NeoVim 0.10+)
})
```
