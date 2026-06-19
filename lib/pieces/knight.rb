# frozen_string_literal: true

require_relative 'piece'

class Knight < Piece
  SYMBOLS = { white: '♘', black: '♞' }.freeze
  JUMPS = [[-2, -1], [-2, 1], [-1, -2], [-1, 2], [1, -2], [1, 2], [2, -1], [2, 1]].freeze

  def symbol
    SYMBOLS[@color]
  end

  def candidate_moves(board)
    JUMPS.filter_map do |dr, dc|
      row = @position[0] + dr
      col = @position[1] + dc
      next unless on_board?(row, col)
      next if board.at(row, col)&.color == @color

      [row, col]
    end
  end
end
