# debugprint.nvim Configuration Showcase

Out of the box, `debugprint` provides a standard set of language configurations to provide 'print-like' logic for over 30 different languages.

However, you may not like the way this is configured for your language of choice. This showcase is designed to collect together useful variations to the `debugprint` configuration which may be useful.

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
    config = function()
        require("debugprint").setup({
            filetypes = {
               ["javascript"] = js_like,
               ["javascriptreact"] = js_like,
               ["typescript"] = js_like,
               ["typescriptreact"] = js_like,
            },
        })
     end,
     version = "*",
}
```
