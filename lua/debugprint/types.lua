-- See https://luals.github.io/wiki/annotations/

---@meta types

---@class DebugprintFileTypeConfig
---@field left string
---@field right string
---@field mid_var string
---@field right_var string
---@field find_treesitter_variable? function

---@class DebugprintGlobalOptions
---@field keymaps? DebugprintKeymapOptions
---@field commands? DebugprintCommandOptions
---@field display_counter? boolean|function
---@field display_location? boolean
---@field display_snippet? boolean
---@field move_to_debugline? boolean
---@field filetypes? DebugprintFileTypeConfig[]
---@field print_tag? string
---Deprecated
---@field create_keymaps? boolean
---@field create_commands? boolean
---@field ignore_treesitter? boolean

---@class DebugprintKeymapOptions
---@field normal? DebugprintKeymapNormalOptions
---@field visual? DebugprintKeymapVisualOptions

---@class DebugprintKeymapNormalOptions
---@field plain_below? string
---@field plain_above? string
---@field variable_below? string
---@field variable_above? string
---@field variable_below_alwaysprompt? string
---@field variable_above_alwaysprompt? string
---@field textobj_below? string
---@field textobj_above? string
---@field delete_debug_prints? string
---@field toggle_comment_debug_prints? string

---@class DebugprintKeymapVisualOptions
---@field variable_below? string
---@field variable_above? string

---@class DebugprintCommandOptions
---@field delete_debug_prints? string
---@field toggle_comment_debug_prints? string

---@class DebugprintFunctionOptions
---@field above? boolean
---@field variable? boolean
---@field ignore_treesitter? boolean

---@class DebugprintFunctionOptionsInternal: DebugprintFunctionOptions
---@field motion? boolean
---@field variable_name? string

---@class DebugprintCommandOpts
---@field line1 integer
---@field line2 integer
---@field range 1|2
