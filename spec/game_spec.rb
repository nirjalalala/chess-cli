# frozen_string_literal: true

require 'game'

RSpec.describe Game do
  subject(:game) { described_class.new(input: input, output: output) }

  let(:input)  { StringIO.new }
  let(:output) { StringIO.new }

  describe '#initialize' do
    it 'starts with white as the current player' do
      expect(game.current_player).to eq(:white)
    end

    it 'places pieces on the board in the starting position' do
      expect(game.board.at(7, 4)).to be_a(King).and(have_attributes(color: :white))
    end
  end

  describe '#switch_turns' do
    it 'changes the current player from white to black' do
      game.switch_turns
      expect(game.current_player).to eq(:black)
    end

    it 'changes the current player back to white after two switches' do
      2.times { game.switch_turns }
      expect(game.current_player).to eq(:white)
    end
  end

  describe '#valid_input?' do
    it 'returns true for a well-formed four-character move string' do
      expect(game.valid_input?('e2e4')).to be(true)
    end

    it 'returns false when the string is too short' do
      expect(game.valid_input?('e24')).to be(false)
    end

    it 'returns false when the string is too long' do
      expect(game.valid_input?('e2e44')).to be(false)
    end

    it 'returns false when the file letter is out of range' do
      expect(game.valid_input?('z2e4')).to be(false)
    end

    it 'returns false when the rank digit is out of range' do
      expect(game.valid_input?('e9e4')).to be(false)
    end
  end

  describe '#parse_move' do
    it 'converts e2e4 to board coordinates' do
      expect(game.parse_move('e2e4')).to eq([[6, 4], [4, 4]])
    end

    it 'converts a1a8 to board coordinates' do
      expect(game.parse_move('a1a8')).to eq([[7, 0], [0, 0]])
    end

    it 'converts h8h1 to board coordinates' do
      expect(game.parse_move('h8h1')).to eq([[0, 7], [7, 7]])
    end

    it 'returns nil for an invalid input string' do
      expect(game.parse_move('bad!')).to be_nil
    end
  end

  describe '#all_legal_moves' do
    it 'returns 20 legal moves for white from the starting position' do
      # 8 pawns × 2 moves each + 2 knights × 2 moves each = 20
      expect(game.all_legal_moves(:white).length).to eq(20)
    end
  end

  describe '#checkmate?' do
    context 'when the current player is in checkmate' do
      # White king at h1 (7,7), black queen at g2 (6,6),
      # black rook at g8 (0,6) defends the queen — king has no escape.
      subject(:game) { described_class.new(input: input, output: output, board: bare_board) }

      let(:bare_board) { Board.new }

      before do
        bare_board.place(King.new(:white, nil), 7, 7)
        bare_board.place(Queen.new(:black, nil), 6, 6)
        bare_board.place(Rook.new(:black, nil), 0, 6)
        bare_board.place(King.new(:black, nil), 0, 0)
      end

      it 'returns true' do
        expect(game.checkmate?).to be(true)
      end
    end

    context 'when the king is in check but has an escape square' do
      subject(:game) { described_class.new(input: input, output: output, board: bare_board) }

      let(:bare_board) { Board.new }

      before do
        bare_board.place(King.new(:white, nil), 4, 4)
        bare_board.place(Rook.new(:black, nil), 0, 4)
        bare_board.place(King.new(:black, nil), 0, 0)
      end

      it 'returns false' do
        expect(game.checkmate?).to be(false)
      end
    end
  end

  describe '#stalemate?' do
    context 'when the current player has no moves and is not in check' do
      # White king at a1 (7,0), black queen at b3 (5,1).
      # The queen covers a2, b2, and b1 — all king escape squares — but not a1 itself.
      subject(:game) { described_class.new(input: input, output: output, board: bare_board) }

      let(:bare_board) { Board.new }

      before do
        bare_board.place(King.new(:white, nil), 7, 0)
        bare_board.place(Queen.new(:black, nil), 5, 1)
        bare_board.place(King.new(:black, nil), 0, 7)
      end

      it 'returns true' do
        expect(game.stalemate?).to be(true)
      end
    end

    context 'when the current player has legal moves available' do
      it 'returns false' do
        expect(game.stalemate?).to be(false)
      end
    end
  end

  describe '#play' do
    context 'when the player quits immediately' do
      let(:input) { StringIO.new("quit\n") }

      it 'exits without raising an error' do
        expect { game.play }.not_to raise_error
      end
    end

    context 'when an invalid move is entered before quitting' do
      let(:input) { StringIO.new("xxxx\nquit\n") }

      it 'outputs an error message' do
        game.play
        expect(output.string).to include('Invalid')
      end
    end

    context 'when a valid move is entered before quitting' do
      let(:input) { StringIO.new("e2e4\nquit\n") }

      it 'applies the move to the board' do
        game.play
        expect(game.board.at(4, 4)).to be_a(Pawn)
      end
    end

    context 'when the board is already in a checkmate position' do
      subject(:game) { described_class.new(input: input, output: output, board: bare_board) }

      let(:bare_board) { Board.new }

      before do
        bare_board.place(King.new(:white, nil), 7, 7)
        bare_board.place(Queen.new(:black, nil), 6, 6)
        bare_board.place(Rook.new(:black, nil), 0, 6)
        bare_board.place(King.new(:black, nil), 0, 0)
      end

      it 'announces checkmate without waiting for input' do
        game.play
        expect(output.string).to include('Checkmate')
      end
    end

    context 'when the player saves before quitting' do
      subject(:game) { described_class.new(input: input, output: output, save_dir: tmpdir) }

      let(:tmpdir) { Dir.mktmpdir }
      let(:input)  { StringIO.new("save mygame\nquit\n") }

      after { FileUtils.rm_rf(tmpdir) }

      it 'writes a save file' do
        game.play
        expect(File.exist?(File.join(tmpdir, 'mygame.json'))).to be(true)
      end

      it 'outputs a confirmation message' do
        game.play
        expect(output.string).to include('Game saved')
      end
    end

    context 'when save is entered without a filename' do
      let(:input) { StringIO.new("save \nquit\n") }

      it 'outputs a usage hint' do
        game.play
        expect(output.string).to include('Usage: save FILENAME')
      end
    end
  end
end
