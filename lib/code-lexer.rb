require_relative 'code-lexer/config'
require_relative 'code-lexer/abstractor'
require_relative 'code-lexer/lexer'
require_relative 'code-lexer/token'

module CodeLexer
    def self.get(language)
        return Lexer.new("#{File.dirname(File.expand_path(__FILE__))}/code-lexer/languages/#{language}.clex")
    end
end
