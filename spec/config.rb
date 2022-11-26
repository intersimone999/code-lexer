require_relative File.expand_path("../../lib/code-lexer", __FILE__)
require 'rspec/autorun'

describe CodeLexer::Config do
    it "should correctly load all the available rules" do
        config = CodeLexer::Config.new("#{File.dirname(File.expand_path($0))}/test_folder/t1.yml")
        expected = "(?:(\\b(arguments)\\b|\\b(break)\\b|\\b(case)\\b|\\b(catch)\\b|\\b(const)\\b|\\b(continue)\\b|\\b(debugger)\\b|\\b(default)\\b|\\b(delete)\\b|\\b(do)\\b|\\b(else)\\b|\\b(eval)\\b|\\b(false)\\b|\\b(finally)\\b|\\b(for)\\b|\\b(function)\\b|\\b(if)\\b|\\b(implements)\\b|\\b(in)\\b|\\b(instanceof)\\b|\\b(interface)\\b|\\b(let)\\b|\\b(new)\\b|\\b(null)\\b|\\b(package)\\b|\\b(private)\\b|\\b(protected)\\b|\\b(public)\\b|\\b(return)\\b|\\b(static)\\b|\\b(switch)\\b|\\b(this)\\b|\\b(throw)\\b|\\b(true)\\b|\\b(try)\\b|\\b(typeof)\\b|\\b(var)\\b|\\b(void)\\b|\\b(while)\\b|\\b(with)\\b|\\b(yield)\\b|\\b(class)\\b|\\b(enum)\\b|\\b(export)\\b|\\b(extends)\\b|\\b(import)\\b|\\b(super)\\b|\\b(from)\\b))"

        # Four rules plus a fallback "other"
        expect(config.rules.size).to eq 5
        
        expect(config.rules[0][0]).to eq :keyword
        expect(config.rules[0][1].source).to eq expected
        
        expect(config.rules[1][0]).to eq :identifier
        expect(config.rules[1][1].source).to eq "[$A-Za-z_][$A-Za-z0-9_]*"
        
        expect(config.rules[2][0]).to eq :comment
        expect(config.rules[2][1].source).to eq "\\/\\/[^.]*[\\n\\r]"
        
        expect(config.rules[3][0]).to eq :comment
        expect(config.rules[3][1].source).to eq "\\/\\/[^.]*$"
    end
    
    it "should find the best matching rule when there is a single match" do
        config = CodeLexer::Config.new("#{File.dirname(File.expand_path($0))}/test_folder/t1.yml")

        r1 = config.matching_rule("artrew void", 0)
        expect(r1.size).to eq 3
        expect(r1[0]).to eq :identifier
    end

    it "should find the best matching rule when there are multiple matches" do
        config = CodeLexer::Config.new("#{File.dirname(File.expand_path($0))}/test_folder/t1.yml")

        r1 = config.matching_rule("static void", 0)
        expect(r1.size).to eq 3
        expect(r1[0]).to eq :keyword
    end

    it "should find the best matching rule when there are multiple matches (with comments)" do
        config = CodeLexer::Config.new("#{File.dirname(File.expand_path($0))}/test_folder/javascript.yml")

        r1 = config.matching_rule("// if (parts.length === 4) {\n", 0)
        expect(r1.size).to eq 3
        expect(r1[0]).to eq :comment
    end

    it "should use the fallback when no rule matches" do
        config = CodeLexer::Config.new("#{File.dirname(File.expand_path($0))}/test_folder/t1.yml")

        r1 = config.matching_rule("@test", 0)
        expect(r1.size).to eq 3
        expect(r1[0]).to eq :other
    end
end
