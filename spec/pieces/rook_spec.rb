# frozen_string_literal: true

require 'board'

RSpec.describe Rook do
  let(:board) { Board.new }

  describe '#symbol' do
    it 'returns ♖ for white' do
      expect(described_class.new(:white, nil).symbol).to eq('♖')
    end

    it 'returns ♜ for black' do
      expect(described_class.new(:black, nil).symbol).to eq('♜')
    end
  end

  describe '#candidate_moves' do
    subject(:rook) { described_class.new(:white, nil) }

    before { board.place(rook, 4, 4) }

    it 'returns 14 moves from [4, 4] on a clear board' do
      expect(rook.candidate_moves(board).length).to eq(14)
    end

    context 'when a friendly piece is on the same file ahead' do
      before { board.place(Pawn.new(:white, nil), 2, 4) }

      it 'does not include the friendly square' do
        expect(rook.candidate_moves(board)).not_to include([2, 4])
      end

      it 'does not pass through the friendly piece' do
        expect(rook.candidate_moves(board)).not_to include([1, 4])
      end

      it 'can still reach the square immediately before it' do
        expect(rook.candidate_moves(board)).to include([3, 4])
      end
    end

    context 'when an enemy piece is on the same file ahead' do
      before { board.place(Pawn.new(:black, nil), 2, 4) }

      it 'includes the enemy square as a capture' do
        expect(rook.candidate_moves(board)).to include([2, 4])
      end

      it 'does not pass through the enemy piece' do
        expect(rook.candidate_moves(board)).not_to include([1, 4])
      end
    end
  end
end
