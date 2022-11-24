module CodeLexer
    class Token
        SPECIAL_TOKEN_OPEN  = "¬"
        SPECIAL_TOKEN_CLOSE = "¬"
        
        def self.special(token)
            "#{SPECIAL_TOKEN_OPEN}#{token}#{SPECIAL_TOKEN_CLOSE}"
        end
        
        attr_accessor :type
        attr_accessor :value
        attr_accessor :abstracted_value
        
        def self.from_string(string)
            unless string.start_with?(SPECIAL_TOKEN_OPEN)
                value = string
            else
                value = nil
            end
            
            token = Token.new(:unknown, value)
            token.abstracted_value = string
            
            return token
        end
        
        def initialize(type, value)
            @type = type
            self.value = value
        end
        
        def value=(v)
            @value = v
            self.reset_abstraction
        end
        
        def to_s
            if @abstracted_value != @value
                return "<#@type:#{@value.inspect}:#{@abstracted_value.inspect}>"
            else
                return "<#@type:#{@value.inspect}>"
            end
        end
                
        def ==(oth)
            @type == oth.type && @value == oth.value && @abstracted_value == oth.abstracted_value
        end
        
        def reset_abstraction
            if @type == :newline
                @abstracted_value = Token.special("NEWLINE")
            elsif @type == :indentation
               @abstracted_value = Token.special("INDENTATION")
            elsif @value =~ /\s/
                @abstracted_value = Token.special(@value.gsub(/\s/, "·"))
            else
                @abstracted_value = @value.clone
            end
        end
    end
end
