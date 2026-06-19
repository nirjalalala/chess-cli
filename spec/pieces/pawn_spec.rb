# frozen_string_literal: true

require 'board'

RSpec.describe Pawn do
  let(:board) { Board.new }

  describe '#symbol' do
    it 'returns ♙ for white' do
      expect(described_class.new(:white, nil).symbol).to eq('♙')
    end

    it 'returns ♟ for black' do
      expect(described_class.new(:black, nil).symbol).to eq('♟')
    end
  end

  describe '#candidate_moves' do
    context 'when a white pawn is on its starting rank (row 6)' do
      let(:pawn) { described_class.new(:white, nil) }

      before { board.place(pawn, 6, 3) }

      it 'includes one square forward' do
        expect(pawn.candidate_moves(board)).to include([5, 3])
      end

      it 'includes two squares forward' do
        expect(pawn.candidate_moves(board)).to include([4, 3])
      end

      it 'returns exactly 2 moves on a clear board' do
        expect(pawn.candidate_moves(board).length).to eq(2)
      end
    end

    context 'when a white pawn is on a non-starting rank (row 4)' do
      let(:pawn) { described_class.new(:white, nil) }

      before { board.place(pawn, 4, 3) }

      it 'includes one square forward' do
        expect(pawn.candidate_moves(board)).to include([3, 3])
      end

      it 'does not include two squares forward' do
        expect(pawn.candidate_moves(board)).not_to include([2, 3])
      end
    end

    context 'when a white pawn is blocked directly ahead' do
      let(:pawn) { described_class.new(:white, nil) }

      before do
        board.place(pawn, 6, 3)
        board.place(described_class.new(:black, nil), 5, 3)
      end

      it 'cannot move forward' do
        expect(pawn.candidate_moves(board)).not_to include([5, 3])
      end

      it 'cannot advance two squares either' do
        expect(pawn.candidate_moves(board)).not_to include([4, 3])
      end
    end

    context 'when a white pawn has an enemy piece diagonally ahead' do
      let(:pawn) { described_class.new(:white, nil) }

      before do
        board.place(pawn, 6, 3)
        board.place(described_class.new(:black, nil), 5, 4)
      end

      it 'includes the diagonal square as a capture' do
        expect(pawn.candidate_moves(board)).to include([5, 4])
      end
    end

    context 'when a white pawn has a friendly piece diagonally ahead' do
      let(:pawn) { described_class.new(:white, nil) }

      before do
        board.place(pawn, 6, 3)
        board.place(described_class.new(:white, nil), 5, 4)
      end

      it 'does not include the diagonal square' do
        expect(pawn.candidate_moves(board)).not_to include([5, 4])
      end
    end

    context 'when a white pawn has an empty diagonal square ahead' do
      let(:pawn) { described_class.new(:white, nil) }

      before { board.place(pawn, 6, 3) }

      it 'does not include the empty diagonal' do
        expect(pawn.candidate_moves(board)).not_to include([5, 4])
      end
    end

    context 'when a white pawn has an enemy piece directly ahead' do
      let(:pawn) { described_class.new(:white, nil) }

      before do
        board.place(pawn, 6, 3)
        board.place(described_class.new(:black, nil), 5, 3)
      end

      it 'cannot capture forward — only diagonal captures are legal' do
        expect(pawn.candidate_moves(board)).not_to include([5, 3])
      end
    end

    context 'when a black pawn is on its starting rank (row 1)' do
      let(:pawn) { described_class.new(:black, nil) }

      before { board.place(pawn, 1, 3) }

      it 'includes one square forward (downward)' do
        expect(pawn.candidate_moves(board)).to include([2, 3])
      end

      it 'includes two squares forward (downward)' do
        expect(pawn.candidate_moves(board)).to include([3, 3])
      end
    end

    context 'when a white pawn can capture en passant to the right' do
      let(:pawn) { described_class.new(:white, nil) }

      before do
        board.place(pawn, 3, 3)
        board.en_passant_target = [2, 4]
      end

      it 'includes the en passant target square' do
        expect(pawn.candidate_moves(board)).to include([2, 4])
      end
    end

    context 'when the en passant target is not adjacent to the pawn' do
      let(:pawn) { described_class.new(:white, nil) }

      before do
        board.place(pawn, 3, 3)
        board.en_passant_target = [2, 6]
      end

      it 'does not include the non-adjacent target' do
        expect(pawn.candidate_moves(board)).not_to include([2, 6])
      end
    end

    context 'when a black pawn has an enemy piece diagonally ahead (downward)' do
      let(:pawn) { described_class.new(:black, nil) }

      before do
        board.place(pawn, 1, 3)
        board.place(described_class.new(:white, nil), 2, 2)
      end

      it 'includes the diagonal square as a capture' do
        expect(pawn.candidate_moves(board)).to include([2, 2])
      end
    end
  end
end
