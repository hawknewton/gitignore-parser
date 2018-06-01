class Gitignore::Parser::Scanner
  def initialize(opts)
    @directory = opts[:directory]
    @filename = opts[:filename]
    @parent_rules = opts[:parent_rules] || []
  end

  def list_files
    files.map do |file|
      if File.directory?(file)
        list_directory(file)
      else
        list_file(file)
      end
    end.compact.flatten
  end

  private

  attr_reader :directory, :parent_rules

  def list_directory(dir)
    return [] if ignored?("#{dir}/")
    dir_rules = rules_for_subdir(dir)
    Gitignore::Parser::Scanner.new(directory: dir, filename: filename, parent_rules: dir_rules).list_files
  end

  def list_file(file)
    return [] if ignored?(file)
    [file]
  end

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
    rules.detect { |r| r.matches?(relative_path(path)) }
  end

  def relative_path(path)
    path[directory.length + 1..-1]
  end

  def rules
    @rules ||= parse_rules + parent_rules
  end

  def rules_for_subdir(path)
    patterns = rules.map { |r| r.for_dir(relative_path(path)) }.compact
    patterns.map { |p| Gitignore::Parser::Rule.new(p) }
  end
end
