type Tile {
  Letter(char: String, value: Int)
  Blank
}

type Rack {
  Rack(tiles: List(Tile))
}

type Board = Dict(#(Int, Int), value)
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

}

fn get_cloze(board, playspot) {

}

fn close_words(cloze, rack, dictionary) {

}

fn is_valid(word, board, dictionary) {

}

fn pairs(xs, ys) {
  list.flat_map(xs, fn(x) {
    list.map(ys, y)
    { #(x, y) }
  })
}
