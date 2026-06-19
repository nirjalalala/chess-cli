# frozen_string_literal: true

require 'board'

RSpec.describe Bishop do
  let(:board) { Board.new }

  describe '#symbol' do
    it 'returns ♗ for white' do
      expect(described_class.new(:white, nil).symbol).to eq('♗')
    end

    it 'returns ♝ for black' do
      expect(described_class.new(:black, nil).symbol).to eq('♝')
    end
  end

  describe '#candidate_moves' do
    subject(:bishop) { described_class.new(:white, nil) }

    before { board.place(bishop, 4, 4) }

    it 'returns 13 moves from [4, 4] on a clear board' do
      expect(bishop.candidate_moves(board).length).to eq(13)
    end

    context 'when a friendly piece is on the same diagonal' do
      before { board.place(Pawn.new(:white, nil), 2, 2) }

      it 'does not include the friendly square' do
        expect(bishop.candidate_moves(board)).not_to include([2, 2])
      end

      it 'does not pass through the friendly piece' do
        expect(bishop.candidate_moves(board)).not_to include([1, 1])
      end
    end

    context 'when an enemy piece is on the same diagonal' do
      before { board.place(Pawn.new(:black, nil), 2, 2) }

      it 'includes the enemy square as a capture' do
        expect(bishop.candidate_moves(board)).to include([2, 2])
      end

      it 'does not pass through the enemy piece' do
        expect(bishop.candidate_moves(board)).not_to include([1, 1])
      end
    end
  end
end
