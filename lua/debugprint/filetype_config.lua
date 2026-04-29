local M = {}

local utils = require("debugprint.utils")

---@param filetypes debugprint.FileTypeConfigOrDynamic[]
---@return debugprint.FileTypeConfig?
M.get = function(filetypes)
    local effective_filetypes = utils.get_effective_filetypes()
    local bufnr = vim.fn.bufnr()

    local params = {
        effective_filetypes = effective_filetypes,
        bufnr = bufnr,
        file_path = vim.api.nvim_buf_get_name(bufnr),
    }

    local config = {}
    local found_config = false

    for _, effective_filetype in ipairs(effective_filetypes) do
        ---@type debugprint.FileTypeConfigOrDynamic
        local entry = filetypes[effective_filetype]

        if entry ~= nil then
            found_config = true

            local filetype_contents = utils.resolve_value(entry, params)
            ---@cast filetype_contents debugprint.FileTypeConfig

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
