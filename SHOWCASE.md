# debugprint.nvim Configuration Showcase

Out of the box, `debugprint` provides a standard set of language configurations, but you may want to customize it or do something a bit different. This showcase is designed to collect together useful advanced tips, tricks, and changes to the `debugprint` configuration which may be useful.

## Modifying or Adding Filetypes

*Note: If you add a configuration for a filetype not supported out-of-the-box, or any issues or improvements for the ones that are, it would be appreciated if you can open an [issue](https://github.com/andrewferrier/debugprint.nvim/issues/new) to have it supported in `debugprint` so others can benefit.*

If `debugprint` doesn't support your filetype, you can add it as a custom filetype in one of two ways:

*   In the `opts.filetypes` object in `setup()`.

*   Using the `require('debugprint').add_custom_filetypes()` method (designed for use from `ftplugin/` directories, etc.)

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

## Use lazy-loading with lazy.nvim

`debugprint` can be configured, when using [lazy.nvim](https://github.com/folke/lazy.nvim) as a plugin manager, to lazy load itself. Use configuration that looks like this:

```lua
return {
    "andrewferrier/debugprint.nvim",

    -- opts = { … },

    -- The 'keys' and 'cmds' sections of this configuration will need to be changed if you
    -- customize the keys/commands.

    keys = {
        { "g?", mode = 'n' },
        { "g?", mode = 'x' },
    },
    cmd = {
        "ToggleCommentDebugPrints",
        "DeleteDebugPrints",
    },
}
```

## Use a custom `display_counter` counter

The `display_counter` option can be set to a custom callback function to implement custom counter logic. In this case you are responsible for implementing your own counter. For example, this logic will implement essentially the same as the default counter:

```lua
local counter = 0

local counter_func = function()
    counter = counter + 1
    return '[' .. tostring(counter) .. ']'
end

debugprint.setup({display_counter = counter_func})
```
