import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/set.{type Set}
import gleam/string
import list_extra

import types.{
  type Board, type Bonus, type Cell, type Char, type Playspot, type Rack, Cell,
  DoubleLetterScore, DoubleWordScore, Rack, Square, Tile, TripleLetterScore,
  TripleWordScore,
}

const board_size = 15

pub fn init() -> Board {
  let board: String =
    "
    4__1___4___1__4
    _2___3___3___2_
    __2___1_1___2__
    1__2___1___2__1
    ____2_____2____
    _3___3___3___3_
    __1___1_1___1__
    4__1___2___1__4
    __1___1_1___1__
    _3___3___3___3_
    ____2_____2____
    1__2___1___2__1
    __2___1_1___2__
    _2___3___3___2_
    4__1___4___1__4
    "

  let assert Ok(board) = parse_board(board)

  board
}

pub fn parse_rack(chars: String, num_blanks: Int) -> Result(Rack, String) {
  case string.byte_size(chars), is_alphanum(chars) {
    size, True if size > 7 -> Error("rack has too many chars")
    _, True -> {
      let chars = string.to_graphemes(chars) |> list.sort(string.compare)
      Ok(Rack(chars, num_blanks))
    }
    _, False -> Error("rack has unidentifiable letters")
  }
}

pub fn char_to_points(char: Char) -> Int {
  case char {
    "E" | "A" | "I" | "O" | "N" | "R" | "T" | "L" | "S" | "U" -> 1
    "D" | "G" -> 2
    "B" | "C" | "M" | "P" -> 3
    "F" | "H" | "V" | "W" | "Y" -> 4
    "K" -> 5
    "J" | "X" -> 8
    "Q" | "Z" -> 10
    // lowercase letters are for blanks
    "e"
    | "a"
    | "i"
    | "o"
    | "n"
    | "r"
    | "t"
    | "l"
    | "s"
    | "u"
    | "d"
    | "g"
    | "b"
    | "c"
    | "m"
    | "p"
    | "f"
    | "h"
    | "v"
    | "w"
    | "y"
    | "k"
    | "j"
    | "x"
    | "q"
    | "z" -> 0
    "1" | "2" | "3" | "4" -> 0
    _ -> panic as { "unrecognized character \"" <> char <> "\"" }
  }
}

/// are all chars in word a-z, A-Z, 1-4, or _?
pub fn is_alphanum(word: String) -> Bool {
  word
  |> string.to_utf_codepoints
  |> list.all(fn(codepoint) {
    let int = string.utf_codepoint_to_int(codepoint)
    case int {
      x if 65 <= x && x <= 90 -> True
      x if 97 <= x && x <= 122 -> True
      49 | 50 | 51 | 52 -> True
      95 -> True
      _ -> False
    }
  })
}

pub fn parse_board(board: String) -> Result(Board, String) {
  let board =
    board
    |> string.replace(" ", "")
    |> string.replace("\n", "")
    |> string.trim

  case string.byte_size(board), is_alphanum(board) {
    _, False -> Error("board must be a-z, A-Z, 1-4, or _")
    225, True -> {
      let board =
        board
        |> string.to_graphemes
        |> list.sized_chunk(into: 15)
        |> list.index_map(fn(row, row_index) {
          row
          |> list.index_map(fn(cell, col_index) {
            #(Cell(col_index, row_index), case cell {
              "1" -> Square(None, Some(DoubleLetterScore))
              "2" -> Square(None, Some(DoubleWordScore))
              "3" -> Square(None, Some(TripleLetterScore))
              "4" -> Square(None, Some(TripleWordScore))
              "_" -> Square(None, None)
              char ->
                Square(
                  Some(Tile(string.uppercase(char), char_to_points(char))),
                  None,
                )
            })
          })
        })
        |> list.flatten
        |> dict.from_list

      Ok(board)
    }
    _, _ -> Error("board must be exactly 225 characters")
  }
}

/// finds all cells corresponding to empty squares that are immediately orthogonal to squares with tiles
pub fn build_adjacent_cells(board: Board) -> Set(Cell) {
  dict.to_list(board)
  |> list_extra.flat_map(fn(tup) {
    case tup {
      #(Cell(x, y), Square(Some(Tile(_, _)), _)) -> [
        Cell(x, y + 1),
        Cell(x + 1, y),
        Cell(x, y - 1),
        Cell(x - 1, y),
      ]
      _ -> []
    }
  })
  |> list.prepend(Cell(7, 7))
  |> list_extra.filter_all([is_on_board, is_square_empty(board, _)])
  |> set.from_list
}

/// rules out playspots that require more letters than the rack has
pub fn rack_has_enough_letters(
  board: Board,
  playspot: Playspot,
  rack_size: Int,
) -> Bool {
  list.count(playspot, is_square_empty(board, _)) <= rack_size
}

/// is cell's square off the board or empty?
pub fn is_square_empty(board: Board, cell: Cell) -> Bool {
  case dict.get(board, cell) {
    Error(Nil) -> True
    Ok(Square(None, _)) -> True
    _ -> False
  }
}

/// is cell's square off the board?
fn is_on_board(cell: Cell) -> Bool {
  let Cell(x, y) = cell
  0 <= x && x < board_size && 0 <= y && y < board_size
}

fn show_bonus(bonus: Bonus) -> String {
  case bonus {
    DoubleLetterScore -> "1"
    DoubleWordScore -> "2"
    TripleLetterScore -> "3"
    TripleWordScore -> "4"
  }
}

pub fn pretty_print(board: Board) -> String {
  let cols = "   012345678901234\n"
  let rows =
    list.range(0, board_size - 1)
    |> list.map(fn(y) {
      let i = string.inspect(y) |> string.pad_start(2, " ")
      let row =
        list.range(0, board_size - 1)
        |> list.map(fn(x) {
          case dict.get(board, Cell(x, y)) {
            Ok(Square(Some(Tile(char, _)), _)) -> char
            Ok(Square(None, Some(bonus))) -> show_bonus(bonus)
            // change to be the correct code
            _ -> "_"
          }
        })
        |> string.concat()
      string.join([i, row, i <> "\n"], " ")
    })
    |> string.concat()

  string.concat(["\n", cols, rows, cols])
}
