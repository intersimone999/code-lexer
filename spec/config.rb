require_relative File.expand_path("../../lib/code-lexer", __FILE__)
require 'rspec/autorun'

describe CodeLexer::Config do
    it "should correctly load all the available rules" do
        config = CodeLexer::Config.new("#{File.dirname(File.expand_path($0))}/test_folder/t1.yml")
        
        # Four rules plus a fallback "other"
        expect(config.rules.size).to eq 5
        
        expect(config.rules[0][0]).to eq :keyword
        expect(config.rules[0][1]).to eq /^(?:abstract|arguments|boolean|break|byte|case|catch|char|const|continue|debugger|default|delete|do|double|else|eval|false|final|finally|float|for|function|goto|if|implements|in|instanceof|int|interface|let|long|native|new|null|package|private|protected|public|return|short|static|switch|synchronized|this|throw|throws|transient|true|try|typeof|var|void|volatile|while|with|yield|class|enum|export|extends|import|super|from)/
        
        expect(config.rules[1][0]).to eq :identifier
        expect(config.rules[1][1].source).to eq "^[$A-Za-z_][$A-Za-z0-9_]*"
        
        expect(config.rules[2][0]).to eq :comment
        expect(config.rules[2][1].source).to eq "^\\/\\/[^.]*[\\n\\r]"
        
        expect(config.rules[3][0]).to eq :comment
        expect(config.rules[3][1].source).to eq "^\\/\\/[^.]*$"
    end
    
    it "should find the best matching rule when there is a single match" do
        config = CodeLexer::Config.new("#{File.dirname(File.expand_path($0))}/test_folder/t1.yml")
        
        r1 = config.matching_rule("artrew void")
        expect(r1.size).to eq 2
        expect(r1[0]).to eq :identifier
    end
    
    it "should find the best matching rule when there are multiple matches" do
        config = CodeLexer::Config.new("#{File.dirname(File.expand_path($0))}/test_folder/t1.yml")
        
        r1 = config.matching_rule("abstract void")
        expect(r1.size).to eq 2
        expect(r1[0]).to eq :keyword
    end
    
    it "should find the best matching rule when there are multiple matches (with comments)" do
        config = CodeLexer::Config.new("#{File.dirname(File.expand_path($0))}/test_folder/javascript.yml")
        
        r1 = config.matching_rule("// if (parts.length === 4) {\n")
        expect(r1.size).to eq 2
        expect(r1[0]).to eq :comment
    end
    
    it "should use the fallback when no rule matches" do
        config = CodeLexer::Config.new("#{File.dirname(File.expand_path($0))}/test_folder/t1.yml")
        
        r1 = config.matching_rule("@test")
        expect(r1.size).to eq 2
        expect(r1[0]).to eq :other
    end
end
