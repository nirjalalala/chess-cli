# frozen_string_literal: true

require_relative 'piece'

class Pawn < Piece
  SYMBOLS = { white: '♙', black: '♟' }.freeze

  def symbol
    SYMBOLS[@color]
  end

  def candidate_moves(board)
    forward_moves(board) + diagonal_captures(board)
  end

  private

  def forward_moves(board)
    moves = []
    row, col = @position
    dir = forward_direction
    one_ahead = row + dir
    return moves unless on_board?(one_ahead, col) && board.at(one_ahead, col).nil?

    moves << [one_ahead, col]
    two_ahead = row + (2 * dir)
    moves << [two_ahead, col] if on_starting_rank?(row) && board.at(two_ahead, col).nil?
    moves
  end

  def diagonal_captures(board)
    row, col = @position
    one_ahead = row + forward_direction
    return [] unless on_board?(one_ahead, col)

    [-1, 1].filter_map do |dc|
      capture_col = col + dc
      next unless on_board?(one_ahead, capture_col)

      target = board.at(one_ahead, capture_col)
      [one_ahead, capture_col] if target && target.color != @color
    end
  end

  def forward_direction
    @color == :white ? -1 : 1
  end

  def on_starting_rank?(row)
    (@color == :white && row == 6) || (@color == :black && row == 1)
  end
end
