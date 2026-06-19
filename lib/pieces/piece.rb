# frozen_string_literal: true

# Abstract base class for all chess pieces.
# Subclasses implement #symbol and, in Phase 3, #candidate_moves.
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
end
