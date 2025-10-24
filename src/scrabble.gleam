import board
import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import gleam/io
import gleam/string
import io_extra.{debug}
import list_extra
import simplifile.{type FileError, read}
import trie.{type Trie}
import types.{
  type Board, type Cell, type Char, type Cloze, type Playspot, type Rack, Cell,
  DoubleLetterScore, DoubleWordScore, Square, Tile, TripleLetterScore,
  TripleWordScore,
}

pub fn main(
  rack_str: String,
  num_blanks: Int,
  board_str: String,
  dictionary: Trie,
  // make ahead of time
) -> Result(List(#(String, Playspot, Int)), String) {
  case board.parse_rack(rack_str, num_blanks), board.parse_board(board_str) {
    Ok(rack), Ok(board) -> Ok(calculate_plays(board, rack, dictionary))
    Error(err), _ -> Error(err)
    _, Error(err) -> Error(err)
  }
}

pub fn precompute_dictionary(words_path: String) -> Result(Trie, FileError) {
  read(words_path)
  |> result.map(trie.build)
}

pub fn calculate_plays(
  board: Board,
  rack: Rack,
  dictionary: Trie,
) -> List(#(String, Playspot, Int)) {
  all_playspots(board, rack)
  |> list_extra.map(get_cloze(board, _))
  |> list_extra.group(by: pair.first, transform: pair.second)
  |> dict.fold([], fn(acc, cloze: Cloze, playspots: List(Playspot)) {
    let words: List(String) = trie.explore(dictionary, cloze, rack)
    list_extra.append(list_extra.pairs(words, playspots), acc)
  })
  |> list.filter_map(score(_, board, dictionary))
  |> list.sort(fn(a, b) {
    let #(_, _, a) = a
    let #(_, _, b) = b
    int.compare(b, a)
  })
}

/// produces every single legal place to play a word. does not check against
/// dictionary.
fn all_playspots(board: Board, rack: Rack) -> List(Playspot) {
  let shortest_word = 2
  let longest_word = 15
  let rack_size = list.length(rack.chars) + rack.num_blanks
  let word_sizes = list.range(shortest_word, longest_word)
  let adjacent = board.build_adjacent_cells(board)
  list_extra.flat_map(word_sizes, fn(word_size) {
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
        list.map(cells, fn(x) { Cell(c + x, r) })
      })

    let vwords =
      pairs
      |> list_extra.map(fn(cell) {
        let Cell(c, r) = transpose_cell(cell)
        list.map(cells, fn(y) { Cell(c, r + y) })
      })

    list_extra.append(hwords, vwords)
  })
  |> list_extra.filter_all([
    is_not_subword(board, _),
    list.any(_, set.contains(adjacent, _)),
    list.any(_, board.is_square_empty(board, _)),
    board.rack_has_enough_letters(board, _, rack_size),
  ])
}

fn transpose_cell(cell: Cell) -> Cell {
  let Cell(x, y) = cell
  Cell(y, x)
}

/// confirms that the letter before and after playspot is either empty or off the board.
/// TODO this might be buggy
fn is_not_subword(board: Board, playspot: Playspot) -> Bool {
  case list.first(playspot), list.last(playspot) {
    Ok(Cell(x1, y1) as c1), Ok(Cell(x2, y2) as c2) ->
      case x1 == x2, y1 == y2 {
        True, False -> [Cell(x1, y1 - 1), Cell(x2, y2 + 1)]
        False, True -> [Cell(x1 - 1, y1), Cell(x2 + 1, y2)]
        _, _ ->
          panic as {
              "playspots must have 1 and only 1 axis. found "
              <> string.inspect(c1)
              <> " "
              <> string.inspect(c2)
            }
      }
    _, _ -> panic as "impossible zero length playspot"
  }
  |> list.all(board.is_square_empty(board, _))
}

/// self-explanatory
fn get_cloze(board: Board, playspot: Playspot) -> #(Cloze, Playspot) {
  let cloze =
    list.map(playspot, fn(cell) {
      case dict.get(board, cell) {
        Ok(Square(Some(Tile(char, _)), _)) -> Ok(char)
        _ -> Error(Nil)
      }
    })
  #(cloze, playspot)
}

/// scores it according to scrabble scoring rules
/// taking into account bonuses, cross-axis words, and bingos
/// by construction, expects the main-axis word to be dictionary legal;
/// however, will disqualify words based on legality of cross-axis words
fn score(
  word_playspot: #(String, Playspot),
  board: Board,
  dictionary: Trie,
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
            |> trie.member(dictionary, _)
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
    Error(Nil) -> acc
    Ok(Square(None, _)) -> acc
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

/// straightforwardly returns the score for the played word
fn score_word(word: List(#(Char, Cell)), board: Board) -> Int {
  let #(total, multiplier, tiles) =
    list.fold(word, #(0, 1, 0), fn(total_bonus, char_cell) {
      let #(total, multiplier, tiles) = total_bonus
      let #(char, cell) = char_cell
      let points = board.char_to_points(char)
      case dict.get(board, cell) {
        Error(Nil) -> panic as "every cell of board must have square"
        Ok(Square(None, None)) -> #(points, multiplier, tiles + 1)
        Ok(Square(None, Some(bonus))) ->
          case bonus {
            DoubleLetterScore -> #(points * 2 + total, multiplier, tiles + 1)
            DoubleWordScore -> #(points + total, 2 * multiplier, tiles + 1)
            TripleLetterScore -> #(points * 3 + total, multiplier, tiles + 1)
            TripleWordScore -> #(points + total, 3 * multiplier, tiles + 1)
          }
        Ok(Square(Some(Tile(_, points)), _)) -> #(
          total + points,
          multiplier,
          tiles,
        )
      }
    })

  debug(#( list.map(word, pair.first) |> string.concat, list.map(word, pair.second), total, multiplier), "A")

  total
  * multiplier
  + {
    case tiles {
      7 -> 50
      _ -> 0
    }
  }
  |> debug("B")
}
