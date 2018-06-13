require 'gitignore/parser/scanner'
require 'gitignore/parser/version'
require 'gitignore/parser/rule'

module Gitignore; end

module Gitignore::Parser
  def self.list_files(opts)
    Gitignore::Parser::Scanner.new(opts).list_files
  end
end
