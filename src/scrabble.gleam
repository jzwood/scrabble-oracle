import board
import gleam/dict
import gleam/function
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import gleam/string
import list_extra
import types.{
  type Board, type Cell, type Char, type Cloze, type Dictionary, type Playspot,
  type Rack, Cell, DefaultKey, Dictionary, DoubleLetterScore, DoubleWordScore,
  Key, Rack, Square, Tile, TripleLetterScore, TripleWordScore,
}

const board_size = 15

pub fn main(
  rack_str: String,
  num_blanks: Int,
  board_str: String,
  dictionary: Dictionary,
  // make ahead of time
) -> Result(List(#(String, Playspot, Int)), String) {
  case board.parse_rack(rack_str, num_blanks), board.parse_board(board_str) {
    Ok(rack), Ok(board) -> Ok(calculate_plays(board, rack, dictionary))
    Error(err), _ -> Error(err)
    _, Error(err) -> Error(err)
  }
}

pub fn calculate_plays(
  board: Board,
  rack: Rack,
  dictionary: Dictionary,
) -> List(#(String, Playspot, Int)) {
  all_playspots(board, rack)
  |> list_extra.map(get_cloze(board, _))
  |> list_extra.group(by: pair.first, transform: pair.second)
  |> dict.fold([], fn(acc, cloze: Cloze, playspots: List(Playspot)) {
    let words: List(String) =
      cloze_words(cloze, dictionary)
      |> list_extra.filter(rack_compatible(rack, cloze, _))
    list_extra.append(list_extra.pairs(words, playspots), acc)
  })
  |> list.filter_map(score(_, board, dictionary))
}

/// wrapper for can_rack_play_word
fn rack_compatible(rack: Rack, cloze: Cloze, word: String) -> Bool {
  let chars =
    case string.to_graphemes(word) |> list.strict_zip(cloze, _) {
      Error(Nil) -> panic as "cloze and word lengths do not match"
      Ok(pairs) ->
        list.filter_map(pairs, fn(tup) {
          case tup {
            #(Ok(_), _) -> Error(Nil)
            #(Error(Nil), char) -> Ok(char)
          }
        })
    }
    |> list.sort(string.compare)
  let assert True = list_extra.is_sorted(rack.chars, string.compare)
  let assert True = list_extra.is_sorted(chars, string.compare)
  can_rack_play_word(rack, chars)
}

/// does the rack have the necessary tiles to play the word?
/// simliar to `are chars subset of rack?` but also handles blanks
fn can_rack_play_word(rack: Rack, chars: List(Char)) -> Bool {
  case rack, chars {
    _, [] -> True
    Rack([h1, ..t1], blanks), [h2, ..t2] if h1 == h2 ->
      can_rack_play_word(Rack(t1, blanks), t2)
    Rack(chars, blanks), [_, ..tail] if blanks > 0 ->
      can_rack_play_word(Rack(chars, blanks - 1), tail)
    _, _ -> False
  }
}

/// cloze length, index of first known letter, letter List(String) // word list
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

/// finds all cells corresponding to empty squares that are immediately orthogonal to squares with tiles
fn build_adjacent_cells(board: Board) -> Set(Cell) {
  dict.keys(board)
  |> list.flat_map(fn(cell) {
    let Cell(x, y) = cell
    [Cell(x, y + 1), Cell(x + 1, y), Cell(x, y - 1), Cell(x - 1, y)]
  })
  |> list.prepend(Cell(7, 7))
  |> list_extra.filter_all([is_on_board, is_square_empty(board, _)])
  |> set.from_list
}

/// produces every single legal place to play a word. does not check against
/// dictionary.
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
  |> list_extra.filter_all([
    is_not_subword(board, _),
    list.any(_, set.contains(adjacent, _)),
    list.any(_, is_square_empty(board, _)),
    rack_has_enough_letters(board, _, rack_size),
  ])
}

fn transpose_cell(cell: Cell) -> Cell {
  let Cell(x, y) = cell
  Cell(y, x)
}

/// confirms that the letter before and after playspot is either empty or off the board.
fn is_not_subword(board: Board, playspot: Playspot) -> Bool {
  case list.first(playspot), list.last(playspot) {
    Ok(Cell(x1, y1)), Ok(Cell(x2, y2)) ->
      case x1 < x2, y1 < y2 {
        True, False -> [Cell(x1 - 1, y1), Cell(x2 + 1, y2)]
        False, True -> [Cell(x1, y1 - 1), Cell(x2, y2 + 2)]
        _, _ -> panic as "playspots must have 1 and only 1 axis"
      }
    _, _ -> panic as "impossible zero length playspot"
  }
  |> list.all(is_square_empty(board, _))
}

