import board
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/set
import gleam/string
import gleeunit
import io_extra.{debug}
import scrabble
import types.{Cell, Square, Tile}

import simplifile.{read, write}
import trie

pub fn main() -> Nil {
  gleeunit.main()
}

const words_path = "./assets/word_list.txt"

const board = "
  4__B___N___1__4
  JOULES_A___QAT_
  OY2E_T1R1___B__
  1__E_A_CONE2O_1
  _RUDER___ADORN_
  _3___L_PIG__T3_
  _V1__I1U1___I__
  MILLINER___1OOF
  _V1__G1G1___NO_
  _A___3_E_3___Z_
  ___NEXUS__2__E_
  1_MAT__1___2_D1
  __E___1_1___2__
  _2W__3___3___2_
  WAS1___4___1__4
  "

//const board = "
    //4__1___4___1__4
    //_2___3___3___2_
    //__2___1_1___2__
    //1__2___1___2__1
    //____2_____2____
    //_3___3___3___3_
    //__1___1_1___1__
    //4__1__BA___1__4
    //__1___1_1___1__
    //_3___3___3___3_
    //____2_____2____
    //1__2___1___2___
    //__2___1_1___2__
    //_2___3___3___2_
    //4__1___4___1__4
    //"

//const rack = "FEASTTH"
const rack = "HELLO"

// gleeunit test functions end in `_test`
pub fn main_test() {
  io.println("reading words: ongoing")
  let assert Ok(words) = read(from: words_path)
  io.println("reading words: done")

  io.println("building dictionary: ongoing")
  let dict = trie.build(words)
  io.println("building dictionary: done")

  let assert Ok(words) = scrabble.main(rack, 0, board, dict)

  let assert Ok(board) = board.parse_board(board)
  board.pretty_print(board)
  |> io.println

  //board.build_adjacent_cells(board)
  //|> set.to_list()
  //|> list.map(fn(cell) { #(cell, Square(Some(Tile("X", 0)), None)) })
  //|> dict.from_list
  //|> board.pretty_print
  //|> io.println

  words
  |> list.take(50)
  |> list.map(fn(tup) {
    let #(word, playspots, points) = tup
    let assert [Cell(x1, y1), ..] = playspots
    let assert [Cell(x2, y2), ..] = playspots |> list.reverse()
    io.println(string.join(
      [
        word,
        int.to_string(points),
        "(" <> int.to_string(x1) <> ",",
        int.to_string(y1) <> ")",
        "(" <> int.to_string(x2) <> ",",
        int.to_string(y2) <> ")",
      ],
      " ",
    ))
  })
}
