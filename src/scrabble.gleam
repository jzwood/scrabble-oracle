import gleam/dict.{type Dict}
import gleam/function
import gleam/io
import gleam/list
import gleam/option.{type Option}
import gleam/pair
import gleam/string
import list_extra
import tuple_extra

pub fn main() -> Nil {
  io.println("Hello from scrabble!")
}

pub type Tile {
  Tile(char: String, value: Int)
  Blank
}

pub type Rack =
  List(Tile)

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

pub type Playspot =
  List(Cell)

pub type Play =
  List(#(Cell, Square))

pub type Board =
  Dict(Cell, Square)

pub type ClozeChar {
  Empty
  Char(char: String)
}

pub type Trie {
  Leaf
  Node(node: String, children: Trie)
}

pub type Cloze =
  List(String)

// "__X__R"
pub type Dictionary =
  Dict(Int, List(String))

// maybe instead we can do  Dict(Int, Trie) that way we can shortcircuit after
// first known letter

// scoring

pub fn calculate_plays(board: Board, rack: Rack, dictionary: Dictionary) {
  all_playspots(board)
  |> list.map(get_cloze(board, _))
  |> list_extra.group(by: pair.first, transform: pair.second)
  |> dict.fold([], fn(acc, cloze: Cloze, playspots: List(Playspot)) {
    let words: List(String) = cloze_words(cloze, rack, dictionary)
    list_extra.append(pairs(words, playspots), acc)
  })
  |> list.filter(is_valid(_, board, dictionary))
  //|> list.map(score(_, board))
}

fn build_dictionary(words) {
  list.fold(words, dict.new(), fn(acc, word) {
    let length = string.length(word)
    string.to_graphemes(word)
    |> list.index_map(fn(char, index) { #(length, char, index) })
    |> list.prepend(#(length, "", -1))
    |> list_extra.group_inner(function.identity, fn(_) { word }, acc)
  })
}

fn all_playspots(board: Board) -> List(Playspot) {
  todo
}

fn get_cloze(board: Board, playspot: Playspot) -> #(Cloze, Playspot) {
  todo
}

fn cloze_words(cloze: Cloze, rack: Rack, dictionary: Dictionary) -> List(String) {
  todo
}

fn is_valid(
  cloze_playspot: #(String, Playspot),
  board: Board,
  dictionary: Dictionary,
) {
  todo
}

fn score(word_playspot: #(String, Playspot)) {
  todo
}

fn pairs(xs: List(a), ys: List(b)) -> List(#(a, b)) {
  list.flat_map(xs, fn(x) { list.map(ys, fn(y) { #(x, y) }) })
}
