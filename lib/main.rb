# frozen_string_literal: true

require_relative 'game'
require_relative 'serializer'

game = ARGV[0] ? Serializer.load(ARGV[0]) : Game.new
game.play
