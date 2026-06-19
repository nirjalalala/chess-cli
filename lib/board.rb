# frozen_string_literal: true

require_relative 'pieces/rook'
require_relative 'pieces/knight'
require_relative 'pieces/bishop'
require_relative 'pieces/queen'
require_relative 'pieces/king'
require_relative 'pieces/pawn'

class Board
  SIZE = 8
  # The eight piece classes on the back rank, ordered a-file through h-file.
  BACK_RANK = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook].freeze

  def initialize
    # Block form is required here: without it every row would share the same array object.
    @grid = Array.new(SIZE) { Array.new(SIZE, nil) }
  end

  def place(piece, row, col)
    @grid[row][col] = piece
    piece.position = [row, col]
  end

  def remove(row, col)
    piece = @grid[row][col]
    piece.position = nil if piece
    @grid[row][col] = nil
    piece
  end

  def at(row, col)
    @grid[row][col]
  end

  def setup_initial_position
    place_back_rank(:black, 0)
    place_pawns(:black, 1)
    place_pawns(:white, 6)
    place_back_rank(:white, 7)
  end

  private

  def place_back_rank(color, row)
    BACK_RANK.each_with_index { |piece_class, col| place(piece_class.new(color, nil), row, col) }
  end

  def place_pawns(color, row)
    SIZE.times { |col| place(Pawn.new(color, nil), row, col) }
  end
end
