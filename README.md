# Code Lexer
[![Gem Version](https://badge.fury.io/rb/code-lexer.svg)](https://badge.fury.io/rb/code-lexer)

This gems allows to tokenize any programming language through a simple specification file.

## Install
To install the latest version, simply run the following command

```
gem install code-lexer
```
hi...  
## Examples

```ruby
js_lexer = CodeLexer.get("javascript")
js_lexer.lex("return 0;").token_stream # → "return ¬·¬ 0 ;"

abstractor = CodeLexer::Abstractor.new.remove_spaces.abstract_identifiers
js_lexer.lex("a = b + c + b").token_stream(abstractor) # → "¬ID1¬ = ¬ID2¬ + ¬ID3¬ + ¬ID2¬"
abstractor.dictionary # → ["a", "b", "c"]
```
