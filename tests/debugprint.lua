vim.o.hidden = true
vim.o.swapfile = false

-- These must be prepended because of this:
-- https://github.com/nvim-treesitter/nvim-treesitter/issues/3092#issue-1288690088
vim.opt.runtimepath:prepend(
    vim.fn.stdpath("data") .. "/site/pack/vendor/start/nvim-treesitter"
)
vim.opt.runtimepath:prepend("../nvim-treesitter")

vim.cmd("runtime! plugin/nvim-treesitter.lua")
vim.cmd("runtime! plugin/filetypes.lua")

local install_parser_if_needed = function(filetype)
    local install = require("nvim-treesitter").install

    if install ~= nil and type(install) == "function" then
        -- Probably on new 'main' branch
        install(filetype):wait(300000)
    else
        if
            vim.tbl_contains(vim.tbl_keys(vim.fn.environ()), "GITHUB_WORKFLOW")
        then
            print("Running in GitHub; installing parser " .. filetype .. "...")
            vim.cmd("TSInstallSync! " .. filetype)
        else
            vim.cmd("new")
            vim.cmd("only")
            local ok, _ = pcall(vim.treesitter.get_parser, 0, filetype, {})
            if not ok then
                print(
                    "Cannot load parser for " .. filetype .. ", installing..."
                )
                vim.cmd("TSInstallSync! " .. filetype)
            end
        end
    end
end

install_parser_if_needed("bash")
install_parser_if_needed("html")
install_parser_if_needed("javascript")
install_parser_if_needed("lua")
install_parser_if_needed("markdown")
install_parser_if_needed("markdown_inline")
install_parser_if_needed("php")
install_parser_if_needed("python")

local current_lua_file = debug.getinfo(1, "S").source:sub(2)
local current_dir = vim.fn.fnamemodify(current_lua_file, ":h")
local scan = vim.loop.fs_scandir(current_dir .. "/specs")

while true do
    ---@diagnostic disable-next-line: param-type-mismatch
    local name, typ = vim.loop.fs_scandir_next(scan)
    if not name then
        break
    end

    if typ == "file" and name:match("%.lua$") then
        require("tests.specs." .. name:gsub("%.lua$", ""))
    end
end
