class Gitignore::Parser::Scanner
  def initialize(opts)
    @directory = opts[:directory]
    @filename = opts[:filename]
    @parent_rules = opts[:parent_rules] || []
  end

  def list_files
    files.map do |file|
      relative = file[directory.length + 1..-1]
      if File.directory?(file)
        next if ignored?("#{relative}/")
        dir_rules = rules_for_dir(relative)
        Gitignore::Parser::Scanner.new(directory: file, filename: filename, parent_rules: dir_rules).list_files
      else
        next if ignored?(relative)
        [file]
      end
    end.compact.flatten
  end

  private

  attr_reader :directory, :parent_rules

  def files
    @files ||= Dir["#{directory}/*"]
  end

  def filename
    @filename || '.gitignore'
  end

  def parse_rules
    gitignore = File.join(directory, filename)
    return [] if Dir[gitignore].empty?

    rules = []
    File.read(gitignore).each_line do |line|
      rules << Gitignore::Parser::Rule.new(line)
    end
    rules
  end

  def ignored?(path)
    rules.detect { |r| r.matches?(path) }
  end

  def rules
    @rules ||= parse_rules + parent_rules
  end

  def rules_for_dir(dir)
    patterns = rules.map { |r| r.for_dir(dir) }.compact
    patterns.map { |p| Gitignore::Parser::Rule.new(p) }
  end
end
