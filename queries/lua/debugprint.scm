; debugprint.nvim: captures for variable detection in lua/luau
; Capture dot-index expressions (e.g. t.key) as a whole.
(dot_index_expression) @variable

; Capture plain identifiers.
(identifier) @variable
