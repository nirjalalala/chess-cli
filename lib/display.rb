# frozen_string_literal: true

class Display
  EMPTY_SQUARE = '·'
  FILES = ('a'..'h').to_a.freeze
  # Ranks in display order: 8 at the top (row 0), 1 at the bottom (row 7).
  RANKS = 8.downto(1).to_a.freeze

  def initialize(board)
    @board = board
  end

  def render
    rows = RANKS.each_with_index.map { |rank, row| render_rank(rank, row) }
    ([file_labels] + rows + [file_labels]).join("\n")
  end

  private

  def file_labels
    "  #{FILES.join(' ')}"
  end

  def render_rank(rank, row)
    squares = (0..7).map { |col| square_char(row, col) }
    "#{rank} #{squares.join(' ')} #{rank}"
  end

  def square_char(row, col)
    piece = @board.at(row, col)
    piece ? piece.symbol : EMPTY_SQUARE
  end
end
