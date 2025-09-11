import gleam/dict.{type Dict}
import gleam/function
import gleam/io
import gleam/list
import gleam/option.{type Option}
import gleam/order.{type Order}
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import gleam/string
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

//pub type Play = List(#(Cell, Square))

pub type Board =
  Dict(Cell, Square)

pub type Cloze =
  List(Result(String, Nil))

// "__X__R"
pub type ClozeKey {
  Key(length: Int, index: Int, char: String)
  DefaultKey(length: Int)
}

pub type Dictionary {
  Dictionary(clozes: Dict(ClozeKey, List(String)), words: Set(String))
}

const board_size = 15

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
    list_extra.append(pairs(words, playspots), acc)
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
  //hwords = [[Coordinate (r, c + x) | x <- [0 .. (ws - 1)]] | r <- [0 .. 14], c <- [0 .. (15 - ws)], ws <- [2 .. 15]]
  //vwords = [[Coordinate (r + y, c) | y <- [0 .. (ws - 1)]] | c <- [0 .. 14], r <- [0 .. (15 - ws)], ws <- [2 .. 15]]

  let shortest_word = 2
  let longest_word = 15
  let word_sizes = list.range(shortest_word, longest_word)
  list.flat_map(word_sizes, fn(word_size) {
    let rows = list.range(0, longest_word - 1)
    // every row
    let cols = list.range(0, longest_word - word_size)
    // every col where word fits

    pairs(rows, cols)
    |> list.flat_map(fn(tup) {
      let #(r, c) = tup
      let cells = list.range(0, word_size - 1)
      let hwords = list.map(cells, fn(x) { Cell(r, c + x) })
      // get straight on (x, y) vs (r, c)

      let #(c, r) = tup
      let vwords = list.map(cells, fn(y) { Cell(r + y, c) })

      [hwords, vwords]
    })
  })
}

fn get_cloze(board: Board, playspot: Playspot) -> #(Cloze, Playspot) {
  todo
}

fn cloze_words(cloze: Cloze, rack: Rack, dictionary: Dictionary) -> List(String) {
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

fn pairs(xs: List(a), ys: List(b)) -> List(#(a, b)) {
  list.flat_map(xs, fn(x) { list.map(ys, fn(y) { #(x, y) }) })
}

fn pairs_by(xs: List(a), ys: List(b), fxn: fn(a, b) -> c) -> List(c) {
  list.flat_map(xs, fn(x) { list.map(ys, fn(y) { fxn(x, y) }) })
}
