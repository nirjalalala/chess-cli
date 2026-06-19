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

  # Returns [[king_from, king_to], ...] pairs for valid castling moves.
  # All four conditions are checked here so King#candidate_moves stays simple.
  def legal_castling_moves(color)
    moves = []
    rank = color == :white ? 7 : 0
    king = @board.at(rank, 4)
    return moves unless king.is_a?(King) && !king.moved? && !in_check?(color)

    moves << [[rank, 4], [rank, 6]] if can_castle_king_side?(rank, color)
    moves << [[rank, 4], [rank, 2]] if can_castle_queen_side?(rank, color)
    moves
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

  def can_castle_king_side?(rank, color)
    rook = @board.at(rank, 7)
    return false unless eligible_rook?(rook, color)
    return false unless @board.at(rank, 5).nil? && @board.at(rank, 6).nil?

    !square_attacked?([rank, 5], color) && !square_attacked?([rank, 6], color)
  end

  def can_castle_queen_side?(rank, color)
    rook = @board.at(rank, 0)
    return false unless eligible_rook?(rook, color)
    return false unless queen_side_path_clear?(rank)

    !square_attacked?([rank, 3], color) && !square_attacked?([rank, 2], color)
  end

  def eligible_rook?(rook, color)
    rook.is_a?(Rook) && rook.color == color && !rook.moved?
  end

  def queen_side_path_clear?(rank)
    @board.at(rank, 1).nil? && @board.at(rank, 2).nil? && @board.at(rank, 3).nil?
  end

  # True if any enemy piece's candidate moves reach the given square.
  # Used for castling — we need to know if a square is covered,
  # independent of whether the covering piece is pinned.
  def square_attacked?(square, color)
    opponent = color == :white ? :black : :white
    enemy_pieces(opponent).any? { |piece| piece.candidate_moves(@board).include?(square) }
  end
end
