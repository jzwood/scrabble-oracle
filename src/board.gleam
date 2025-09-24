import gleam/dict
import gleam/list
import gleam/option.{None, Some}
import gleam/string

import types.{
  type Board, type Bonus, type Char, Cell, DoubleLetterScore, DoubleWordScore,
  Square, Tile, TripleLetterScore, TripleWordScore,
}

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
    1__2___1___2___
    __2___1_1___2__
    _2___3___3___2_
    4__1___4___1__4
    "
    |> string.replace(" ", "")
    |> string.replace("\n", "")
    |> string.trim

  let assert Ok(board) = parse_board(board)

  board
}

pub fn char_to_points(char: Char) -> Int {
  case char {
    "a" -> 0
    "b" -> 0
    "c" -> 0
    "d" -> 0
    _ -> 0
  }
}

pub fn is_alphanum(codepoint: UtfCodepoint) -> Bool {
  let int = string.utf_codepoint_to_int(codepoint)
  case int {
    49 | 50 | 51 | 52 | 95 -> True
    x if 65 <= x && x <= 90 -> True
    x if 97 <= x && x <= 122 -> True
    _ -> False
  }
}

pub fn parse_board(board: String) -> Result(Board, String) {
  // Okay, we need to be able to input a board with a blank, maybe a regular
  // letter is lowercase while a blank is uppercase??

  let codepoints = string.to_utf_codepoints(board)

  case string.byte_size(board), list.all(codepoints, is_alphanum) {
    _, False -> Error("board must be a-z, A-Z, 1-4, or _")
    225, True -> {
      let board =
        board
        |> string.to_graphemes
        |> list.window(15)
        |> list.index_map(fn(row, y) {
          row
          |> list.index_map(fn(cell, x) {
            let bonus = case cell {
              "1" -> Some(DoubleLetterScore)
              "2" -> Some(DoubleWordScore)
              "3" -> Some(TripleLetterScore)
              "4" -> Some(TripleWordScore)
              _ -> None
            }

            let tile = case cell {
              "_" -> None
              char -> Some(Tile(string.lowercase(char), char_to_points(char)))
            }

            #(Cell(x, y), Square(tile, bonus))
          })
        })
        |> list.flatten
        |> dict.from_list

      Ok(board)
    }
    _, _ -> Error("board must be exactly 225 characters")
  }
}
