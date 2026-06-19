# frozen_string_literal: true

require 'board'

RSpec.describe King do
  let(:board) { Board.new }

  describe '#symbol' do
    it 'returns ♔ for white' do
      expect(described_class.new(:white, nil).symbol).to eq('♔')
    end

    it 'returns ♚ for black' do
      expect(described_class.new(:black, nil).symbol).to eq('♚')
    end
  end

  describe '#candidate_moves' do
    subject(:king) { described_class.new(:white, nil) }

    context 'when at central square [4, 4] on a clear board' do
      before { board.place(king, 4, 4) }

      it 'returns 8 moves' do
        expect(king.candidate_moves(board).length).to eq(8)
      end
    end

    context 'when at corner [0, 0]' do
      before { board.place(king, 0, 0) }

      it 'returns 3 moves' do
        expect(king.candidate_moves(board).length).to eq(3)
      end
    end

    context 'when a friendly piece occupies an adjacent square' do
      before do
        board.place(king, 4, 4)
        board.place(Pawn.new(:white, nil), 3, 4)
      end

      it 'does not include the friendly square' do
        expect(king.candidate_moves(board)).not_to include([3, 4])
      end

      it 'returns 7 moves' do
        expect(king.candidate_moves(board).length).to eq(7)
      end
    end

    context 'when an enemy piece occupies an adjacent square' do
      before do
        board.place(king, 4, 4)
        board.place(Pawn.new(:black, nil), 3, 4)
      end

      it 'includes the enemy square as a capture' do
        expect(king.candidate_moves(board)).to include([3, 4])
      end
    end
  end
end