/// rules out playspots that require more letters than the rack has
fn rack_has_enough_letters(
  board: Board,
  playspot: Playspot,
  rack_size: Int,
) -> Bool {
  list.count(playspot, is_square_empty(board, _)) <= rack_size
}

/// is cell's square off the board or empty?
fn is_square_empty(board: Board, cell: Cell) -> Bool {
  case dict.get(board, cell) {
    Error(Nil) -> True
    Ok(Square(None, _)) -> True
    _ -> False
  }
}

/// is cell's square off the board?
fn is_on_board(cell: Cell) -> Bool {
  let Cell(x, y) = cell
  0 <= x && x < board_size && 0 <= y && y < board_size
}

/// self-explanatory
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

/// gets every word list for each cloze (char, index) pair and returns the
/// shortest of these word lists
fn cloze_words(cloze: Cloze, dictionary: Dictionary) -> List(String) {
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

/// scores it according to scrabble scoring rules
/// taking into account bonuses, cross-axis words, and bingos
/// by construction, expects the main-axis word to be dictionary legal;
/// however, will disqualify words based on legality of cross-axis words
fn score(
  word_playspot: #(String, Playspot),
  board: Board,
  dictionary: Dictionary,
) -> Result(#(String, Playspot, Int), Nil) {
  let assert #(word, [Cell(x1, y1), Cell(x2, y2), ..] as playspot) =
    word_playspot
  let xdx = int.absolute_value(y2 - y1)
  let xdy = int.absolute_value(x2 - x1)

  let placement =
    string.to_graphemes(word)
    |> list.zip(playspot)

  list.fold(placement, Some(0), fn(acc, tup) {
    let #(char, cell) = tup
    option.then(acc, fn(total) {
      case cross_word(char, cell, xdx, xdy, board) {
        [] -> panic as "cross word cannot have length 0"
        [_] -> Some(total)
        // cross-axis words with 1 char mean no x-axis word was formed
        word ->
          case
            list.map(word, pair.first)
            |> string.concat
            |> set.contains(dictionary.words, _)
          {
            True -> Some(score_word(word, board) + total)
            False -> None
          }
      }
    })
  })
  |> option.map(fn(total) {
    let points = score_word(placement, board)
    #(word, playspot, total + points)
  })
  |> option.to_result(Nil)
}

fn flood(
  cell: Cell,
  dx: Int,
  dy: Int,
  board: Board,
  acc: List(#(Char, Cell)),
) -> List(#(Char, Cell)) {
  let Cell(x, y) = cell
  let cell = Cell(x + dx, y + dy)
  case dict.get(board, cell) {
    Error(Nil) -> []
    Ok(Square(None, _)) -> []
    Ok(Square(Some(Tile(char, _)), _)) ->
      flood(cell, dx, dy, board, [#(char, cell), ..acc])
  }
}

/// returns cross-axis words, ie words longer than 1 character that are formed
/// by playing the character at that cell
fn cross_word(
  char: Char,
  cell: Cell,
  xdx: Int,
  xdy: Int,
  board: Board,
) -> List(#(Char, Cell)) {
  case dict.get(board, cell) {
    Error(Nil) -> panic as "cross_word cell must start on the board"
    Ok(Square(Some(Tile(char, _)), _)) -> [#(char, cell)]
    // tile already exists on board so you cannot score x-axis points
    Ok(Square(None, _)) ->
      list.flatten([
        flood(cell, -xdx, -xdy, board, []),
        [#(char, cell)],
        flood(cell, xdx, xdy, board, []) |> list.reverse,
      ])
  }
}

fn score_word(word: List(#(Char, Cell)), board: Board) -> Int {
  let #(total, multiplier) =
    list.fold(word, #(0, 1), fn(total_bonus, char_cell) {
      let #(total, multiplier) = total_bonus
      let #(char, cell) = char_cell
      let points = board.char_to_points(char)
      case dict.get(board, cell) {
        Error(Nil) -> panic as "every cell of board must have square"
        Ok(Square(None, None)) -> #(points, multiplier)
        Ok(Square(None, Some(bonus))) ->
          case bonus {
            DoubleLetterScore -> #(total + { points * 2 }, multiplier)
            DoubleWordScore -> #(total + points, 2 * multiplier)
            TripleLetterScore -> #(total + { points * 3 }, multiplier)
            TripleWordScore -> #(total + points, 3 * multiplier)
          }
        Ok(Square(Some(Tile(_, points)), _)) -> #(total + points, multiplier)
      }
    })
  total * multiplier
}
