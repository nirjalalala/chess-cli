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
    pieces_for(color).flat_map { |piece| @validator.legal_moves(piece) }
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

    @validator.legal_moves(piece).include?(to)
  end

  def apply_move(from, to)
    @board.move(from, to)
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
