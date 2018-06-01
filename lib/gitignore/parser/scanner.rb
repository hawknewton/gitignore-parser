class Gitignore::Parser::Scanner
  def initialize(opts)
    @filename = opts[:filename]
  end

  def list_files(dir, parent_rules = [])
    rules = get_rules_for(dir) + parent_rules

    files = Dir["#{dir}/*"]

    files.map do |file|
      relative = file[dir.length + 1..-1]
      if File.directory?(file)
        next if rules.detect { |r| r.matches?("#{relative}/") }
        dir_rules = rules_for_dir(relative, rules)
        list_files(file, dir_rules)
      else
        next if rules.detect { |r| r.matches?(relative) }
        [file]
      end
    end.compact.flatten
  end

  private

  def filename
    @filename || '.gitignore'
  end

  def get_rules_for(dir)
    gitignore = File.join(dir, filename)
    return [] if Dir[gitignore].empty?

    rules = []
    File.read(gitignore).each_line do |line|
      rules << Gitignore::Parser::Rule.new(line)
    end
    rules
  end

  def rules_for_dir(dir, rules)
    patterns = rules.map { |r| r.for_dir(dir) }.compact
    patterns.map { |p| Gitignore::Parser::Rule.new(p) }
  end
end
