local M = {}

---@class FileTypeConfig
---@field left string
---@field right string
---@field mid_var string
---@field right_var string
---@field find_treesitter_variable? function

---@class GlobalOptions
---@field keymaps? table
---@field commands? table
---@field display_counter? boolean
---@field display_snippet? boolean
---@field move_to_debugline? boolean
---@field ignore_treesitter? boolean
---@field filetypes? FileTypeConfig[]
---@field print_tag? string
---Deprecated
---@field create_keymaps? boolean
---@field create_commands? boolean

---@class FunctionOptions
---@field above boolean
---@field variable boolean
---@field ignore_treesitter boolean

---@class FunctionOptionsInternal: FunctionOptions
---@field motion? boolean
---@field prerepeat? boolean
---@field variable_name? string

---@class CommandOpts
---@field line1 integer
---@field line2 integer
---@field range 1|2

return M
