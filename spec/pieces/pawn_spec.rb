# frozen_string_literal: true

require 'pieces/pawn'

RSpec.describe Pawn do
  describe '#symbol' do
    it 'returns ♙ for white' do
      expect(described_class.new(:white, nil).symbol).to eq('♙')
    end

    it 'returns ♟ for black' do
      expect(described_class.new(:black, nil).symbol).to eq('♟')
    end
  end
end
