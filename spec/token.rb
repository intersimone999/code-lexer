require_relative File.expand_path("../../lib/code-lexer", __FILE__)
require 'rspec/autorun'

describe CodeLexer::Token do
    it "should correctly define special tokens" do
        expect(CodeLexer::Token.special("hello world")).to eq("¬hello world¬")
    end
    
    it "should correctly create base tokens" do
        token = CodeLexer::Token.new(:keyword, "test")
        
        expect(token.type).to eq :keyword
        expect(token.value).to eq "test"
        expect(token.abstracted_value).to eq "test"
    end
    
    it "should correctly abstract tokens with spaces" do
        token = CodeLexer::Token.new(:comment, "test test")
        
        expect(token.type).to eq :comment
        expect(token.value).to eq "test test"
        expect(token.abstracted_value).to eq CodeLexer::Token.special("test·test")
    end
    
    it "should correctly abstract newlines" do
        token = CodeLexer::Token.new(:newline, "\n")
        
        expect(token.type).to eq :newline
        expect(token.value).to eq "\n"
        expect(token.abstracted_value).to eq CodeLexer::Token.special("NEWLINE")
        
        token = CodeLexer::Token.new(:newline, "\r")
        
        expect(token.type).to eq :newline
        expect(token.value).to eq "\r"
        expect(token.abstracted_value).to eq CodeLexer::Token.special("NEWLINE")
    end
    
    it "should correctly return a string representation" do
        token = CodeLexer::Token.new(:identifier, "test")
        expect(token.to_s).to eq "<identifier:\"test\">"
        
        token = CodeLexer::Token.new(:string, "test test")
        expect(token.to_s).to eq "<string:\"test test\":\"#{CodeLexer::Token.special("test·test")}\">"
    end
end
 
