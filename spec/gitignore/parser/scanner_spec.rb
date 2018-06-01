RSpec.describe Gitignore::Parser::Scanner do
  subject(:result) do
    described_class.new(opts).list_files(directory)
  end
  let(:opts) { { } }

  context 'given a directory with no .gitignore' do
    let(:directory) { 'spec/data/no_gitignore' }
    it 'returns all files' do
      expect(result).to match_array([
        'spec/data/no_gitignore/one',
        'spec/data/no_gitignore/two/three'
      ])
    end
  end

  context 'given a directory with a .gitignore' do
    let(:directory) { 'spec/data/one_gitignore' }
    it 'ignores the correct files' do
      expect(result).to match_array([
        'spec/data/one_gitignore/keep1',
        'spec/data/one_gitignore/keep2',
        'spec/data/one_gitignore/keep/keep_me',
        'spec/data/one_gitignore/keep/keep/keep_me_too',
        'spec/data/one_gitignore/keep/not_no_much',
        'spec/data/one_gitignore/keep/one_level',
        'spec/data/one_gitignore/nested_drop/level2/keep',
        'spec/data/one_gitignore/nested_drop/test'
      ])
    end
  end

  context 'given a directory with a nested .gitignore' do
    let(:directory) { 'spec/data/two_gitignores' }
    it 'ignores the correct files' do
      expect(result).to match_array([
        'spec/data/two_gitignores/keep',
        'spec/data/two_gitignores/subdir/keep_too'
      ])
    end
  end

  context 'given a directory with nested .ebignire files' do
    let(:directory) { 'spec/data/ebignore' }
    it 'returns all files' do
      expect(result).to match_array([
        'spec/data/ebignore/drop',
        'spec/data/ebignore/keep',
        'spec/data/ebignore/subdir/drop',
        'spec/data/ebignore/subdir/drop_too',
        'spec/data/ebignore/subdir/keep_too'
      ])
    end

    context 'when configured to read .ebignore' do
      let(:opts) { { filename: '.ebignore' } }
      it 'ignores the correct files' do
        expect(result).to match_array([
          'spec/data/ebignore/keep',
          'spec/data/ebignore/subdir/keep_too'
        ])
      end
    end
  end
end
