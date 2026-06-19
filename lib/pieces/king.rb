# frozen_string_literal: true

require_relative 'piece'

class King < Piece
  SYMBOLS = { white: '♔', black: '♚' }.freeze
  DIRECTIONS = [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]].freeze

  def symbol
    SYMBOLS[@color]
  end

  def candidate_moves(board)
    DIRECTIONS.filter_map do |dr, dc|
      row = @position[0] + dr
      col = @position[1] + dc
      next unless on_board?(row, col)
      next if board.at(row, col)&.color == @color

      [row, col]
    end
  end
end
