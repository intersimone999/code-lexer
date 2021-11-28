require_relative 'token'

module CodeLexer
    class Abstractor
        attr_reader     :dictionary
        
        def initialize(dictionary=[])
            @dictionary = ["NOOP"] + dictionary
        end
        
        def abstract_everything
            self.abstract_identifiers
            self.abstract_numbers
            self.abstract_comments
            self.abstract_strings
            self.abstract_spaces
            
            return self
        end
        
        def abstract_identifiers
            @abstract_identifiers = true
            return self
        end
        
        def abstract_numbers
            @abstract_numbers = true
            return self
        end
        
        def abstract_comments
            @abstract_comments = true
            return self
        end
        
        def abstract_strings
            @abstract_strings = true
            return self
        end
        
        def abstract_spaces
            @abstract_spaces = true
            return self
        end
        
        def remove_spaces
            @remove_spaces = true
            return self
        end
        
        def remove_newlines
            @remove_newlines = true
            return self
        end
        
        def remove_comments
            @remove_comments = true
            return self
        end
        
        def abstract!(tokens)
            if @abstract_identifiers
                identifier_tokens = tokens.select { |t| t.type == :identifier }
                identifiers = identifier_tokens.map { |id| id.value }.uniq
                
                identifiers.each do |id|
                    if @dictionary.include?(id)
                        abstracted_id = @dictionary.index(id)
                    else
                        abstracted_id = @dictionary.size
                        @dictionary << id 
                    end
                        
                    identifier_tokens.select { |t| t.value == id }.each do |matching_token|
                        matching_token.abstracted_value = Token.special("ID#{abstracted_id}")
                    end
                end
            end
            
            if @remove_comments
                tokens.delete_if { |t| t.type == :comment }
            elsif @abstract_comments
                tokens.select { |t| t.type == :comment }.each do |comment_token|
                    comment_token.abstracted_value = Token.special("COMMENT")
                end
            end
            
            if @abstract_numbers
                tokens.select { |t| t.type == :number }.each do |number_token|
                    number_token.abstracted_value = Token.special("NUMBER")
                end
            end
            
            if @abstract_strings
                tokens.select { |t| t.type == :string }.each do |string_token|
                    string_token.abstracted_value = Token.special("STRING")
                end
            end
            
            if @remove_newlines
                tokens.delete_if { |t| t.type == :newline }
            end
            
            if @remove_spaces
                tokens.delete_if { |t| t.type == :space }
            elsif @abstract_spaces
                tokens.select { |t| t.type == :space }.each do |space_token|
                    previous_index = tokens.index(space_token) - 1
                    if previous_index < 0 || tokens[previous_index].type == :newline
                        space_token.abstracted_value = Token.special("INDENTATION")
                    else
                        space_token.abstracted_value = Token.special("WHITESPACE")
                    end
                end
            end
            
            return self
        end
    end
end
