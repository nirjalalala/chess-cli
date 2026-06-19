# frozen_string_literal: true

require_relative 'piece'

class Queen < Piece
  SYMBOLS = { white: '♕', black: '♛' }.freeze
  DIRECTIONS = [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]].freeze

  def symbol
    SYMBOLS[@color]
  end

  def candidate_moves(board)
    slide_along(DIRECTIONS, board)
  end
end
