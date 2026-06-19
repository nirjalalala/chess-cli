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

  def move(from, to)
    piece = remove(from[0], from[1])
    remove(to[0], to[1])
    place(piece, to[0], to[1])
    piece.mark_moved!
  end

  def find_king(color)
    each_square { |piece, row, col| return [row, col] if piece.is_a?(King) && piece.color == color }
    nil
  end

  def deep_clone
    clone = self.class.new
    each_square do |piece, row, col|
      next unless piece

      new_piece = piece.class.new(piece.color, nil)
      new_piece.mark_moved! if piece.moved?
      clone.place(new_piece, row, col)
    end
    clone
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

  def each_square
    @grid.each_with_index do |row_arr, row|
      row_arr.each_with_index { |piece, col| yield piece, row, col }
    end
  end
end
