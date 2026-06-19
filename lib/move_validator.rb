# frozen_string_literal: true

require_relative 'board'

class MoveValidator
  def initialize(board)
    @board = board
  end

  def in_check?(color)
    king_pos = @board.find_king(color)
    enemy_color = color == :white ? :black : :white
    enemy_pieces(enemy_color).any? do |piece|
      piece.candidate_moves(@board).include?(king_pos)
    end
  end

  def legal_moves(piece)
    piece.candidate_moves(@board).reject do |destination|
      move_leaves_king_in_check?(piece, destination)
    end
  end

  private

  def move_leaves_king_in_check?(piece, destination)
    clone = @board.deep_clone
    clone.move(piece.position, destination)
    MoveValidator.new(clone).in_check?(piece.color)
  end

  def enemy_pieces(color)
    squares = (0..7).flat_map { |row| (0..7).map { |col| @board.at(row, col) } }
    squares.select { |piece| piece&.color == color }
  end
end
