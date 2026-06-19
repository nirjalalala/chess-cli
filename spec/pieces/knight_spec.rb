# frozen_string_literal: true

require 'board'

RSpec.describe Knight do
  let(:board) { Board.new }

  describe '#symbol' do
    it 'returns ♘ for white' do
      expect(described_class.new(:white, nil).symbol).to eq('♘')
    end

    it 'returns ♞ for black' do
      expect(described_class.new(:black, nil).symbol).to eq('♞')
    end
  end

  describe '#candidate_moves' do
    subject(:knight) { described_class.new(:white, nil) }

    context 'when at central square [4, 4] on a clear board' do
      before { board.place(knight, 4, 4) }

      it 'returns 8 moves' do
        expect(knight.candidate_moves(board).length).to eq(8)
      end
    end

    context 'when at [4, 4] with friendly pieces on all orthogonally adjacent squares' do
      before do
        board.place(knight, 4, 4)
        [[3, 4], [5, 4], [4, 3], [4, 5]].each { |r, c| board.place(Pawn.new(:white, nil), r, c) }
      end

      it 'jumps over them and still returns 8 moves' do
        expect(knight.candidate_moves(board).length).to eq(8)
      end
    end

    context 'when at corner [0, 0]' do
      before { board.place(knight, 0, 0) }

      it 'returns 2 moves' do
        expect(knight.candidate_moves(board).length).to eq(2)
      end
    end

    context 'when a friendly piece is on a target square' do
      before do
        board.place(knight, 4, 4)
        board.place(Pawn.new(:white, nil), 2, 3)
      end

      it 'does not include the friendly square' do
        expect(knight.candidate_moves(board)).not_to include([2, 3])
      end
    end

    context 'when an enemy piece is on a target square' do
      before do
        board.place(knight, 4, 4)
        board.place(Pawn.new(:black, nil), 2, 3)
      end

      it 'includes the enemy square as a capture' do
        expect(knight.candidate_moves(board)).to include([2, 3])
      end
    end
  end
end
