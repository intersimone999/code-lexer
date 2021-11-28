require_relative 'token'
require_relative 'abstractor'
require_relative 'config'

module CodeLexer
    class Lexer
        def initialize(config_path_or_config)
            if config_path_or_config.is_a?(Config)
                @config = config_path_or_config
            else
                @config = Config.new(config_path_or_config)
            end
        end
        
        def lex(content)
            content = content.clone
            tokens = []
            while content.length > 0
                token_name, regex = @config.matching_rule(content)
                content.sub!(regex) do |value|
                    tokens << Token.new(token_name, value)
                    ""
                end
            end
            
            return LexedContent.new(tokens)
        end
    end
    
    class LexedContent
        attr_reader     :tokens
        
        def initialize(tokens)
            @tokens = tokens
        end
                
        def token_lines
            result = []
            current_line = []
            @tokens.each do |t|
                if t.type == :newline
                    result << current_line
                    current_line = []
                else
                    current_line << t
                end
            end
            
            result << current_line
            result.delete_if { |line| line.empty? }
            
            return result
        end
        
        def token_stream(abstractor = nil)
            abstractor.abstract!(@tokens) if abstractor
            
            result = []
            @tokens.each do |token|
                result << token.abstracted_value
            end
            
            return result.join(" ")
        end
    end
end
