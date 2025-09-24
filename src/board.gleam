import gleam/dict
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

import types.{
  type Board, type Bonus, type Char, Cell, DoubleLetterScore, DoubleWordScore,
  Square, Tile, TripleLetterScore, TripleWordScore,
}

pub fn init_board() -> Board {
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
  parse_board(board)
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

pub fn parse_board(board: String) -> Board {
  // Okay, we need to be able to input a board with a blank, maybe a regular
  // letter is lowercase while a blank is uppercase??
  board
  |> string.replace(" ", "")
  |> string.trim
  |> string.split("\n")
  |> list.index_map(fn(row, y) {
    row
    |> string.to_graphemes
    |> list.index_map(fn(cell, x) {
      let bonus = case cell {
        "1" -> Some(DoubleLetterScore)
        "2" -> Some(DoubleWordScore)
        "3" -> Some(TripleLetterScore)
        "4" -> Some(TripleWordScore)
        _ -> None
      }

      // could get utc codepoint and check it's between a-z or A-Z or "_"
      let tile = case cell {
        "_" -> None
        char -> Some(Tile(string.lowercase(char), char_to_points(char)))
      }

      #(Cell(x, y), Square(tile, bonus))
    })
  })
  |> list.flatten
  |> dict.from_list
}
