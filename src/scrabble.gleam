import gleam/dict.{type Dict}
import gleam/function
import gleam/io
import gleam/list
import gleam/option.{type Option, Some}
import gleam/pair
import gleam/result
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

pub type Cloze =
  List(Option(#(String, Int)))

// "__X__R"
pub type Dictionary =
  Dict(#(Int, Int, String), List(String))

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

fn build_default_key(length) {
  #(length, -1, "")
}

fn build_key(length, cloze_char) {
  let #(char, index) = cloze_char
  #(length, index, char)
}

// cloze length, index of first known letter, letter List(String) // word list
fn build_dictionary(words: List(String)) -> Dictionary {
  list.fold(words, dict.new(), fn(acc, word) {
    let length = string.length(word)
    string.to_graphemes(word)
    |> list.index_map(fn(char, index) { #(length, index, char) })
    |> list.prepend(build_default_key(length))
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
  let length = list.length(cloze)
  let maybe_key = list.find(cloze, option.is_some)
  let key = case maybe_key {
    Ok(Some(cloze_char)) -> build_key(length, cloze_char)
    _ -> build_default_key(length)
  }
  dict.get(dictionary, key)
  |> result.unwrap([])
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
