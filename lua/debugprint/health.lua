local M = {}

M.check = function()
    vim.health.start("debugprint.nvim report")

    local global_opts = require("debugprint")._get_global_opts()

    if global_opts ~= nil then
        vim.health.ok("debugprint has been set up")

        local success_lazyconfig, module_lazyconfig =
            pcall(require, "lazy.core.config")

        if success_lazyconfig then
            local plugin = module_lazyconfig.spec.plugins["debugprint.nvim"]

            if
                plugin
                and global_opts.print_tag ~= nil
                and global_opts.print_tag ~= ""
            then
                if plugin.lazy then
                    vim.health.warn(
                        "print_tag is set, but plugin is lazy-loaded, this won't highlight the lines correctly"
                    )
                else
                    vim.health.ok(
                        "print_tag is set and plugin is not lazy-loaded, "
                            .. "lines will be highlighted if mini.hipatterns is available"
                    )
                end
            end
        else
            vim.health.warn(
                "lazy.nvim is not being used as plugin manager, cannot check lazy-loading status"
            )
        end

        local success_hipatterns, module_hipatterns =
            pcall(require, "mini.hipatterns")

        if success_hipatterns and module_hipatterns then
            vim.health.ok(
                "mini.hipatterns is available and lines can be highlighted"
            )
        else
            vim.health.warn(
                "mini.hipatterns is not available; lines cannot be highlighted"
            )
        end
    else
        vim.health.warn(
            "debugprint is not yet setup, checkhealth cannot be run"
        )
    end
end

return M
