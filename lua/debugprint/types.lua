-- See https://luals.github.io/wiki/annotations/

---@meta types

---@class DebugprintFileTypeConfig
---@field left string
---@field right string
---@field mid_var string
---@field right_var string
---@field find_treesitter_variable? function
---@field display_counter? boolean|function
---@field display_location? boolean
---@field display_snippet? boolean

---@class DebugprintGlobalOptions
---@field keymaps? DebugprintKeymapOptions
---@field commands? DebugprintCommandOptions
---@field display_counter? boolean|function
---@field display_location? boolean
---@field display_snippet? boolean
---@field move_to_debugline? boolean
---@field notify_for_registers? boolean
---@field filetypes? DebugprintFileTypeConfig[]
---@field print_tag? string
---Deprecated
---@field create_keymaps? boolean
---@field create_commands? boolean
---@field ignore_treesitter? boolean

---@class DebugprintKeymapOptions
---@field normal? DebugprintKeymapNormalOptions
---@field insert? DebugprintKeymapInsertOptions
---@field visual? DebugprintKeymapVisualOptions

---@class DebugprintKeymapNormalOptions
---@field plain_below? string|false
---@field plain_above? string|false
---@field variable_below? string|false
---@field variable_above? string|false
---@field variable_below_alwaysprompt? string|false
---@field variable_above_alwaysprompt? string|false
---@field textobj_below? string|false
---@field textobj_above? string|false
---@field delete_debug_prints? string|false
---@field toggle_comment_debug_prints? string|false

---@class DebugprintKeymapInsertOptions
---@field plain? string|false
---@field variable? string|false

---@class DebugprintKeymapVisualOptions
---@field variable_below? string|false
---@field variable_above? string|false

---@class DebugprintCommandOptions
---@field delete_debug_prints? string|false
---@field toggle_comment_debug_prints? string|false
---@field reset_debug_prints_counter? string|false

---@class DebugprintFunctionOptions
---@field above? boolean
---@field variable? boolean
---@field ignore_treesitter? boolean
---@field insert? boolean
---@field motion? boolean

---@class DebugprintFunctionOptionsInternal: DebugprintFunctionOptions
---@field variable_name? string
---@field register? string

---@class DebugprintCommandOpts
---@field line1 integer
---@field line2 integer
---@field range 1|2
