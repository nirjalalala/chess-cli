# frozen_string_literal: true

require 'json'
require 'fileutils'
require_relative 'board'
require_relative 'game'

class Serializer
  class << self
    def dump(game, path)
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, JSON.pretty_generate(game_to_h(game)))
    end

    def load(path)
      data = JSON.parse(File.read(path))
      game_from_h(data)
    end

    private

    def game_to_h(game)
      {
        'current_player' => game.current_player.to_s,
        'en_passant_target' => game.board.en_passant_target,
        'squares' => squares_to_a(game.board)
      }
    end

    def squares_to_a(board)
      (0..7).flat_map do |row|
        (0..7).filter_map do |col|
          piece = board.at(row, col)
          next unless piece

          { 'type' => piece.class.name, 'color' => piece.color.to_s,
            'row' => row, 'col' => col, 'moved' => piece.moved? }
        end
      end
    end

    def game_from_h(data)
      board = build_board(data['squares'])
      board.en_passant_target = data['en_passant_target']
      Game.new(board: board, current_player: data['current_player'].to_sym)
    end

    def build_board(squares)
      board = Board.new
      squares.each do |sq|
        piece_class = Object.const_get(sq['type'])
        piece = piece_class.new(sq['color'].to_sym, nil)
        piece.mark_moved! if sq['moved']
        board.place(piece, sq['row'], sq['col'])
      end
      board
    end
  end
end
