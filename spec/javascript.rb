require_relative File.expand_path("../../lib/code-lexer", __FILE__)
require 'rspec/autorun'

describe CodeLexer::Lexer do
    it "should correctly parse a simple text" do
        lexer = CodeLexer.get("javascript")
        lexed = lexer.lex("if (a == b) return 0.0;")
        expected_tokens = [
            CodeLexer::Token.new(:keyword, "if"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:parenthesis, "("),
            CodeLexer::Token.new(:identifier, "a"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:operator, "=="),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:identifier, "b"),
            CodeLexer::Token.new(:parenthesis, ")"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:keyword, "return"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:number, "0.0"),
            CodeLexer::Token.new(:semicolon, ";"),
        ]
        expect(lexed.tokens).to eq expected_tokens
    end
end
