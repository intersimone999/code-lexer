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
        
        def lex(content, abstractor = nil)
            checkpoint_index = 0
            content = content.clone
            tokens = []
            while checkpoint_index < content.size
                previous_index = checkpoint_index
                token_name, occurrence_index, checkpoint_index = @config.matching_rule(content, checkpoint_index)

                if checkpoint_index != previous_index
                    tokens << Token.new(token_name, content[occurrence_index..checkpoint_index-1])
                end
            end

            return LexedContent.new(tokens, abstractor)
        end
    end
    
    class LexedContent
        attr_reader     :tokens
        attr_reader     :abstractor
        
        def self.from_stream_string(stream, abstractor)
            tokens = stream.split(" ").map { |t| Token.from_string(t) }
            abstractor.deabstract!(tokens)
            return LexedContent.new(tokens, abstractor)
        end
        
        def initialize(tokens, abstractor = nil)
            @tokens = tokens
            @abstractor = abstractor
            
            @abstractor.abstract!(@tokens) if @abstractor
        end
        
        def reconstruct
            @tokens.map { |t| t.value.to_s }.join("")
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
            result = []
            
            tokens = @tokens
            if abstractor
                tokens = tokens.map { |t| t.clone }
                tokens.each { |t| t.reset_abstraction }
                abstractor.abstract!(tokens)
            end
            
            tokens.each do |token|
                result << token.abstracted_value
            end
            
            return result.join(" ")
        end
        
        def to_s
            @tokens.map { |t| t.value }.join("")
        end
        
        def dump(filename, mode = "w", force = false)
            if mode.downcase.include?("w") && !force
                if FileTest.exist?(filename) || FileTest.exist?(lexdata(filename))
                    raise "Destination filename or lexdata filename already exist."
                end
            end
            
            File.open(filename, mode) do |f|
                f << self.token_stream + "\n"
            end
            
            File.open(lexdata(filename), "#{mode}b") do |f|
                f << Marshal.dump(@abstractor)
            end
        end
        
        def self.load(file_or_filename, lexdata_or_lexdata_filename = nil)
            if file_or_filename.is_a?(String) && (lexdata_or_lexdata_filename.is_a?(String) || !lexdata_or_lexdata_filename)
                unless lexdata_or_lexdata_filename
                    return self.load_filename(file_or_filename)
                else
                    return self.load_filename(file_or_filename, lexdata_or_lexdata_filename)
                end
            elsif file_or_filename.is_a?(File) && lexdata_or_lexdata_filename.is_a?(File)
                return self.load_file(file_or_filename, lexdata_or_lexdata_filename)
            else
                raise "Unable to call with the provided input types: expected (String, String), (String), or (File, File)"
            end
        end
        
        def self.load_filename(filename, lexdata_filename = filename + ".lexdata")
            File.open(filename, "r") do |file|
                File.open(lexdata_filename, "rb") do |lexdata_file|
                    return LexedContent.load_file(file, lexdata_file)
                end
            end
        end
        
        def self.load_file(file, lexdata_file)
            line = file.readline
            abstractor = Marshal.load(lexdata_file)
            return LexedContent.from_stream_string(line, abstractor)
        end
        
        private
        def lexdata(filename)
            filename + ".lexdata"
        end
    end
end
