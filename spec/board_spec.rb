# frozen_string_literal: true

require 'board'

# board.rb requires all piece files, so King, Rook, Pawn, etc. are in scope here.

RSpec.describe Board do
  subject(:board) { described_class.new }

  describe '#initialize' do
    it 'starts with all 64 squares empty' do
      squares = (0..7).flat_map { |row| (0..7).map { |col| board.at(row, col) } }
      expect(squares).to all(be_nil)
    end
  end

  describe '#place' do
    let(:rook) { Rook.new(:white, nil) }

    it 'places a piece at the given square' do
      board.place(rook, 3, 4)
      expect(board.at(3, 4)).to eq(rook)
    end

    it 'updates the position stored on the piece itself' do
      board.place(rook, 3, 4)
      expect(rook.position).to eq([3, 4])
    end
  end

  describe '#at' do
    it 'returns nil for an empty square' do
      expect(board.at(0, 0)).to be_nil
    end

    it 'returns the piece that was placed there' do
      pawn = Pawn.new(:black, nil)
      board.place(pawn, 1, 3)
      expect(board.at(1, 3)).to eq(pawn)
    end
  end

  describe '#remove' do
    let(:rook) { Rook.new(:white, nil) }

    before { board.place(rook, 2, 2) }

    it 'clears the square' do
      board.remove(2, 2)
      expect(board.at(2, 2)).to be_nil
    end

    it 'returns the piece that was removed' do
      expect(board.remove(2, 2)).to eq(rook)
    end

    it 'clears the position stored on the piece' do
      board.remove(2, 2)
      expect(rook.position).to be_nil
    end

    it 'returns nil when removing from an already-empty square' do
      expect(board.remove(5, 5)).to be_nil
    end
  end

  describe '#setup_initial_position' do
    before { board.setup_initial_position }

    it 'places a white King at e1 (row 7, col 4)' do
      expect(board.at(7, 4)).to be_a(King).and(have_attributes(color: :white))
    end

    it 'places a black King at e8 (row 0, col 4)' do
      expect(board.at(0, 4)).to be_a(King).and(have_attributes(color: :black))
    end

    it 'places a white Queen at d1 (row 7, col 3)' do
      expect(board.at(7, 3)).to be_a(Queen).and(have_attributes(color: :white))
    end

    it 'places a black Queen at d8 (row 0, col 3)' do
      expect(board.at(0, 3)).to be_a(Queen).and(have_attributes(color: :black))
    end

    it 'fills rank 2 (row 6) with white Pawns' do
      pieces = (0..7).map { |col| board.at(6, col) }
      expect(pieces).to all(be_a(Pawn).and(have_attributes(color: :white)))
    end

    it 'fills rank 7 (row 1) with black Pawns' do
      pieces = (0..7).map { |col| board.at(1, col) }
      expect(pieces).to all(be_a(Pawn).and(have_attributes(color: :black)))
    end

    it 'places white Rooks at a1 and h1 (row 7, cols 0 and 7)' do
      pieces = [board.at(7, 0), board.at(7, 7)]
      expect(pieces).to all(be_a(Rook).and(have_attributes(color: :white)))
    end

    it 'places black Rooks at a8 and h8 (row 0, cols 0 and 7)' do
      pieces = [board.at(0, 0), board.at(0, 7)]
      expect(pieces).to all(be_a(Rook).and(have_attributes(color: :black)))
    end

    it 'leaves the middle four ranks (rows 2–5) empty' do
      squares = (2..5).flat_map { |row| (0..7).map { |col| board.at(row, col) } }
      expect(squares).to all(be_nil)
    end

    it 'records the correct position on each placed piece' do
      expect(board.at(7, 4).position).to eq([7, 4])
    end
  end
end
