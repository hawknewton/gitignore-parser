class Gitignore::Parser::Rule
  def initialize(pattern)
    @pattern = pattern
  end

  def matches?(path, match = glob)
    return false if comment?
    path = path.gsub(%r{/$}, '') if pattern[-1] != '/'
    File.fnmatch(match, path)
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def for_dir(dir)
    (match, rest) = glob.split('/', 2)
    return rest if match == '**'
    return "#{rest[0..1] == '**' ? '' : '/'}#{rest}" if rest && matches?(dir, match)
    return nil if pattern[0] == '/' || comment?
    pattern
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  private

  attr_reader :pattern

  def comment?
    pattern =~ /^#/
  end

  def glob
    @glob ||= pattern.gsub(/((?<!\\)\s)+$/, '').gsub(%r{^\*\*/}, '').gsub(%r{^/}, '')
  end
end
