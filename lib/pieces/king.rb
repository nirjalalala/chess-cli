# frozen_string_literal: true

require_relative 'piece'

class King < Piece
  SYMBOLS = { white: '♔', black: '♚' }.freeze

  def symbol
    SYMBOLS[@color]
  end
end
