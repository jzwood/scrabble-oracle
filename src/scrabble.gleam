import gleam/io
import gleam/list
import gleam/dict.{type Dict}
import gleam/pair
import gleam/option.{type Option}
import list_extra

pub fn main() -> Nil {
  io.println("Hello from scrabble!")
}

pub type Tile {
  Tile(char: String, value: Int)
  Blank
}
pub type Rack = List(Tile)
pub type Bonus {
 DoubleLetterScore
 TripleLetterScore
 DoubleWordScore
 TripleWordScore
}
pub type Square {
  Square(tile: Option(Tile), bonus: Option(Bonus))
}
pub type Cell {
  Cell(x: Int, y: Int)
}
pub type Playspot = List(Cell)
pub type Play = List(#(Cell, Square))
pub type Board = Dict(Cell, Square)
pub type ClozeChar {
  Empty
  Char(char: String)
}
pub type Trie {
  Leaf
  Node(node: String, children: Trie)
}
pub type Cloze = List(String) // "__X__R"

// scoring

pub fn calculate_plays(board: Board, rack: Rack, dictionary) {
  all_playspots(board)
  |> list.map(get_cloze(board, _))
  |> list_extra.group(by: pair.first, transform: pair.second)
  |> dict.fold([], fn(acc, cloze: Cloze, playspots: List(Playspot)) {
    let words: List(String) = cloze_words(cloze, rack, dictionary)
    [pairs(words, playspots), ..acc]
  })
  |> list.flatten
  |> list.filter(is_valid(_, board, dictionary))
  //|> list.map(score(_, board))
}

fn all_playspots(board: Board) -> List(Playspot) {

}

fn get_cloze(board: Board, playspot: Playspot) -> #(Cloze, Playspot) {

}

fn cloze_words(cloze: Cloze, rack: Rack, dictionary) -> List(String) {

}

fn is_valid(cloze_playspot: #(String, Playspot), board: Board, dictionary) {

}

fn score(word_playspot: #(String, Playspot), ) {

}

fn pairs(xs: List(a), ys: List(b)) -> List(#(a, b)) {
  list.flat_map(xs, fn(x) {
    list.map(ys, fn(y) {
      #(x, y)
    })
  })
}
