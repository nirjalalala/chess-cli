# frozen_string_literal: true

# Abstract base class for all chess pieces.
# Subclasses implement #symbol and #candidate_moves.
class Piece
  attr_reader :color
  attr_accessor :position

  def initialize(color, position)
    @color = color
    @position = position
  end

  def white?
    @color == :white
  end

  def black?
    @color == :black
  end

  # Subclasses must override this to return the Unicode glyph for the piece.
  def symbol
    raise NotImplementedError, "#{self.class} must implement #symbol"
  end

  # Subclasses must override this to return candidate [row, col] destinations.
  # These are geometrically reachable squares — check filtering happens in MoveValidator.
  def candidate_moves(_board)
    raise NotImplementedError, "#{self.class} must implement #candidate_moves"
  end

  private

  # Walk along each direction until the board edge or a blocking piece.
  # Used by Rook, Bishop, and Queen.
  def slide_along(directions, board)
    directions.flat_map { |dr, dc| ray_moves(dr, dc, board) }
  end

  def ray_moves(row_step, col_step, board)
    moves = []
    row, col = @position
    loop do
      row += row_step
      col += col_step
      break unless on_board?(row, col)

      occupant = board.at(row, col)
      if occupant
        moves << [row, col] unless occupant.color == @color
        break
      end
      moves << [row, col]
    end
    moves
  end

  def on_board?(row, col)
    row.between?(0, 7) && col.between?(0, 7)
  end
end
