import gleam/dict
import gleam/list
import gleam/option.{None, Some}
import gleam/string

import types.{
  type Board, type Char, type Rack, Cell, DoubleLetterScore, DoubleWordScore,
  Rack, Square, Tile, TripleLetterScore, TripleWordScore,
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
    _ -> panic as "unrecognized character"
  }
}

/// are all chars in word a-z, A-Z, 0-9, or _?
pub fn is_alphanum(word: String) -> Bool {
  word
  |> string.to_utf_codepoints
  |> list.all(fn(codepoint) {
    let int = string.utf_codepoint_to_int(codepoint)
    case int {
      49 | 50 | 51 | 52 | 95 -> True
      x if 65 <= x && x <= 90 -> True
      x if 97 <= x && x <= 122 -> True
      _ -> False
    }
  })
}

pub fn parse_board(board: String) -> Result(Board, String) {
  case string.byte_size(board), is_alphanum(board) {
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
