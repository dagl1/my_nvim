;; inherits: python
;; !clear

;; Module-level docstring
(module . (expression_statement (string)) @fold)

;; Functie docstring
(function_definition
  body: (block . (expression_statement (string)) @fold))

;; Klasse docstring
(class_definition
  body: (block . (expression_statement (string)) @fold))
