
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gitignore/parser/version'

Gem::Specification.new do |spec|
  spec.name          = 'gitignore-parser'
  spec.version       = Gitignore::Parser::VERSION
  spec.authors       = ['hawknewton']
  spec.email         = ['hawk.newton@gmail.com']

  spec.summary       = 'List files honoring .gitgnore'
  spec.description   = 'Lists files and directies accordingto .gitignore'
  spec.homepage      = 'https://github.com/hawknewton/gitignore-parser'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
end
