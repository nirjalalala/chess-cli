# frozen_string_literal: true

require 'board'
require 'move_validator'

RSpec.describe MoveValidator do
  subject(:validator) { described_class.new(board) }

  let(:board) { Board.new }

  describe '#in_check?' do
    context 'when the king is not attacked' do
      before do
        board.place(King.new(:white, nil), 7, 4)
      end

      it 'returns false' do
        expect(validator.in_check?(:white)).to be(false)
      end
    end

    context 'when an enemy rook attacks the king along the same rank' do
      before do
        board.place(King.new(:white, nil), 7, 4)
        board.place(Rook.new(:black, nil), 7, 0)
      end

      it 'returns true' do
        expect(validator.in_check?(:white)).to be(true)
      end
    end

    context 'when an enemy bishop attacks the king diagonally' do
      before do
        board.place(King.new(:white, nil), 4, 4)
        board.place(Bishop.new(:black, nil), 1, 1)
      end

      it 'returns true' do
        expect(validator.in_check?(:white)).to be(true)
      end
    end

    context 'when a friendly piece is between the king and an enemy rook' do
      before do
        board.place(King.new(:white, nil), 7, 4)
        board.place(Pawn.new(:white, nil), 7, 2)
        board.place(Rook.new(:black, nil), 7, 0)
      end

      it 'returns false — the friendly piece blocks the attack' do
        expect(validator.in_check?(:white)).to be(false)
      end
    end

    context 'when a knight attacks the king' do
      before do
        board.place(King.new(:white, nil), 4, 4)
        board.place(Knight.new(:black, nil), 2, 3)
      end

      it 'returns true' do
        expect(validator.in_check?(:white)).to be(true)
      end
    end
  end

  describe '#legal_castling_moves' do
    let(:black_king) { King.new(:black, nil) }

    before { board.place(black_king, 0, 4) }

    context 'when white can castle king-side' do
      let(:white_king) { King.new(:white, nil) }
      let(:white_rook) { Rook.new(:white, nil) }

      before do
        board.place(white_king, 7, 4)
        board.place(white_rook, 7, 7)
      end

      it 'includes the king-side move [e1, g1]' do
        expect(validator.legal_castling_moves(:white)).to include([[7, 4], [7, 6]])
      end
    end

    context 'when white can castle queen-side' do
      let(:white_king) { King.new(:white, nil) }
      let(:white_rook) { Rook.new(:white, nil) }

      before do
        board.place(white_king, 7, 4)
        board.place(white_rook, 7, 0)
      end

      it 'includes the queen-side move [e1, c1]' do
        expect(validator.legal_castling_moves(:white)).to include([[7, 4], [7, 2]])
      end
    end

    context 'when the king has already moved' do
      let(:white_king) { King.new(:white, nil) }
      let(:white_rook) { Rook.new(:white, nil) }

      before do
        board.place(white_king, 7, 4)
        board.place(white_rook, 7, 7)
        white_king.mark_moved!
      end

      it 'returns no castling moves' do
        expect(validator.legal_castling_moves(:white)).to be_empty
      end
    end

    context 'when the rook has already moved' do
      let(:white_king) { King.new(:white, nil) }
      let(:white_rook) { Rook.new(:white, nil) }

      before do
        board.place(white_king, 7, 4)
        board.place(white_rook, 7, 7)
        white_rook.mark_moved!
      end

      it 'returns no castling moves' do
        expect(validator.legal_castling_moves(:white)).to be_empty
      end
    end

    context 'when the king is currently in check' do
      before do
        board.place(King.new(:white, nil), 7, 4)
        board.place(Rook.new(:white, nil), 7, 7)
        board.place(Rook.new(:black, nil), 0, 4)
      end

      it 'returns no castling moves' do
        expect(validator.legal_castling_moves(:white)).to be_empty
      end
    end

    context 'when a piece occupies the king-side path' do
      before do
        board.place(King.new(:white, nil), 7, 4)
        board.place(Rook.new(:white, nil), 7, 7)
        board.place(Bishop.new(:white, nil), 7, 5)
      end

      it 'does not include the king-side castling move' do
        dests = validator.legal_castling_moves(:white).map { |_, to| to }
        expect(dests).not_to include([7, 6])
      end
    end

    context 'when the king would pass through an attacked square (f1)' do
      before do
        board.place(King.new(:white, nil), 7, 4)
        board.place(Rook.new(:white, nil), 7, 7)
        board.place(Rook.new(:black, nil), 0, 5)
      end

      it 'does not include the king-side castling move' do
        dests = validator.legal_castling_moves(:white).map { |_, to| to }
        expect(dests).not_to include([7, 6])
      end
    end

    context 'when the king would land on an attacked square (g1)' do
      before do
        board.place(King.new(:white, nil), 7, 4)
        board.place(Rook.new(:white, nil), 7, 7)
        board.place(Rook.new(:black, nil), 0, 6)
      end

      it 'does not include the king-side castling move' do
        dests = validator.legal_castling_moves(:white).map { |_, to| to }
        expect(dests).not_to include([7, 6])
      end
    end
  end

  describe '#legal_moves' do
    context 'when no move would leave the king in check' do
      before do
        board.place(King.new(:white, nil), 7, 4)
        board.place(Rook.new(:white, nil), 4, 4)
      end

      it 'returns all candidate moves' do
        rook = board.at(4, 4)
        candidates = rook.candidate_moves(board)
        expect(validator.legal_moves(rook)).to match_array(candidates)
      end
    end

    context 'when the king is in check' do
      before do
        board.place(King.new(:white, nil), 7, 4)
        board.place(Rook.new(:black, nil), 7, 0)
      end

      it 'only returns moves that resolve the check' do
        king = board.at(7, 4)
        legal = validator.legal_moves(king)
        legal.each do |move|
          clone = board.deep_clone
          clone.move([7, 4], move)
          after_check = described_class.new(clone).in_check?(:white)
          expect(after_check).to be(false)
        end
      end
    end

    context 'when a piece is pinned — moving it would expose the king' do
      before do
        # White king on e1 (7,4), white rook on e4 (4,4), black rook on e8 (0,4).
        # The white rook is pinned on the e-file.
        board.place(King.new(:white, nil), 7, 4)
        board.place(Rook.new(:white, nil), 4, 4)
        board.place(Rook.new(:black, nil), 0, 4)
      end

      it 'does not include moves that break the pin' do
        white_rook = board.at(4, 4)
        legal = validator.legal_moves(white_rook)
        off_file_moves = legal.reject { |_row, col| col == 4 }
        expect(off_file_moves).to be_empty
      end

      it 'includes moves along the pin axis (e-file)' do
        white_rook = board.at(4, 4)
        legal = validator.legal_moves(white_rook)
        on_file_moves = legal.select { |_row, col| col == 4 }
        expect(on_file_moves).not_to be_empty
      end
    end
  end
end
