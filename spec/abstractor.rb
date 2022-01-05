require_relative File.expand_path("../../lib/code-lexer", __FILE__)
require 'rspec/autorun'

describe CodeLexer::Abstractor do
    it "should correctly abstract identifiers" do
        sequence = [
            CodeLexer::Token.new(:keyword, "if"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:parenthesis, "("),
            CodeLexer::Token.new(:identifier, "t1"),
            CodeLexer::Token.new(:operator, "=="),
            CodeLexer::Token.new(:identifier, "t2"),
            CodeLexer::Token.new(:parenthesis, ")"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:keyword, "return"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:identifier, "t1"),
            CodeLexer::Token.new(:semicolon, ";")
        ]
        original_sequence = sequence.clone
        
        abstractor = CodeLexer::Abstractor.new.abstract_identifiers
        abstractor.abstract!(sequence)
        
        expect(sequence.select { |t| t.type != :identifier }).to eq(original_sequence.select { |t| t.type != :identifier })
        expect(sequence[3].abstracted_value).to eq CodeLexer::Token.special("ID1")
        expect(sequence[5].abstracted_value).to eq CodeLexer::Token.special("ID2")
        expect(sequence[10].abstracted_value).to eq CodeLexer::Token.special("ID1")
    end
    
    it "should correctly abstract identifiers by using a dictionary" do
        sequence = [
            CodeLexer::Token.new(:keyword, "if"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:parenthesis, "("),
            CodeLexer::Token.new(:identifier, "t1"),
            CodeLexer::Token.new(:operator, "=="),
            CodeLexer::Token.new(:identifier, "t2"),
            CodeLexer::Token.new(:parenthesis, ")"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:keyword, "return"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:identifier, "t1"),
            CodeLexer::Token.new(:semicolon, ";")
        ]
        original_sequence = sequence.clone
        
        abstractor = CodeLexer::Abstractor.new(['t2', 't1']).abstract_identifiers
        abstractor.abstract!(sequence)
        
        expect(sequence.select { |t| t.type != :identifier }).to eq(original_sequence.select { |t| t.type != :identifier })
        expect(sequence[3].abstracted_value).to eq CodeLexer::Token.special("ID2")
        expect(sequence[5].abstracted_value).to eq CodeLexer::Token.special("ID1")
        expect(sequence[10].abstracted_value).to eq CodeLexer::Token.special("ID2")
    end
    
    it "should correctly abstract numbers" do
        sequence = [
            CodeLexer::Token.new(:keyword, "if"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:parenthesis, "("),
            CodeLexer::Token.new(:identifier, "t1"),
            CodeLexer::Token.new(:operator, "=="),
            CodeLexer::Token.new(:number, "134"),
            CodeLexer::Token.new(:parenthesis, ")"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:keyword, "return"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:number, "3.5"),
            CodeLexer::Token.new(:semicolon, ";")
        ]
        original_sequence = sequence.clone
        
        abstractor = CodeLexer::Abstractor.new.abstract_numbers
        abstractor.abstract!(sequence)
        
        expect(sequence.select { |t| t.type != :number }).to eq(original_sequence.select { |t| t.type != :number })

        expect(sequence[5].abstracted_value).to eq CodeLexer::Token.special("NUMBER")
        expect(sequence[10].abstracted_value).to eq CodeLexer::Token.special("NUMBER")
    end
    
    it "should correctly abstract comments" do
        sequence = [
            CodeLexer::Token.new(:keyword, "if"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:parenthesis, "("),
            CodeLexer::Token.new(:identifier, "t1"),
            CodeLexer::Token.new(:operator, "=="),
            CodeLexer::Token.new(:number, "134"),
            CodeLexer::Token.new(:parenthesis, ")"),
            CodeLexer::Token.new(:comment, "//This is an inline comment"),
            CodeLexer::Token.new(:newline, "\r"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:keyword, "return"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:number, "3.5"),
            CodeLexer::Token.new(:semicolon, ";"),
            CodeLexer::Token.new(:comment, "/* this is a test comment */"),
        ]
        original_sequence = sequence.clone
        
        abstractor = CodeLexer::Abstractor.new.abstract_comments
        abstractor.abstract!(sequence)
        
        expect(sequence.select { |t| t.type != :comment }).to eq(original_sequence.select { |t| t.type != :comment })

        expect(sequence[7].abstracted_value).to eq CodeLexer::Token.special("COMMENT")
        expect(sequence[14].abstracted_value).to eq CodeLexer::Token.special("COMMENT")
    end
    
    it "should correctly abstract strings" do
        sequence = [
            CodeLexer::Token.new(:keyword, "if"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:parenthesis, "("),
            CodeLexer::Token.new(:identifier, "t1"),
            CodeLexer::Token.new(:operator, "=="),
            CodeLexer::Token.new(:string, "hello world"),
            CodeLexer::Token.new(:parenthesis, ")"),
            CodeLexer::Token.new(:comment, "//This is an inline comment"),
            CodeLexer::Token.new(:newline, "\r"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:keyword, "return"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:string, "test string two"),
            CodeLexer::Token.new(:semicolon, ";"),
            CodeLexer::Token.new(:comment, "/* this is a test comment */"),
        ]
        original_sequence = sequence.clone
        
        abstractor = CodeLexer::Abstractor.new.abstract_strings
        abstractor.abstract!(sequence)
        
        expect(sequence.select { |t| t.type != :string }).to eq(original_sequence.select { |t| t.type != :string })

        expect(sequence[5].abstracted_value).to eq CodeLexer::Token.special("STRING")
        expect(sequence[12].abstracted_value).to eq CodeLexer::Token.special("STRING")
    end
    
    it "should correctly abstract spaces" do
        sequence = [
            CodeLexer::Token.new(:keyword, "if"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:parenthesis, "("),
            CodeLexer::Token.new(:identifier, "t1"),
            CodeLexer::Token.new(:operator, "=="),
            CodeLexer::Token.new(:identifier, "t2"),
            CodeLexer::Token.new(:parenthesis, ")"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:keyword, "return"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:identifier, "t1"),
            CodeLexer::Token.new(:semicolon, ";"),
            CodeLexer::Token.new(:newline, "\n"),
            CodeLexer::Token.new(:space, "\t\t")
        ]
        original_sequence = sequence.clone
        
        abstractor = CodeLexer::Abstractor.new.abstract_spaces
        abstractor.abstract!(sequence)
        
        expect(sequence.select { |t| t.type != :space }).to eq(original_sequence.select { |t| t.type != :space })

        expect(sequence[1].abstracted_value).to eq CodeLexer::Token.special("WHITESPACE")
        expect(sequence[7].abstracted_value).to eq CodeLexer::Token.special("WHITESPACE")
        expect(sequence[9].abstracted_value).to eq CodeLexer::Token.special("WHITESPACE")
        expect(sequence[13].abstracted_value).to eq CodeLexer::Token.special("INDENTATION")
    end
    
    it "should correctly remove newlines" do
        sequence = [
            CodeLexer::Token.new(:keyword, "if"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:parenthesis, "("),
            CodeLexer::Token.new(:identifier, "t1"),
            CodeLexer::Token.new(:operator, "=="),
            CodeLexer::Token.new(:identifier, "t2"),
            CodeLexer::Token.new(:parenthesis, ")"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:keyword, "return"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:identifier, "t1"),
            CodeLexer::Token.new(:semicolon, ";"),
            CodeLexer::Token.new(:newline, "\n"),
            CodeLexer::Token.new(:space, "\t\t")
        ]
        
        abstractor = CodeLexer::Abstractor.new.remove_newlines
        abstractor.abstract!(sequence)
        
        expect(sequence.count { |t| t.type == :newline }).to eq 0
    end
    
    it "should correctly remove spaces" do
        sequence = [
            CodeLexer::Token.new(:keyword, "if"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:parenthesis, "("),
            CodeLexer::Token.new(:identifier, "t1"),
            CodeLexer::Token.new(:operator, "=="),
            CodeLexer::Token.new(:identifier, "t2"),
            CodeLexer::Token.new(:parenthesis, ")"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:keyword, "return"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:identifier, "t1"),
            CodeLexer::Token.new(:semicolon, ";"),
            CodeLexer::Token.new(:newline, "\n"),
            CodeLexer::Token.new(:space, "\t\t")
        ]
        
        abstractor = CodeLexer::Abstractor.new.remove_spaces
        abstractor.abstract!(sequence)
        
        expect(sequence.count { |t| t.type == :space }).to eq 0
    end
    
    it "should correctly remove comments" do
        sequence = [
            CodeLexer::Token.new(:keyword, "if"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:parenthesis, "("),
            CodeLexer::Token.new(:identifier, "t1"),
            CodeLexer::Token.new(:operator, "=="),
            CodeLexer::Token.new(:string, "hello world"),
            CodeLexer::Token.new(:parenthesis, ")"),
            CodeLexer::Token.new(:comment, "//This is an inline comment"),
            CodeLexer::Token.new(:newline, "\r"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:keyword, "return"),
            CodeLexer::Token.new(:space, " "),
            CodeLexer::Token.new(:string, "test string two"),
            CodeLexer::Token.new(:semicolon, ";"),
            CodeLexer::Token.new(:comment, "/* this is a test comment */"),
        ]
        
        abstractor = CodeLexer::Abstractor.new.remove_comments
        abstractor.abstract!(sequence)
        
        expect(sequence.count { |t| t.type == :comment }).to eq 0
    end
end
 
