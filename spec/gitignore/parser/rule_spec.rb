RSpec.describe Gitignore::Parser::Rule do
  subject(:rule) { described_class.new(pattern) }

  context 'given a patern without slashes' do
    let(:pattern) { 'foo*bar' }

    it 'matches as a glob' do
      expect(rule.ignore?('foobar')).to be true
      expect(rule.ignore?('foo123bar')).to be true
      expect(rule.ignore?('bar')).to be false
    end

    it 'matches directories' do
      expect(rule.ignore?('foobar/')).to be true
      expect(rule.ignore?('foobar123/')).to be false
    end

    it 'propagates the rule to subdirectories' do
      expect(rule.for_dir('foobar')).to eq pattern
      expect(rule.for_dir('test')).to eq pattern
    end
  end

  context 'given a pattern with unescaped trailing spaces' do
    let(:pattern) { 'foo*  ' }

    it 'ignores the spaces' do
      expect(rule.ignore?('foo')).to be true
    end

    it 'matches directories' do
      expect(rule.ignore?('foo/')).to be true
      expect(rule.ignore?('bar/')).to be false
    end

    it 'propagates the rule to subdirectories' do
      expect(rule.for_dir('foobar')).to eq pattern
      expect(rule.for_dir('test')).to eq pattern
    end
  end

  context 'given a pattern with escaped trailing spaces' do
    let(:pattern) { 'foo*\ \ ' }

    it 'matches the spaces' do
      expect(rule.ignore?('foo123  ')).to be true
      expect(rule.ignore?('foo123 ')).to be false
    end

    it 'matches directories' do
      expect(rule.ignore?('foo123  /')).to be true
      expect(rule.ignore?('foo123 /')).to be false
    end

    it 'propagates the rule to subdirectories' do
      expect(rule.for_dir('foobar')).to eq pattern
      expect(rule.for_dir('test')).to eq pattern
    end
  end

  context 'given a pattern with a leading #' do
    let(:pattern) { '#foo' }

    it 'ignores the pattern' do
      expect(rule.ignore?('#foo')).to be false
      expect(rule.ignore?('foo')).to be false
    end

    it 'does not propagate the rule to subdirectories' do
      expect(rule.for_dir('foobar')).to be_nil
    end
  end

  context 'given a pattern with a leading \#' do
    let(:pattern) { '\#foo' }

    it 'matches the #' do
      expect(rule.ignore?('#foo')).to be true
      expect(rule.ignore?('foo')).to be false
    end

    it 'matches directories' do
      expect(rule.ignore?('#foo/')).to be true
      expect(rule.ignore?('foo/')).to be false
    end
  end

  context 'given a pattern ending with a slash' do
    let(:pattern) { 'foo*/' }

    it 'only matches directories' do
      expect(rule.ignore?('foo')).to be false
      expect(rule.ignore?('foo/')).to be true
      expect(rule.ignore?('foo123/')).to be true
    end
  end

  context 'given a pattern starting with **' do
    let(:pattern) { '**/foo' }

    it 'matches the trailing pattern' do
      expect(rule.ignore?('foo')).to be true
      expect(rule.ignore?('bar')).to be false
    end

    it 'matches directories' do
      expect(rule.ignore?('foo/')).to be true
      expect(rule.ignore?('bar/')).to be false
    end
  end

  context 'given a pattern with a leading slash' do
    let(:pattern) { '/foo' }
    it 'matches the proceeding glob' do
      expect(rule.ignore?('foo')).to be true
      expect(rule.ignore?('bar')).to be false
    end

    it 'matches directories' do
      expect(rule.ignore?('foo/')).to be true
      expect(rule.ignore?('bar/')).to be false
    end

    it 'does not propagate the rule to subdirectories' do
      expect(rule.for_dir('bar')).to be_nil
      expect(rule.for_dir('foo')).to be_nil
    end
  end

  context 'given a pattern with multiple slashes' do
    let(:pattern) { 'foo/bar/baz' }

    it 'matches nothing' do
      expect(rule.ignore?('foo')).to be false
      expect(rule.ignore?('foo/')).to be false
      expect(rule.ignore?('baz')).to be false
      expect(rule.ignore?('baz/')).to be false
    end

    it 'propagates the whole pattern when the subdirectory does not match' do
      expect(rule.for_dir('test')).to eq pattern
    end

    it 'propagates the trailing pattern when the subdirectory matches' do
      expect(rule.for_dir('foo')).to eq '/bar/baz'
    end
  end

  context 'given a pattern with a leading slash and multiple slashes' do
    let(:pattern) { '/foo/bar/baz' }

    it 'matches nothing' do
      expect(rule.ignore?('foo')).to be false
      expect(rule.ignore?('foo/')).to be false
      expect(rule.ignore?('baz')).to be false
      expect(rule.ignore?('baz/')).to be false
    end

    it 'does not propagate pattern when the subdirectory does not match' do
      expect(rule.for_dir('test')).to be_nil
    end

    it 'propagates the trailing pattern when the subdirectory matches' do
      expect(rule.for_dir('foo')).to eq '/bar/baz'
    end
  end

  context 'given a pattern with multiple slashes and two asterisks' do
    let(:pattern) { 'foo/**/baz' }

    it 'matches nothing' do
      expect(rule.ignore?('foo')).to be false
      expect(rule.ignore?('foo/')).to be false
      expect(rule.ignore?('baz')).to be false
      expect(rule.ignore?('baz/')).to be false
    end

    it 'propagates the pattern when the subdirectory does not match' do
      expect(rule.for_dir('test')).to eq pattern
    end

    it 'propagates the trailing pattern when the subdirectory matches' do
      expect(rule.for_dir('foo')).to eq '**/baz'
    end
  end

  context 'given a pattern with a leading slash and two asterisks' do
    let(:pattern) { '/**/baz' }

    it 'matches nothing' do
      expect(rule.ignore?('foo')).to be false
      expect(rule.ignore?('foo/')).to be false
      expect(rule.ignore?('baz')).to be false
      expect(rule.ignore?('baz/')).to be false
    end

    it 'propagates the pattern when the subdirectory does not match' do
      expect(rule.for_dir('test')).to eq 'baz'
    end

    it 'propagates the trailing pattern when the subdirectory matches' do
      expect(rule.for_dir('foo')).to eq 'baz'
    end
  end

  context 'given a pattern with a a trailing "/**"' do
    let(:pattern) { 'baz/**' }

    it 'matches nothing' do
      expect(rule.ignore?('foo')).to be false
      expect(rule.ignore?('baz')).to be false
      expect(rule.ignore?('baz/')).to be false
    end

    it 'propagates the pattern when the subdirectory does not match' do
      expect(rule.for_dir('test')).to eq 'baz/**'
    end

    it 'propagates the trailing pattern when the subdirectory matches' do
      expect(rule.for_dir('baz')).to eq '**'
    end
  end

  context 'given a pattern of "**"' do
    let(:pattern) { '**' }
    it 'matches everything' do
      expect(rule.ignore?('foo')).to be true
      expect(rule.ignore?('baz/')).to be true
    end

    it 'propages nothing to subdirectories' do
      expect(rule.for_dir('test')).to be_nil
    end
  end

  context 'given a pattern without a leading !' do
    let(:pattern) { 'foo' }

    it 'ignores the pattern' do
      expect(rule.ignore?('foo')).to be true
    end

    it 'does not unignore the pattern' do
      expect(rule.unignore?('foo')).to be false
    end

    it 'does not prefix the rule with !' do
      expect(rule.for_dir('bar')).to eq 'foo'
    end
  end

  context 'given a pattern with a leading !' do
    let(:pattern) { '!foo' }

    it 'does not ignore the pattern' do
      expect(rule.ignore?('foo')).to be false
    end

    it 'unignores the pattern' do
      expect(rule.unignore?('foo')).to be true
    end

    it 'prefixes the rule with !' do
      expect(rule.for_dir('bar')).to eq '!foo'
    end
  end
end
