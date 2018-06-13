class Gitignore::Parser::Scanner
  def initialize(opts)
    @directory = opts[:directory]
    @filename = opts[:filename]
    @parent_patterns = opts[:parent_patterns] || []
  end

  def list_files
    kept = files.map do |file|
      if File.directory?(file)
        list_directory(file)
      else
        list_file(file)
      end
    end.compact.flatten

    kept + (files.reject { |f| File.directory?(f) } - kept).select do |filtered|
      unignored?(filtered)
    end
  end

  private

  attr_reader :directory, :parent_patterns

  def list_directory(dir)
    return [] if ignored?("#{dir}/")
    dir_rules = rules_for_subdir(dir)
    Gitignore::Parser::Scanner.new(directory: dir, filename: filename, parent_patterns: dir_rules).list_files
  end

  def list_file(file)
    return [] if ignored?(file)
    [file]
  end

  def files
    @files ||= Dir.glob("#{directory}/*", File::FNM_DOTMATCH).tap { |a| a.shift(2) }
  end

  def filename
    @filename || '.gitignore'
  end

  def rules
    @rules ||= patterns.map do |line|
      Gitignore::Parser::Rule.new(line)
    end
  end

  %i[ignore unignore].each do |name|
    define_method("#{name}d?") do |path|
      rules.detect { |r| r.send("#{name}?", relative_path(path)) }
    end
  end

  def patterns
    @patterns ||=
      begin
        gitignore = File.join(directory, filename)
        return parent_patterns unless File.exist?(gitignore)
        File.readlines(gitignore) + parent_patterns
      end
  end

  def relative_path(path)
    path[directory.length + 1..-1]
  end

  def rules_for_subdir(path)
    rules.map { |r| r.for_dir(relative_path(path)) }.compact
  end
end
