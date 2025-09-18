import gleam/dict.{type Dict}
import gleam/function
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
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
}

pub type Rack {
  Rack(chars: List(Char), num_blanks: Int)
}

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

const board_size = 15

pub fn calculate_plays(
  board: Board,
  rack: Rack,
  dictionary: Dictionary,
) -> List(#(String, Int)) {
  all_playspots(board, rack)
  |> list_extra.map(get_cloze(board, _))
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

fn build_adjacent_cells(board: Board) -> Set(Cell) {
  dict.keys(board)
  |> list.flat_map(fn(cell) {
    let Cell(x, y) = cell
    [Cell(x, y + 1), Cell(x + 1, y), Cell(x, y - 1), Cell(x - 1, y)]
  })
  |> list_extra.filter(is_on_board)
  |> list_extra.filter(is_square_empty(board, _))
  |> set.from_list
}

fn all_playspots(board: Board, rack: Rack) -> List(Playspot) {
  let shortest_word = 2
  let longest_word = 15
  let rack_size = list.length(rack.chars) + rack.num_blanks
  let word_sizes = list.range(shortest_word, longest_word)
  let adjacent = build_adjacent_cells(board)
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
      |> list_extra.map(fn(cell) {
        let Cell(c, r) = cell
        list_extra.map(cells, fn(x) { Cell(c + x, r) })
      })

    let vwords =
      pairs
      |> list_extra.map(fn(cell) {
        let Cell(c, r) = transpose_cell(cell)
        list_extra.map(cells, fn(y) { Cell(c, r + y) })
      })

    list_extra.append(hwords, vwords)
  })
  |> list_extra.filter(fn(playspot) {
    is_not_subword(board, playspot)
    && list.any(playspot, set.contains(adjacent, _))
    && list.any(playspot, is_square_empty(board, _))
    && list.count(playspot, is_square_empty(board, _)) <= rack_size
  })
}

fn transpose_cell(cell: Cell) -> Cell {
  let Cell(x, y) = cell
  Cell(y, x)
}

fn pop_tile(char: Char, rack: Rack) -> #(Option(Tile), Rack) {
  list.fold_right(rack, #(None, []), fn(acc, val) {
    case acc {
      #(Some(_) as tile, rack) -> #(tile, [char, ..rack])
      #(None, rack) -> {
        case val {
          None -> #(Some(Tile(val, 0)), rack)
        }
      }
    }
  })
}

/// confirms that the letter before and after playspot is either empty or off the board.
fn is_not_subword(board: Board, playspot: Playspot) -> Bool {
  case list.first(playspot), list.last(playspot) {
    Ok(Cell(x1, y1) as cell1), Ok(Cell(x2, y2) as cell2) ->
      case x1 < x2, y1 < y2 {
        True, False -> [Cell(x1 - 1, y1), Cell(x2 + 1, y2)]
        False, True -> [Cell(x1, y1 - 1), Cell(x2, y2 + 2)]
        _, _ -> panic as "playspots must have 1 and only 1 axis"
      }
    _, _ -> panic as "impossible zero length playspot"
  }
  |> list.all(is_square_empty(board, _))
}

fn is_square_empty(board: Board, cell: Cell) -> Bool {
  case dict.get(board, cell) {
    Error(Nil) -> True
    Ok(Square(None, _)) -> True
    _ -> False
  }
}

fn is_on_board(cell: Cell) -> Bool {
  let Cell(x, y) = cell
  0 <= x && x < board_size && 0 <= y && y < board_size
}

fn get_cloze(board: Board, playspot: Playspot) -> #(Cloze, Playspot) {
  let cloze =
    list_extra.map(playspot, fn(cell) {
      case dict.get(board, cell) {
        Ok(Square(Some(Tile(char, _)), _)) -> Ok(char)
        _ -> Error(Nil)
      }
    })
  #(cloze, playspot)
}

// NOT DONE. WE NEED TO FILTER OUT ALL WORDS THAT YOU COULD NOT PLAY WITH RACK
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
  // TODO filter words that you could not play with your rack
}

fn score(
  word_playspot: #(String, Playspot),
  board: Board,
  dictionary: Dictionary,
) -> Result(#(String, Int), Nil) {
  let #(word, playspot) = word_playspot
  todo
}
