;; extends

; 1. Target commas specifically
"," @punctuation.comma

; 2. Target colons specifically
":" @punctuation.colon

; 3. Target semicolons specifically
";" @punctuation.semicolon

; 4. Target periods/dots specifically
"." @punctuation.delimiter.period

; target = 
"=" @punctuation.delimiter.equals

; "@" with priority as 110
("@" @punctuation.delimiter.at 
  (#set! priority 110))



; dunder / rexex
(function_definition
  name: (identifier) @variable.dunder
  (#match? @variable.dunder "^__.*__$")
  (#set! priority 150))

