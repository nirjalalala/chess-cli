# chess-cli

A two-player command-line Chess game written in Ruby. Runs entirely in the terminal with Unicode pieces.
<img width="919" height="399" alt="chess-cli" src="https://github.com/user-attachments/assets/84a55bba-f4c1-4fcd-b712-3de4c9b5cf54" />

## Features

- All six piece types with correct movement geometry
- Full rule enforcement: check, checkmate, and stalemate detection
- Castling (king-side and queen-side)
- En passant
- Pawn promotion with piece selection
- Save and resume games (JSON format)

## Requirements

- Ruby 3.x
- Bundler

## Setup

```bash
git clone https://github.com/nirjalalala/chess-cli.git
cd chess-cli
bundle install
```

## Playing

```bash
./bin/chess                      # start a new game
./bin/chess saves/mygame.json    # resume a saved game
```

### Entering moves

Type the source square followed by the destination square and press Enter:

```
White's move: e2e4
```

| Action | Input |
|---|---|
| Move a piece | `e2e4` |
| Castle king-side | `e1g1` (white) / `e8g8` (black) |
| Castle queen-side | `e1c1` (white) / `e8c8` (black) |
| Save the game | `save FILENAME` |
| Quit | `quit` |

When a pawn reaches the back rank you will be prompted to choose a promotion piece: `Q` (Queen), `R` (Rook), `B` (Bishop), or `N` (Knight). Defaults to Queen.

## Development

```bash
bundle exec rspec        # run all tests
bundle exec rubocop      # lint
ruby lib/main.rb         # alternative entry point
```
