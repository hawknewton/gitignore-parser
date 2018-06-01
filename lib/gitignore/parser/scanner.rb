require 'awesome_print'

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

    (files.select { |f| !File.directory?(f) } - kept).each do |filtered|
      kept << filtered if unignore?(filtered)
    end
 
    kept
  end

  private

  attr_reader :directory, :parent_patterns

  def list_directory(dir)
    return [] if ignore?("#{dir}/")
    dir_rules = rules_for_subdir(dir)
    Gitignore::Parser::Scanner.new(directory: dir, filename: filename, parent_patterns: dir_rules).list_files
  end

  def list_file(file)
    return [] if ignore?(file)
    [file]
  end

  def files
    @files ||= Dir["#{directory}/*"]
  end

  def filename
    @filename || '.gitignore'
  end

  def rules
    @rules ||= patterns.map do |line|
      Gitignore::Parser::Rule.new(line)
    end
  end

  def ignore?(path)
    rules.detect { |r| r.ignore?(relative_path(path)) }
  end

  def unignore?(path)
    rules.detect { |r| r.unignore?(relative_path(path)) }
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
