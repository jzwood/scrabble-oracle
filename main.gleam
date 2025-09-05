type Tile {
  Letter(char: String, value: Int)
  Blank
}

type Rack {
  Rack(tiles: List(Tile))
}

type Board =
  Dict(#(Int, Int), value)

type Square {
  Bonus
  Rack
}

// scoring
type Bonus {
  DoubleLetterScore
  TripleLetterScore
  DoubleWordScore
  TripleWordScore
}

pub fn calculate_plays(board, rack, dictionary) {
  all_playspots(board)
  |> list.map(get_cloze(board, _))
  |> list.group(by: pair.first)
  |> dict.fold([], fn(acc, cloze, tuple) {
    let words = cloze_words(cloze, rack, dictionary)
    let playspots = pair.second(tuple)
    [pairs(playspots, words), ..acc]
  })
  |> list.flatten
  |> list.filter(is_valid(_, board, dictionary))
}

fn all_playspots(board) {
  todo
}

fn get_cloze(board, playspot) {
  todo
}

fn close_words(cloze, rack, dictionary) {
  todo
}

fn is_valid(word, board, dictionary) {
  todo
}

fn pairs(xs, ys) {
  list.flat_map(xs, fn(x) {
    list.map(ys, y)
    { #(x, y) }
  })
}
