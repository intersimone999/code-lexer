require_relative File.expand_path("../../lib/code-lexer", __FILE__)
require 'rspec/autorun'

describe CodeLexer::Lexer do
    it "should correctly parse a simple text" do
        lexer = CodeLexer::Lexer.new("#{File.dirname(File.expand_path($0))}/test_folder/javascript.yml")
        lexed = lexer.lex("if (a == b) return 0;")
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
            CodeLexer::Token.new(:number, "0"),
            CodeLexer::Token.new(:semicolon, ";"),
        ]
        expect(lexed.tokens).to eq expected_tokens
    end
end

describe CodeLexer::LexedContent do
    it "should correctly return a token stream without abstractor" do
        tokens = [
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
            CodeLexer::Token.new(:number, "0"),
            CodeLexer::Token.new(:semicolon, ";"),
        ]
        
        content = CodeLexer::LexedContent.new(tokens)
        
        expect(content.token_stream(nil)).to eq "if ¬·¬ ( a ¬·¬ == ¬·¬ b ) ¬·¬ return ¬·¬ 0 ;"
    end
    
    it "should correctly return a token stream with abstractor" do
        tokens = [
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
            CodeLexer::Token.new(:number, "0"),
            CodeLexer::Token.new(:semicolon, ";"),
        ]
        
        content = CodeLexer::LexedContent.new(tokens)
        abstractor = CodeLexer::Abstractor.new.remove_spaces.abstract_identifiers
        
        expect(content.token_stream(abstractor)).to eq "if ( ¬ID1¬ == ¬ID2¬ ) return 0 ;"
    end
    
    it "should correctly return token lines" do
        tokens = [
            CodeLexer::Token.new(:keyword, "if"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:parenthesis, "("),
            CodeLexer::Token.new(:identifier, "a"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:operator, "=="),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:identifier, "b"),
            CodeLexer::Token.new(:parenthesis, ")"),
            CodeLexer::Token.new(:newline, "\n"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:keyword, "return"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:number, "0"),
            CodeLexer::Token.new(:newline, "\n"),
            CodeLexer::Token.new(:semicolon, ";"),
        ]
        
        content = CodeLexer::LexedContent.new(tokens)
        lines = content.token_lines
        
        expect(lines.size).to eq 3
        expect(lines[0]).to eq tokens[0..8]
        expect(lines[1]).to eq tokens[10..13]
        expect(lines[2]).to eq [tokens[15]]
    end
    
    it "should correctly deabstract a simple abstracted sequence" do        
        abstractor = CodeLexer::Abstractor.new.abstract_everything
        abstractor.identifiers_dictionary << "a"
        abstractor.identifiers_dictionary << "b"
        abstractor.numbers_dictionary << "0"
        abstractor.strings_dictionary << "test"
        
        content = CodeLexer::LexedContent.from_stream_string(
            "if ¬WHITESPACE¬ ( ¬ID1¬ ¬WHITESPACE¬ == ¬WHITESPACE¬ ¬ID2¬ ¬WHITESPACE¬ && ¬WHITESPACE¬ ¬ID2¬ ¬WHITESPACE¬ != ¬WHITESPACE¬ ¬STRING¬ ) ¬WHITESPACE¬ return ¬WHITESPACE¬ ¬NUMBER¬ ;",
            abstractor
        )
        
        expected = [
            CodeLexer::Token.new(:unknown, "if"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:unknown, "("),
            CodeLexer::Token.new(:identifier, "a"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:unknown, "=="),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:identifier, "b"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:unknown, "&&"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:identifier, "b"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:unknown, "!="),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:string, "\"test\""),
            CodeLexer::Token.new(:unknown, ")"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:unknown, "return"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:number, "0"),
            CodeLexer::Token.new(:unknown, ";"),
        ]
        
        abstractor.abstract!(expected)
        
        expect(content.tokens).to eq expected
    end
    
    it "should correctly return a string representation" do        
        abstractor = CodeLexer::Abstractor.new.abstract_everything
        abstractor.identifiers_dictionary << "a"
        abstractor.identifiers_dictionary << "b"
        abstractor.numbers_dictionary << "0"
        abstractor.strings_dictionary << "test"
        
        content = CodeLexer::LexedContent.from_stream_string(
            "if ¬WHITESPACE¬ ( ¬ID1¬ ¬WHITESPACE¬ == ¬WHITESPACE¬ ¬ID2¬ ¬WHITESPACE¬ && ¬WHITESPACE¬ ¬ID2¬ ¬WHITESPACE¬ != ¬WHITESPACE¬ ¬STRING¬ ) ¬WHITESPACE¬ return ¬WHITESPACE¬ ¬NUMBER¬ ;",
            abstractor
        )
        
        expected = 'if (a == b && b != "test") return 0;'
        
        expect(content.to_s).to eq expected
    end
end
 
