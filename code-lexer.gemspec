Gem::Specification.new do |s|
  s.name        = 'code-lexer'
  s.version     = '0.9'
  s.date        = '2022-11-18'
  s.summary     = "Simple source code lexer"
  s.description = "Source code lexer configurable for any programming language that allows to tokenize and abstract a given source file"
  s.authors     = ["Simone Scalabrino"]
  s.email       = 's.scalabrino9@gmail.com'
  s.files       = Dir.glob("lib/**/*.rb") + Dir.glob("lib/**/*.yml") + Dir.glob("lib/**/*.yaml")
  s.homepage    = 'https://github.com/intersimone999/code-lexer'
  s.license     = "GPL-3.0-only"
  
  s.add_runtime_dependency "code-assertions", "~> 1.1.2", ">= 1.1.2"
end
