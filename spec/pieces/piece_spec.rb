# frozen_string_literal: true

require 'pieces/piece'

RSpec.describe Piece do
  subject(:piece) { described_class.new(:white, [4, 4]) }

  describe '#color' do
    it 'returns the color the piece was created with' do
      expect(piece.color).to eq(:white)
    end
  end

  describe '#position' do
    it 'returns the position the piece was created with' do
      expect(piece.position).to eq([4, 4])
    end
  end

  describe '#position=' do
    it 'updates the stored position' do
      piece.position = [2, 3]
      expect(piece.position).to eq([2, 3])
    end
  end

  describe '#white?' do
    it 'returns true for a white piece' do
      expect(piece.white?).to be true
    end

    it 'returns false for a black piece' do
      expect(described_class.new(:black, nil).white?).to be false
    end
  end

  describe '#black?' do
    it 'returns true for a black piece' do
      expect(described_class.new(:black, nil).black?).to be true
    end

    it 'returns false for a white piece' do
      expect(piece.black?).to be false
    end
  end

  describe '#symbol' do
    it 'raises NotImplementedError — subclasses must implement it' do
      expect { piece.symbol }.to raise_error(NotImplementedError)
    end
  end

  describe '#candidate_moves' do
    it 'raises NotImplementedError — subclasses must implement it' do
      expect { piece.candidate_moves(nil) }.to raise_error(NotImplementedError)
    end
  end
end
