-- See https://luals.github.io/wiki/annotations/

---@meta types

---@class debugprint.FileTypeConfig
---@field left string
---@field right string
---@field mid_var string
---@field right_var string
---@field find_treesitter_variable? function(node:TSNode):string
---@field display_counter? boolean|function():string
---@field display_location? boolean
---@field display_snippet? boolean

---@class debugprint.FileTypeConfigParams
---@field effective_filetypes string[]
---@field file_path string
---@field bufnr integer

---@alias debugprint.FileTypeConfigOrDynamic debugprint.FileTypeConfig |
---                                          function(debugprint.FileTypeConfigParams):debugprint.FileTypeConfig)

---@class debugprint.GlobalOptions
---@field keymaps? debugprint.KeymapOptions
---@field commands? debugprint.CommandOptions
---@field display_counter? boolean|function():string
---@field display_location? boolean
---@field display_snippet? boolean
---@field move_to_debugline? boolean
---@field notify_for_registers? boolean
---@field highlight_lines? boolean
---@field filetypes? debugprint.FileTypeConfigOrDynamic[]
---@field print_tag? string
---Deprecated
---@field create_keymaps? boolean
---@field create_commands? boolean
---@field ignore_treesitter? boolean

---@class debugprint.KeymapOptions
---@field normal? debugprint.KeymapNormalOptions
---@field insert? debugprint.KeymapInsertOptions
---@field visual? debugprint.KeymapVisualOptions

---@class debugprint.KeymapNormalOptions
---@field plain_below? string|false
---@field plain_above? string|false
---@field variable_below? string|false
---@field variable_above? string|false
---@field variable_below_alwaysprompt? string|false
---@field variable_above_alwaysprompt? string|false
---@field surround_plain? string|false
---@field surround_variable? string|false
---@field surround_variable_alwaysprompt? string|false
---@field textobj_below? string|false
---@field textobj_above? string|false
---@field textobj_surround? string|false
---@field delete_debug_prints? string|false
---@field toggle_comment_debug_prints? string|false

---@class debugprint.KeymapInsertOptions
---@field plain? string|false
---@field variable? string|false

---@class debugprint.KeymapVisualOptions
---@field variable_below? string|false
---@field variable_above? string|false

---@class debugprint.CommandOptions
---@field delete_debug_prints? string|false
---@field toggle_comment_debug_prints? string|false
---@field reset_debug_prints_counter? string|false

---@class debugprint.FunctionOptions
---@field above? boolean
---@field variable? boolean
---@field ignore_treesitter? boolean
---@field insert? boolean
---@field motion? boolean
---@field surround? boolean

---@class debugprint.FunctionOptionsInternal: debugprint.FunctionOptions
---@field variable_name? string
---@field register? string

---@class debugprint.CommandOpts
---@field line1 integer
---@field line2 integer
---@field range 1|2
