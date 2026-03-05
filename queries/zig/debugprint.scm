; debugprint.nvim: captures for variable detection in zig
; Capture field expressions (e.g. person.year) as a whole.
(field_expression) @variable

; Capture plain identifiers.
(identifier) @variable
