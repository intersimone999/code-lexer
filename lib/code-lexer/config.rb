require 'yaml'

module CodeLexer
    class Config
        attr_reader     :rules
        def initialize(path)
            @config = File.basename(path)
            @rules = []
            
            load_rules(path)
        end
        
        def matching_rule(text, start_index)
            min_index = 10000
            min_triple = []
            @rules.each do |name, regex|
                if (first_occurrence_index = text.index(regex, start_index))
                    if first_occurrence_index < min_index
                        min_index = first_occurrence_index
                        new_start_index = Regexp.last_match.end(0)
                        min_triple = [name, first_occurrence_index, new_start_index]
                    end
                end
            end
            return *min_triple
        end
        
        private
        def load_rules(content)
            parsed = YAML.load_file(content)
            
            
            parsed['lexer'].each do |name, regexs|
                regexs.each do |regex|
                    regex = Regexp.new(regex, Regexp::MULTILINE)
                    @rules << [name.to_sym, regex]
                end
            end
            
            @rules << [:other, /./]
        end
    end 
end
