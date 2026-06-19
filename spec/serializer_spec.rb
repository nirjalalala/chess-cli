# frozen_string_literal: true

require 'serializer'
require 'json'
require 'tmpdir'

RSpec.describe Serializer do
  let(:game)   { Game.new }
  let(:tmpdir) { Dir.mktmpdir }
  let(:path)   { File.join(tmpdir, 'test.json') }

  after { FileUtils.rm_rf(tmpdir) }

  describe '.dump' do
    it 'creates a file at the given path' do
      described_class.dump(game, path)
      expect(File.exist?(path)).to be(true)
    end

    it 'writes valid JSON' do
      described_class.dump(game, path)
      expect { JSON.parse(File.read(path)) }.not_to raise_error
    end

    it 'records the current player' do
      described_class.dump(game, path)
      data = JSON.parse(File.read(path))
      expect(data['current_player']).to eq('white')
    end

    it 'records all 32 pieces from the starting position' do
      described_class.dump(game, path)
      data = JSON.parse(File.read(path))
      expect(data['squares'].length).to eq(32)
    end
  end

  describe '.load' do
    before { described_class.dump(game, path) }

    it 'returns a Game object' do
      expect(described_class.load(path)).to be_a(Game)
    end

    it 'restores the current player' do
      expect(described_class.load(path).current_player).to eq(:white)
    end

    it 'restores pieces to their correct positions' do
      loaded = described_class.load(path)
      expect(loaded.board.at(7, 4)).to be_a(King).and(have_attributes(color: :white))
    end

    it 'restores the moved flag as false on a piece that has not moved' do
      loaded = described_class.load(path)
      expect(loaded.board.at(7, 4).moved?).to be(false)
    end
  end

  describe 'round-trip' do
    it 'preserves the current player after a turn switch' do
      game.board.move([6, 4], [4, 4])
      game.switch_turns
      described_class.dump(game, path)
      expect(described_class.load(path).current_player).to eq(:black)
    end

    it 'preserves the moved flag on a piece that has moved' do
      game.board.move([6, 4], [4, 4])
      described_class.dump(game, path)
      expect(described_class.load(path).board.at(4, 4).moved?).to be(true)
    end

    it 'preserves a non-nil en passant target' do
      game.board.en_passant_target = [5, 4]
      described_class.dump(game, path)
      expect(described_class.load(path).board.en_passant_target).to eq([5, 4])
    end

    it 'preserves a nil en passant target' do
      described_class.dump(game, path)
      expect(described_class.load(path).board.en_passant_target).to be_nil
    end
  end
end
