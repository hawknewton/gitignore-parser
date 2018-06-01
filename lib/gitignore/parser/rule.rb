class Gitignore::Parser::Rule
  def initialize(pattern)
    @pattern = pattern
  end

  def matches?(path, match = glob)
    return false if comment?
    path = path.gsub(/\/$/, '') if pattern[-1] != '/' 
    File.fnmatch(match, path)
  end

  def for_dir(dir)
    return nil if comment?
    (match, rest) = glob.split('/', 2)
    return rest if match == '**'
    return "#{rest[0..1] == '**' ? '' : '/'}#{rest}" if rest && matches?(dir, match)
    return nil if pattern[0] == '/'
    pattern
  end

  private

  attr_reader :pattern

  def comment?
    pattern =~ /^#/
  end

  def glob
    @glob ||= pattern.gsub(/((?<!\\)\s)+$/, '').gsub(/^\*\*\//, '').gsub(/^\//, '')
  end
end
