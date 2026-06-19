# frozen_string_literal: true

require_relative 'board'
require_relative 'display'
require_relative 'move_validator'
require_relative 'serializer'

class Game
  attr_reader :board, :current_player

  def initialize(input: $stdin, output: $stdout, board: nil, current_player: :white, save_dir: 'saves')
    @board = board || Board.new.tap(&:setup_initial_position)
    @input = input
    @output = output
    @current_player = current_player
    @save_dir = save_dir
    @validator = MoveValidator.new(@board)
  end

  def play
    loop do
      @output.puts Display.new(@board).render
      if game_over?
        announce_result
        break
      end
      announce_check if in_check?
      break unless take_turn
    end
  end

  def switch_turns
    @current_player = @current_player == :white ? :black : :white
  end

  def valid_input?(str)
    return false unless str.length == 4

    str[0].match?(/[a-h]/i) && str[1].match?(/[1-8]/) &&
      str[2].match?(/[a-h]/i) && str[3].match?(/[1-8]/)
  end

  def parse_move(input_str)
    return nil unless valid_input?(input_str)

    [square_to_coords(input_str[0..1]), square_to_coords(input_str[2..3])]
  end

  def all_legal_moves(color)
    regular = pieces_for(color).flat_map { |piece| @validator.legal_moves(piece) }
    castling = @validator.legal_castling_moves(color).map { |_, to| to }
    regular + castling
  end

  def checkmate?
    in_check? && all_legal_moves(@current_player).empty?
  end

  def stalemate?
    !in_check? && all_legal_moves(@current_player).empty?
  end

  private

  def in_check?
    @validator.in_check?(@current_player)
  end

  def game_over?
    all_legal_moves(@current_player).empty?
  end

  def take_turn
    input_str = prompt_for_move
    return false if input_str.downcase == 'quit'
    return true if handle_save_command(input_str)

    coords = parse_move(input_str)
    unless coords && valid_move?(coords[0], coords[1])
      @output.puts "Invalid move. Enter a move like e2e4, save FILENAME, or 'quit' to exit."
      return true
    end

    apply_move(coords[0], coords[1])
    promote_pawn_if_needed(coords[1])
    switch_turns
    true
  end

  def prompt_for_move
    @output.print "#{@current_player.to_s.capitalize}'s move (e.g. e2e4, save FILENAME, quit): "
    raw = @input.gets
    return 'quit' if raw.nil?

    raw.strip
  end

  def handle_save_command(input_str)
    parts = input_str.split(' ', 2)
    return false unless parts[0].downcase == 'save'

    filename = parts[1]&.strip
    if filename.nil? || filename.empty?
      @output.puts 'Usage: save FILENAME (e.g. save mygame)'
      return true
    end

    path = File.join(@save_dir, "#{filename}.json")
    Serializer.dump(self, path)
    @output.puts "Game saved to #{path}."
    true
  end

  def valid_move?(from, to)
    piece = @board.at(from[0], from[1])
    return false unless piece&.color == @current_player
    return true if @validator.legal_castling_moves(@current_player).include?([from, to])

    @validator.legal_moves(piece).include?(to)
  end

  def apply_move(from, to)
    if castling_move?(from, to)
      apply_castle(from, to)
    elsif en_passant_capture?(from, to)
      apply_en_passant(from, to)
    else
      @board.move(from, to)
    end
    update_en_passant_target(from, to)
  end

  PROMOTION_PIECES = { 'Q' => Queen, 'R' => Rook, 'B' => Bishop, 'N' => Knight }.freeze

  def promote_pawn_if_needed(to)
    piece = @board.at(to[0], to[1])
    return unless piece.is_a?(Pawn) && promotion_rank?(piece.color, to[0])

    new_class = prompt_promotion_choice
    @board.place(new_class.new(piece.color, nil), to[0], to[1])
  end

  def promotion_rank?(color, row)
    (color == :white && row.zero?) || (color == :black && row == 7)
  end

  def prompt_promotion_choice
    @output.print 'Pawn promoted! Choose piece (Q/R/B/N): '
    input = @input.gets&.strip&.upcase
    PROMOTION_PIECES.fetch(input, Queen)
  end

  def castling_move?(from, to)
    piece = @board.at(from[0], from[1])
    piece.is_a?(King) && (to[1] - from[1]).abs == 2
  end

  def en_passant_capture?(from, to)
    piece = @board.at(from[0], from[1])
    piece.is_a?(Pawn) && from[1] != to[1] && @board.at(to[0], to[1]).nil?
  end

  def apply_en_passant(from, to)
    @board.move(from, to)
    # The captured pawn sits on the attacker's starting row, in the destination column.
    @board.remove(from[0], to[1])
  end

  def update_en_passant_target(from, to)
    piece = @board.at(to[0], to[1])
    @board.en_passant_target = ([(from[0] + to[0]) / 2, from[1]] if piece.is_a?(Pawn) && (to[0] - from[0]).abs == 2)
  end

  def apply_castle(king_from, king_to)
    rank = king_from[0]
    king_side = king_to[1] == 6
    rook_from = [rank, king_side ? 7 : 0]
    rook_to   = [rank, king_side ? 5 : 3]
    @board.move(king_from, king_to)
    @board.move(rook_from, rook_to)
  end

  def announce_check
    @output.puts "#{@current_player.to_s.capitalize} is in check!"
  end

  def announce_result
    if in_check?
      winner = @current_player == :white ? :black : :white
      @output.puts "Checkmate! #{winner.to_s.capitalize} wins!"
    else
      @output.puts 'Stalemate! The game is a draw.'
    end
  end

  def square_to_coords(square)
    col = square[0].downcase.ord - 'a'.ord
    row = 8 - square[1].to_i
    [row, col]
  end

  def pieces_for(color)
    all_pieces = (0..7).flat_map do |row|
      (0..7).filter_map { |col| @board.at(row, col) }
    end
    all_pieces.select { |piece| piece.color == color }
  end
end
