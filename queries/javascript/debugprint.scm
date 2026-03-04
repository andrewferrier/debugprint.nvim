; debugprint.nvim: captures for variable detection in javascript/javascriptreact
; Capture the whole member expression when cursor is on the property identifier
; (e.g. `x.abc` when cursor is on `abc`).
(member_expression
  property: (property_identifier)) @variable

; Capture plain identifiers.
(identifier) @variable
