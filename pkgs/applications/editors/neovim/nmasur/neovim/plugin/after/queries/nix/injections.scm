expression: (apply_expression
  function: (apply_expression
    function: (select_expression
      attrpath: (attrpath) @writeshell (#match? @writeshell "^writeShell.*$")
      )
    )
  (indented_string_expression) @bash
)
