local M = {}

local utils = require("debugprint.utils")

---@param fn function(DebugprintFileTypeConfigParams):DebugprintFileTypeConfig
---@return DebugprintFileTypeConfig
local get_function_wrapped_config = function(fn)
    local bufnr = vim.fn.bufnr()

    local result = fn({
        effective_filetypes = utils.get_effective_filetypes(),
        bufnr = bufnr,
        file_path = vim.api.nvim_buf_get_name(bufnr),
    })

    return result
end

---@param filetypes DebugprintFileTypeConfigOrDynamic[]
---@return DebugprintFileTypeConfig?
M.get = function(filetypes)
    local effective_filetypes = utils.get_effective_filetypes()
    local config = {}
    local found_config = false

    for _, effective_filetype in ipairs(effective_filetypes) do
        ---@type DebugprintFileTypeConfigOrDynamic
        local entry = filetypes[effective_filetype]

        if entry ~= nil then
            found_config = true

            local filetype_contents

            if type(entry) == "function" then
                filetype_contents = get_function_wrapped_config(entry)
            else
                filetype_contents = entry
            end
            ---@cast filetype_contents DebugprintFileTypeConfig

            -- Combine all valid configs into the same object. This seems to
            -- make sense as an approach; the only case where I've found where
            -- this applies so far is ["bash", "sh"]. If this causes problems we
            -- may need to come up with something more sophisticated.
            config = vim.tbl_deep_extend(
                "keep",
                vim.deepcopy(filetype_contents),
                config
            )
        end
    end

    if not found_config then
        return nil
    else
        return config
    end
end

return M
