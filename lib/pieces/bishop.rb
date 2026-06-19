# frozen_string_literal: true

require_relative 'piece'

class Bishop < Piece
  SYMBOLS = { white: '♗', black: '♝' }.freeze

  def symbol
    SYMBOLS[@color]
  end
end
