import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/string
import gleam/function
import gleam/option.{type Option}
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import list_extra

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

pub type Cloze =
  List(Result(#(String, Int), Nil))

// "__X__R"
pub type Dictionary {
  Dictionary(
    clozes: Dict(#(Int, Int, String), List(String)),
    words: Set(String),
  )
}

pub fn calculate_plays(board: Board, rack: Rack, dictionary: Dictionary) -> List(#(String, Int)) {
  all_playspots(board)
  |> list.map(get_cloze(board, _))
  |> list_extra.group(by: pair.first, transform: pair.second)
  |> dict.fold([], fn(acc, cloze: Cloze, playspots: List(Playspot)) {
    let words: List(String) = cloze_words(cloze, rack, dictionary)
    list_extra.append(pairs(words, playspots), acc)
  })
  |> list.filter_map(score(_, board, dictionary))
}

fn build_default_key(length) {
  #(length, -1, "")
}

fn build_key(length, cloze_char) {
  let #(char, index) = cloze_char
  #(length, index, char)
}

// cloze length, index of first known letter, letter List(String) // word list
fn build_cloze_dictionary(words: List(String)) -> Dictionary {
  Dictionary(
    list.fold(words, dict.new(), fn(acc, word) {
      let length = string.length(word)
      string.to_graphemes(word)
      |> list.index_map(fn(char, index) { #(length, index, char) })
      |> list.prepend(build_default_key(length))
      |> list_extra.group_inner(function.identity, fn(_) { word }, acc)
    }),
    set.from_list(words),
  )
}

fn all_playspots(board: Board) -> List(Playspot) {
  todo
}

fn get_cloze(board: Board, playspot: Playspot) -> #(Cloze, Playspot) {
  todo
}

fn cloze_words(cloze: Cloze, rack: Rack, dictionary: Dictionary) -> List(String) {
  let length = list.length(cloze)
  let key =
    list.find(cloze, result.is_ok)
    |> result.flatten
    |> result.map(build_key(length, _))
    |> result.unwrap(build_default_key(length))

  dict.get(dictionary.clozes, key)
  |> result.unwrap([])
}

fn score(word_playspot: #(String, Playspot), board: Board, dictionary: Dictionary) -> Result(#(String, Int), Nil) {
  let #(word, playspot) = word_playspot
  todo
}

fn pairs(xs: List(a), ys: List(b)) -> List(#(a, b)) {
  list.flat_map(xs, fn(x) { list.map(ys, fn(y) { #(x, y) }) })
}
