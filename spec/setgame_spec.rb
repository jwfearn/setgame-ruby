require_relative '../setgame'

RSpec.describe SET::Card do
  # a, b, and c are a known set
  let(:a) { described_class.new(1, 0, 0, 1) }
  let(:b) { described_class.new(0, 1, 0, 0) }
  let(:c) { described_class.new(2, 2, 0, 2) }
  # x is known not to make a set with any combination of a, b, or c
  let(:x) { described_class.new(0, 1, 0, 1) }

  describe '#to_s' do
    it 'outputs in number, color, shading, shape order' do
      expect(b.to_s).to eq('one green solid diamond')
      expect(x.to_s).to eq('one green solid squiggle')
      expect(described_class.new(0, 0, 1, 0).to_s).to eq('one red empty diamond')
      expect(described_class.new(0, 0, 2, 0).to_s).to eq('one red striped diamond')
    end

    it 'pluralizes multiple shapes' do
      expect(a.to_s).to eq('two red solid squiggles')
      expect(c.to_s).to eq('three purple solid ovals')
    end
  end

  describe '.set?' do
    it 'is true when given known sets' do
      expect(described_class.set?(a, b, c)).to be true
    end

    it 'is false when given known non-sets' do
      expect(described_class.set?(a, b, x)).to be false
      expect(described_class.set?(a, x, c)).to be false
      expect(described_class.set?(a, b, x)).to be false
    end
  end

  describe '.find_set' do
    it 'returns nil when no set is found' do
      expect(described_class.find_set(a, b, x)).to be nil
      expect(described_class.find_set(a, x, c)).to be nil
      expect(described_class.find_set(a, b, x)).to be nil
    end

    it 'returns an array of three cards when a set is found' do
      expect(described_class.find_set(a, b, c)).to contain_exactly(a, b, c)
      expect(described_class.find_set(x, a, b, c)).to contain_exactly(a, b, c)
      expect(described_class.find_set(a, x, b, c)).to contain_exactly(a, b, c)
      expect(described_class.find_set(a, b, x, c)).to contain_exactly(a, b, c)
      expect(described_class.find_set(a, b, c, x)).to contain_exactly(a, b, c)
    end
  end

  describe '.remove_set' do
    context 'when no set is found' do
      it 'returns nil' do
        expect(described_class.remove_set(nil)).to be nil
        expect(described_class.remove_set([])).to be nil
        expect(described_class.remove_set([x])).to be nil
        expect(described_class.remove_set([a, x])).to be nil
        expect(described_class.remove_set([x, a])).to be nil
        expect(described_class.remove_set([a, b, x])).to be nil
        expect(described_class.remove_set([a, x, c])).to be nil
        expect(described_class.remove_set([a, b, x])).to be nil
      end

      it 'does not change input board when no set is found' do
        board = nil; expect { described_class.remove_set(board) }.not_to change { board }
        board = []; expect { described_class.remove_set(board) }.not_to change { board }
        board = [x]; expect { described_class.remove_set(board) }.not_to change { board }
        board = [x, a]; expect { described_class.remove_set(board) }.not_to change { board }
        board = [a, x]; expect { described_class.remove_set(board) }.not_to change { board }
        board = [a, b, x]; expect { described_class.remove_set(board) }.not_to change { board }
        board = [a, x, c]; expect { described_class.remove_set(board) }.not_to change { board }
        board = [a, b, x]; expect { described_class.remove_set(board) }.not_to change { board }
      end
    end

    context 'when a set is found' do
      it 'returns an array of three cards' do
        board = [a, b, c]; expect(described_class.remove_set(board)).to contain_exactly(a, b, c)
        board = [x, a, b, c]; expect(described_class.remove_set(board)).to contain_exactly(a, b, c)
        board = [a, x, b, c]; expect(described_class.remove_set(board)).to contain_exactly(a, b, c)
        board = [a, b, x, c]; expect(described_class.remove_set(board)).to contain_exactly(a, b, c)
        board = [a, b, c, x]; expect(described_class.remove_set(board)).to contain_exactly(a, b, c)
      end

      it 'removes set from input board' do
        board = [a, b, c]; described_class.remove_set(board); expect(board).to be_empty
        board = [x, a, b, c]; described_class.remove_set(board); expect(board).to contain_exactly(x)
        board = [a, x, b, c]; described_class.remove_set(board); expect(board).to contain_exactly(x)
        board = [a, b, x, c]; described_class.remove_set(board); expect(board).to contain_exactly(x)
        board = [a, b, c, x]; described_class.remove_set(board); expect(board).to contain_exactly(x)
      end
    end
  end
end

RSpec.describe SET::Game do
  describe '#play' do
    it 'terminates and can report results' do
      expect(described_class.new.play.report).not_to be_empty
    end
  end
end
