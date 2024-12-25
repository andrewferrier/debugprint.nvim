-- For most of these default configurations, debugprint.nvim aims to log at a
-- 'debug'-style level of logging. For more console-oriented languages (e.g.
-- shell), it logs to stderr, as this is often a standard way of producing
-- output which isn't part of the main program. In some cases, however, it
-- deviates from these principles, in particular to avoid the user of debugprint
-- having to modify their imports to make sure the statements can be
-- added/removed standalone, or to ensure that the statements are visible by
-- default. Explanations are given below in comments below in some cases.

---@type DebugprintFileTypeConfig
local shell = {
    left = '>&2 echo "',
    right = '"',
    mid_var = "${",
    right_var = '}"',
    ---@param node TSNode
    find_treesitter_variable = function(node)
        if node:type() == "variable_name" then
            return vim.treesitter.get_node_text(node, 0)
        else
            return nil
        end
    end,
}

local docker = vim.deepcopy(shell)

docker.left = "RUN " .. docker.left

-- Use console.warn() rather than console.debug() so that messages are visible
-- by default in browser consoles. console.warn() will send to stderr with
-- NodeJS. See
-- https://github.com/andrewferrier/debugprint.nvim/issues/72#issuecomment-1902469694
-- for some other discussion on this.
---@type DebugprintFileTypeConfig
local js = {
    left = 'console.warn("',
    right = '")',
    mid_var = '", ',
    right_var = ")",
    ---@param node TSNode
    find_treesitter_variable = function(node)
        if node:type() == "property_identifier" and node:parent() ~= nil then
            local parent = node:parent()
            ---@cast parent TSNode
            return vim.treesitter.get_node_text(parent, 0)
        elseif node:type() == "identifier" then
            return vim.treesitter.get_node_text(node, 0)
        else
            return nil
        end
    end,
}

---@type DebugprintFileTypeConfig
local cs = {
    left = 'System.Console.Error.WriteLine($"',
    right = '");',
    mid_var = "{",
    right_var = '}");',
}

