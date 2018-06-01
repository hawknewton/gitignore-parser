class Gitignore::Parser::Rule
  def initialize(pattern)
    if pattern[0] == '!'
      @unignore = true
      pattern = pattern[1..-1]
    else
      @unignore = false
    end

    @pattern = pattern
  end

  def ignore?(path)
    !unignore && matches?(path)
  end

  def unignore?(path)
    unignore && matches?(path)
  end

  def for_dir(dir)
    pattern = pattern_for_dir(dir)
    return nil unless pattern
    "#{unignore ? '!' : ''}#{pattern}"
  end

  private

  attr_reader :pattern, :unignore

  def comment?
    pattern =~ /^#/
  end

  def glob
    @glob ||= pattern.gsub(/((?<!\\)\s)+$/, '').gsub(%r{^\*\*/}, '').gsub(%r{^/}, '')
  end

  def matches?(path, match = glob)
    return false if comment?
    path = path.gsub(%r{/$}, '') if pattern[-1] != '/'
    File.fnmatch(match, path)
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def pattern_for_dir(dir)
    (match, rest) = glob.split('/', 2)
    return rest if match == '**'
    return "#{rest[0..1] == '**' ? '' : '/'}#{rest}" if rest && matches?(dir, match)
    return nil if pattern[0] == '/' || comment?
    pattern
  end
  # rubocop:enable Metrics/CyclomaticComplexity
end
