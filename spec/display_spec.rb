# frozen_string_literal: true

require 'display'
require 'board'

RSpec.describe Display do
  subject(:display) { described_class.new(board) }

  let(:board) { Board.new }

  before { board.setup_initial_position }

  describe '#render' do
    subject(:output) { display.render }

    it 'includes all rank labels 1 through 8' do
      expect(output).to include('1', '2', '3', '4', '5', '6', '7', '8')
    end

    it 'includes all file labels a through h' do
      expect(output).to include('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h')
    end

    it 'shows the white king symbol' do
      expect(output).to include('♔')
    end

    it 'shows the black king symbol' do
      expect(output).to include('♚')
    end

    it 'shows empty square markers for the middle ranks' do
      expect(output).to include('·')
    end
  end
end
