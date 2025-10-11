-- For most of these default configurations, debugprint.nvim aims to log at a
-- 'debug'-style level of logging. For more console-oriented languages (e.g.
-- shell), it logs to stderr, as this is often a standard way of producing
-- output which isn't part of the main program. In some cases, however, it
-- deviates from these principles, in particular to avoid the user of debugprint
-- having to modify their imports to make sure the statements can be
-- added/removed standalone, or to ensure that the statements are visible by
-- default. Explanations are given below in comments below in some cases.

local ESCAPE_DOUBLE_QUOTES = function(variable_name)
    return string.gsub(variable_name, '"', '\\"')
end

local ESCAPE_SINGLE_QUOTES = function(variable_name)
    return string.gsub(variable_name, "'", "\\'")
end

---@type debugprint.FileTypeConfig
local shell = {
    left = '>&2 echo "',
    right = '"',
    mid_var = "${",
    right_var = '}"',
    location = "$0:$LINENO",
    ---@param node TSNode
    find_treesitter_variable = function(node)
        if node:type() == "variable_name" then
            return vim.treesitter.get_node_text(node, 0)
        else
            return nil
        end
    end,
    escape_variable_name = ESCAPE_DOUBLE_QUOTES,
}

local docker = vim.deepcopy(shell)

docker.left = "RUN " .. docker.left

-- Use console.warn() rather than console.debug() so that messages are visible
-- by default in browser consoles. console.warn() will send to stderr with
-- NodeJS. See
-- https://github.com/andrewferrier/debugprint.nvim/issues/72#issuecomment-1902469694
-- for some other discussion on this.
---@type debugprint.FileTypeConfig
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
    escape_variable_name = ESCAPE_DOUBLE_QUOTES,
}

---@type debugprint.FileTypeConfig
local cs = {
    left = 'System.Console.Error.WriteLine($"',
    right = '");',
    mid_var = "{",
    right_var = '}");',
}

---@type debugprint.FileTypeConfig
local lua = {
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
    escape_variable_name = ESCAPE_SINGLE_QUOTES,
}

---@type debugprint.FileTypeConfig
local ruby = {
    left = 'STDERR.puts "',
    right = '"',
    mid_var = "#{",
    right_var = '}"',
    escape_variable_name = ESCAPE_DOUBLE_QUOTES,
}

---@type debugprint.FileTypeConfig[]
return {
    ["apex"] = {
        left = "System.debug('",
        right = "');",
        mid_var = "' + ",
        right_var = ");",
    },
    ["astro"] = js,
    ["applescript"] = {
        left = 'log "',
        right = '"',
        mid_var = '" & ',
        right_var = "",
    },
    ["bash"] = shell,
    ["c"] = {
        left = 'fprintf(stderr, "',
        right = '\\n", __FILE__, __LINE__);',
        mid_var = '%d\\n", __FILE__, __LINE__, ',
        right_var = ");",
        location = "%s:%d",
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
        escape_variable_name = ESCAPE_DOUBLE_QUOTES,
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
        location = '" << __FILE__ << ":" << __LINE__ << "',
    },
    ["crystal"] = ruby,
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
        escape_variable_name = ESCAPE_DOUBLE_QUOTES,
    },
    ["fortran"] = {
        left = "print *, '",
        right = "'",
        mid_var = "', ",
        right_var = "",
    },
    ["gdscript"] = {
        left = 'print("',
        right = '")',
        mid_var = '" + str(',
        right_var = "))",
    },
    ["go"] = {
        left = 'fmt.Fprintf(os.Stderr, "',
        right = '\\n")',
        mid_var = '%+v\\n", ',
        right_var = ")",
        escape_variable_name = ESCAPE_DOUBLE_QUOTES,
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
        escape_variable_name = ESCAPE_DOUBLE_QUOTES,
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
    ["lua"] = lua,
    ["luau"] = lua,
    ["make"] = {
        left = '\t@echo >&2 "',
        right = '"',
        mid_var = '"$(',
        right_var = ")",
    },
    ["nim"] = {
        left = 'stderr.writeLine("',
        right = '")',
        mid_var = '" & ',
        right_var = ".repr)",
    },
    ["perl"] = {
        left = 'print STDERR "',
        right = '\\n";',
        mid_var = "$",
        right_var = '\\n";',
        location = '", __FILE__, ":", __LINE__, "',
    },
    ["php"] = {
        left = 'fwrite(STDERR, "',
        right = '\\n");',
        mid_var = "$",
        right_var = '\\n");',
        location = '" . __FILE__ . ":" . __LINE__ . "',
        escape_variable_name = ESCAPE_DOUBLE_QUOTES,
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
        escape_variable_name = ESCAPE_DOUBLE_QUOTES,
    },
    ["r"] = {
        left = 'cat(paste("',
        right = '"), file=stderr())',
        mid_var = '", ',
        right_var = "), file=stderr())",
    },
    ["ruby"] = ruby,
    ["rust"] = {
        left = 'eprintln!("',
        right = '", file!(), line!());',
        mid_var = '{:#?}", file!(), line!(), ',
        location = "{}:{}",
        right_var = ");",
        escape_variable_name = ESCAPE_DOUBLE_QUOTES,
    },
    ["sh"] = shell,
    ["swift"] = {
        left = 'debugPrint("',
        right = '")',
        mid_var = "\\(",
        right_var = ')")',
        location = "\\(#file):\\(#line)",
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
        right = '\\n", .{ @src().file, @src().line });',
        mid_var = '{any}\\n", .{ @src().file, @src().line, ',
        location = "{s}:{d}",
        right_var = " });",
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
    ["zsh"] = shell,
}
