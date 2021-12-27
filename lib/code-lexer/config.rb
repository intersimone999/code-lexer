require 'yaml'

module CodeLexer
    class Config
        attr_reader     :rules
        def initialize(path)
            @config = File.basename(path)
            @rules = []
            
            load_rules(path)
        end
        
        def matching_rule(text)
            min_score = 10000
            min_couple = []
            @rules.each do |name, regex|
                if (score = (text =~ regex))
                    if score < min_score
                        min_score = score
                        min_couple = [name, regex]
                    end
                end
            end
            
            return *min_couple
        end
        
        private
        def load_rules(content)
            parsed = YAML.load_file(content)
            
            
            parsed['lexer'].each do |name, regexs|
                regexs.each do |regex|
                    regex = Regexp.new("^" + regex, Regexp::MULTILINE)
                    @rules << [name.to_sym, regex]
                end
            end
            
            @rules << [:other, /./]
        end
    end 
end
