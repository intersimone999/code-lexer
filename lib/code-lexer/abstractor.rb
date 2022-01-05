require_relative 'token'

module CodeLexer
    class Abstractor        
        def initialize(identifiers_dictionary = [], strings_dictionary = [], numbers_dictionary = [])
            @dictionary = {}
            @dictionary[:identifiers] = ['NOOP'] + identifiers_dictionary
            @dictionary[:strings] = strings_dictionary
            @dictionary[:numbers] = numbers_dictionary
            
            @abstractor_pieces = []
        end
        
        def abstract_everything
            self.abstract_identifiers
            self.abstract_numbers
            self.abstract_comments
            self.abstract_strings
            self.abstract_spaces
            
            return self
        end
        
        def dictionary
            warn "[DEPRECATION] The method CodeLexer::Abstractor#dictionary is deprecated; used CodeLexer::Abstractor#identifiers_dictionary instead"
            self.identifiers_dictionary
        end
        
        def identifiers_dictionary
            @dictionary[:identifiers]
        end
        
        def strings_dictionary
            @dictionary[:strings]
        end
        
        def numbers_dictionary
            @dictionary[:numbers]
        end
        
        def dictionaries
            @dictionary
        end
        
        def abstract_identifiers
            @abstractor_pieces << IdentifierAbstractor.new(self)
            return self
        end
        
        def abstract_numbers
            @abstractor_pieces << NumberAbstractor.new(self)
            return self
        end
        
        def abstract_comments
            @abstractor_pieces << CommentAbstractor.new(self)
            return self
        end
        
        def abstract_strings
            @abstractor_pieces << StringAbstractor.new(self)
            return self
        end
        
        def abstract_spaces
            @abstractor_pieces << SpaceAbstractor.new(self)
            return self
        end
        
        def remove_spaces
            @abstractor_pieces << SpaceRemover.new(self)
            return self
        end
        
        def remove_newlines
            @abstractor_pieces << NewlineRemover.new(self)
            return self
        end
        
        def remove_comments
            @abstractor_pieces << CommentRemover.new(self)
            return self
        end
        
        def abstract!(tokens)
            @abstractor_pieces.each do |abstractor_piece|
                tokens = abstractor_piece.abstract(tokens)
            end
            
            return self
        end
        
        def deabstract!(tokens)
            @abstractor_pieces.each do |abstractor_piece|
                tokens = abstractor_piece.deabstract(tokens)
            end
            
            return self
        end
    end
    
    class AbstractorPiece
        def initialize(abstractor)
            @abstractor = abstractor
        end
        
        def abstract(tokens)
            return tokens
        end
        
        def deabstract(tokens)
            return tokens
        end
    end
    
    class IdentifierAbstractor < AbstractorPiece
        def abstract(tokens)
            identifier_tokens = tokens.select { |t| t.type == :identifier }
            identifiers = identifier_tokens.map { |id| id.value }.uniq
            
            identifiers.each do |id|
                if @abstractor.identifiers_dictionary.include?(id)
                    abstracted_id = @abstractor.identifiers_dictionary.index(id)
                else
                    abstracted_id = @abstractor.identifiers_dictionary.size
                    @abstractor.identifiers_dictionary << id 
                end
                    
                identifier_tokens.select { |t| t.value == id }.each do |matching_token|
                    matching_token.abstracted_value = Token.special("ID#{abstracted_id}")
                end
            end
            
            return tokens
        end
        
        def deabstract(tokens)
            tokens.select { |t| t.abstracted_value.match?(/.ID[0-9]+./) }.each do |token|
                id = token.abstracted_value.scan(/.ID([0-9]+)./).flatten[0].to_i
                
                token.type = :identifier
                token.value = @abstractor.identifiers_dictionary[id]
            end
            
            return tokens
        end
    end
    
    class NumberAbstractor < AbstractorPiece
        def abstract(tokens)
            tokens.select { |t| t.type == :number }.each do |number_token|
                number_token.abstracted_value = Token.special("NUMBER")
                @abstractor.numbers_dictionary << number_token.value
            end
            
            return tokens
        end
        
        def deabstract(tokens)
            id = 0
            tokens.select { |t| t.abstracted_value == Token.special("NUMBER") }.each do |token|
                token.type = :number
                token.value = @abstractor.numbers_dictionary[id]
                
                id += 1
            end
            
            return tokens
        end
    end
    
    class StringAbstractor < AbstractorPiece
        def abstract(tokens)
            tokens.select { |t| t.type == :string }.each do |string_token|
                string_token.abstracted_value = Token.special("STRING")
                @abstractor.strings_dictionary << string_token.value
            end
            
            return tokens
        end
        
        def deabstract(tokens)
            id = 0
            tokens.select { |t| t.abstracted_value == Token.special("STRING") }.each do |token|
                token.type = :string
                token.value = '"' + @abstractor.strings_dictionary[id] + '"'
                
                id += 1
            end
            
            return tokens
        end
    end
    
    class CommentAbstractor < AbstractorPiece
        def abstract(tokens)
            tokens.select { |t| t.type == :comment }.each do |comment_token|
                comment_token.abstracted_value = Token.special("COMMENT")
            end
            return tokens
        end
        
        def deabstract(tokens)
            tokens.select { |t| t.abstracted_value == Token.special("COMMENT") }.each do |token|
                token.type = :comment
                token.value = 'Unknown comment'
            end
            
            return tokens
        end
    end
    
    class SpaceAbstractor < AbstractorPiece
        def abstract(tokens)
            tokens.select { |t| t.type == :space }.each do |space_token|
                previous_index = tokens.index(space_token) - 1
                if previous_index < 0 || tokens[previous_index].type == :newline
                    space_token.abstracted_value = Token.special("INDENTATION")
                else
                    space_token.abstracted_value = Token.special("WHITESPACE")
                end
            end
            
            return tokens
        end
        
        def deabstract(tokens)
            tokens.select do |t| 
                t.abstracted_value == Token.special("INDENTATION") || 
                t.abstracted_value == Token.special("WHITESPACE")
            end.each do |token|
                token.type = :space
                token.value = ' '
            end
            
            return tokens
        end
    end
    
    class SpaceRemover < AbstractorPiece
        def abstract(tokens)
            tokens.delete_if { |t| t.type == :space }
            return tokens
        end
    end
    
    class NewlineRemover < AbstractorPiece
        def abstract(tokens)
            tokens.delete_if { |t| t.type == :newline }
            return tokens
        end
    end
    
    class CommentRemover < AbstractorPiece
        def abstract(tokens)
            tokens.delete_if { |t| t.type == :comment }
            return tokens
        end
    end
end