---@type DebugprintFileTypeConfig[]
return {
    ["apex"] = {
        left = "System.debug('",
        right = "');",
        mid_var = "' + ",
        right_var = ");",
    },
    ["applescript"] = {
        left = 'log "',
        right = '"',
        mid_var = '" & ',
        right_var = "",
    },
    ["bash"] = shell,
    ["c"] = {
        left = 'fprintf(stderr, "',
        right = '\\n");',
        mid_var = function()
            local d_fmt = '%d\\n", '
            local s_fmt = '%s\\n", '

            local lsp = vim.lsp
            local client = lsp.get_clients({ bufnr = 0, name = "clangd" })[1]
            if not client then
                return d_fmt
            end

            local res, err = client:request_sync(
                lsp.protocol.Methods.textDocument_hover,
                lsp.util.make_position_params(
                    vim.api.nvim_get_current_win(),
                    client.offset_encoding
                ),
                1000
            )

            if err or not res then
                return d_fmt
            end

            local content = vim.tbl_get(res, "result", "contents", "value")
            if not content then
                return d_fmt
            end

            local typeinfo = content:match("### variable.-\nType: `(.-)`")
                or content:match("### field.-\nType: `(.-)`")
                or content:match("### param.-\nType: `(.-)`")
            if
                typeinfo
                and (typeinfo:find("char %*") or typeinfo:find("char const%*"))
            then
                return s_fmt
            end
            return d_fmt
        end,
        right_var = ");",
        find_treesitter_variable = function(node)
            if node:type() == "field_expression" then
                return vim.treesitter.get_node_text(node, 0)
            elseif
                node:parent()
                and node:parent():type() == "field_expression"
                and node:prev_named_sibling()
            then
                return vim.treesitter.get_node_text(node:parent(), 0)
            elseif node:type() == "identifier" then
                return vim.treesitter.get_node_text(node, 0)
            else
                return nil
            end
        end,
    },
    ["cmake"] = {
        left = 'message(DEBUG "',
        right = '")',
        mid_var = "${",
        right_var = '}")',
    },
    ["cobol"] = {
        left = 'DISPLAY "',
        right = '".',
        mid_var = '" ',
        right_var = ".",
    },
    ["cpp"] = {
        left = 'std::cerr << "',
        right = '" << std::endl;',
        mid_var = '" << ',
        right_var = " << std::endl;",
    },
    ["cs"] = cs,
    ["c_sharp"] = cs,
    ["dart"] = {
        left = 'print("',
        right = '");',
        mid_var = "${",
        right_var = '}");',
    },
    ["dockerfile"] = docker,
    ["dosbatch"] = {
        left = 'echo "',
        right = '" 1>&2',
        mid_var = "%",
        right_var = '%" 1>&2',
    },
    ["elixir"] = {
        left = 'IO.puts :stderr, "',
        right = '"',
        mid_var = "#{inspect(",
        right_var = ')}"',
    },
    ["fish"] = {
        left = 'echo "',
        right = '" 1>&2',
        mid_var = "$",
        right_var = '" 1>&2',
    },
    ["fortran"] = {
        left = "print *, '",
        right = "'",
        mid_var = "', ",
        right_var = "",
    },
    ["go"] = {
        left = 'fmt.Fprintf(os.Stderr, "',
        right = '\\n")',
        mid_var = '%+v\\n", ',
        right_var = ")",
    },
    ["haskell"] = {
        left = 'putStrLn "',
        right = '"',
        mid_var = '" ++ ',
        right_var = "",
    },
    ["java"] = {
        left = 'System.err.println("',
        right = '");',
        mid_var = '" + ',
        right_var = ");",
    },
    ["javascript"] = js,
    ["javascriptreact"] = js,
    ["kotlin"] = {
        left = 'println("',
        right = '")',
        mid_var = "$",
        right_var = '")',
    },
    ["lean"] = {
        left = 'dbg_trace s!"',
        right = '"',
        mid_var = "{",
        right_var = '}"',
    },
    ["lisp"] = {
        left = '(format t "',
        right = '")',
        mid_var = '~D" ',
        right_var = ")",
    },
    ["lua"] = {
        left = "print('",
        right = "')",
        mid_var = "' .. vim.inspect(",
        right_var = "))",
        ---@param node TSNode
        find_treesitter_variable = function(node)
            if node:type() == "dot_index_expression" then
                return vim.treesitter.get_node_text(node, 0)
            elseif
                node:parent()
                and node:parent():type() == "dot_index_expression"
                and node:prev_named_sibling()
            then
                local parent = node:parent()
                ---@cast parent TSNode
                return vim.treesitter.get_node_text(parent, 0)
            elseif node:type() == "identifier" then
                return vim.treesitter.get_node_text(node, 0)
            else
                return nil
            end
        end,
    },
    ["make"] = {
        left = '\t@echo >&2 "',
        right = '"',
        mid_var = '"$(',
        right_var = ")",
    },
    ["perl"] = {
        left = 'print STDERR "',
        right = '\\n";',
        mid_var = "$",
        right_var = '\\n";',
    },
    ["php"] = {
        left = 'fwrite(STDERR, "',
        right = '\\n");',
        mid_var = "$",
        right_var = '\\n");',
    },
    ["ps1"] = {
        left = 'Write-Error "',
        right = '"',
        mid_var = "$",
        right_var = '"',
    },
    -- Don't print to stderr by default, because it requires 'import sys'
    ["python"] = {
        left = 'print("',
        left_var = 'print(f"',
        right = '")',
        mid_var = "{",
        right_var = '}")',
    },
    ["r"] = {
        left = 'cat(paste("',
        right = '"), file=stderr())',
        mid_var = '", ',
        right_var = "), file=stderr())",
    },
    ["ruby"] = {
        left = 'STDERR.puts "',
        right = '"',
        mid_var = "#{",
        right_var = '}"',
    },
    ["rust"] = {
        left = 'eprintln!("',
        right = '");',
        mid_var = '{:#?}", ',
        right_var = ");",
    },
    ["sh"] = shell,
    ["swift"] = {
        left = 'debugPrint("',
        right = '")',
        mid_var = "\\(",
        right_var = ')")',
    },
    ["svelte"] = js,
    ["tcl"] = {
        left = 'puts "',
        right = '"',
        mid_var = "$",
        right_var = '"',
    },
    ["typescript"] = js,
    ["typescriptreact"] = js,
    ["vim"] = {
        left = 'echo "',
        right = '"',
        mid_var = '" .. ',
        right_var = "",
    },
    ["vue"] = js,
    ["zig"] = {
        left = 'std.debug.print("',
        right = '\\n", .{});',
        mid_var = '{any}\\n", .{',
        right_var = "});",
    },
    ["zsh"] = shell,
}
