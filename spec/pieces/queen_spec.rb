# frozen_string_literal: true

require 'board'

RSpec.describe Queen do
  let(:board) { Board.new }

  describe '#symbol' do
    it 'returns ♕ for white' do
      expect(described_class.new(:white, nil).symbol).to eq('♕')
    end

    it 'returns ♛ for black' do
      expect(described_class.new(:black, nil).symbol).to eq('♛')
    end
  end

  describe '#candidate_moves' do
    subject(:queen) { described_class.new(:white, nil) }

    before { board.place(queen, 4, 4) }

    it 'returns 27 moves from [4, 4] on a clear board' do
      expect(queen.candidate_moves(board).length).to eq(27)
    end

    context 'when a friendly piece blocks a ray' do
      before { board.place(Pawn.new(:white, nil), 4, 6) }

      it 'does not include the friendly square' do
        expect(queen.candidate_moves(board)).not_to include([4, 6])
      end

      it 'does not pass through the friendly piece' do
        expect(queen.candidate_moves(board)).not_to include([4, 7])
      end
    end

    context 'when an enemy piece is on a ray' do
      before { board.place(Pawn.new(:black, nil), 4, 6) }

      it 'includes the enemy square as a capture' do
        expect(queen.candidate_moves(board)).to include([4, 6])
      end

      it 'does not pass through the enemy piece' do
        expect(queen.candidate_moves(board)).not_to include([4, 7])
      end
    end
  end
end
