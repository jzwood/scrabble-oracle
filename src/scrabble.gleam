import gleam/dict.{type Dict}
import gleam/function
import gleam/io
import gleam/list
import gleam/option.{type Option, None}
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import gleam/string
import list_extra

pub fn main() -> Nil {
  io.println("Hello from scrabble!")
}

type Direction {
  Up
  Right
  Down
  Left
}

type Axis {
  Horizontal
  Vertical
}

type Char =
  String

pub type Tile {
  Tile(char: Char, value: Int)
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

//pub type Play = List(#(Cell, Square))

pub type Board =
  Dict(Cell, Square)

pub type Cloze =
  List(Result(Char, Nil))

// "__X__R"
pub type ClozeKey {
  Key(length: Int, index: Int, char: Char)
  DefaultKey(length: Int)
}

pub type Dictionary {
  Dictionary(clozes: Dict(ClozeKey, List(Char)), words: Set(String))
}

pub fn calculate_plays(
  board: Board,
  rack: Rack,
  dictionary: Dictionary,
) -> List(#(String, Int)) {
  all_playspots(board)
  |> list.map(get_cloze(board, _))
  |> list_extra.group(by: pair.first, transform: pair.second)
  |> dict.fold([], fn(acc, cloze: Cloze, playspots: List(Playspot)) {
    let words: List(String) = cloze_words(cloze, rack, dictionary)
    list_extra.append(list_extra.pairs(words, playspots), acc)
  })
  |> list.filter_map(score(_, board, dictionary))
}

// cloze length, index of first known letter, letter List(String) // word list
pub fn build_cloze_dictionary(words: List(String)) -> Dictionary {
  Dictionary(
    list.fold(words, dict.new(), fn(acc, word) {
      let length = string.length(word)
      string.to_graphemes(word)
      |> list.index_map(fn(char, index) { Key(length, index, char) })
      |> list.prepend(DefaultKey(length))
      |> list_extra.group_inner(function.identity, fn(_) { word }, acc)
    }),
    set.from_list(words),
  )
}

fn all_playspots(board: Board) -> List(Playspot) {
  let shortest_word = 2
  let longest_word = 15
  let word_sizes = list.range(shortest_word, longest_word)
  list.flat_map(word_sizes, fn(word_size) {
    // every row
    let rows = list.range(0, longest_word - 1)
    // every col for start of word where word fits
    let cols = list.range(0, longest_word - word_size)
    // word's char indexes
    let cells = list.range(0, word_size - 1)

    let pairs = list_extra.pairs_by(cols, rows, Cell)

    let hwords =
      pairs
      |> list.map(fn(cell) {
        let Cell(c, r) = cell
        list.map(cells, fn(x) { Cell(c + x, r) })
      })

    let vwords =
      pairs
      |> list.map(fn(cell) {
        let Cell(c, r) = transpose_cell(cell)
        list.map(cells, fn(y) { Cell(c, r + y) })
      })

    list_extra.append(hwords, vwords)
  })
  |> list.filter(is_not_subword(board, _))
  |> list.filter(has_empty_square(board, _))
}

fn transpose_cell(cell: Cell) -> Cell {
  let Cell(x, y) = cell
  Cell(y, x)
}

fn adjacent_cell(cell: Cell, dir: Direction) -> Cell {
  let Cell(x, y) = cell
  case dir {
    Up -> Cell(x, y + 1)
    Right -> Cell(x, y)
    Down -> Cell(x, y - 1)
    Left -> Cell(x - 1, y)
  }
}

// OH SNAP, THIS IS WRONG. WE NEED WORD LENGTH TO GET RIGHT AND BOTTOM CORRECT
// -- NEEDS A RETHINK
fn is_not_subword(board: Board, playspot: Playspot) -> Bool {
  //list.all(dirs, fn(dir) { is_square_empty(board, adjacent_cell(cell, dir)) })
  todo
}

fn has_empty_square(board: Board, playspot: Playspot) -> Bool {
  list.any(playspot, is_square_empty(board, _))
}

fn is_square_empty(board: Board, cell: Cell) -> Bool {
  case dict.get(board, cell) {
    Error(Nil) -> True
    Ok(Square(None, _)) -> True
    _ -> False
  }
}

fn get_cloze(board: Board, playspot: Playspot) -> #(Cloze, Playspot) {
  todo
}

fn cloze_words(cloze: Cloze, rack: Rack, dictionary: Dictionary) -> List(Char) {
  let length = list.length(cloze)
  let assert Ok(words) = dict.get(dictionary.clozes, DefaultKey(length))

  list.index_fold(cloze, words, fn(acc, char, index) {
    result.try(char, fn(char) {
      dict.get(dictionary.clozes, Key(length, index, char))
      |> result.map(fn(words) {
        case list.length(words) < list.length(acc) {
          True -> words
          False -> acc
        }
      })
    })
    |> result.unwrap(acc)
  })
}

fn score(
  word_playspot: #(String, Playspot),
  board: Board,
  dictionary: Dictionary,
) -> Result(#(String, Int), Nil) {
  let #(word, playspot) = word_playspot
  todo
}
