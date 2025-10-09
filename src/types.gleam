import gleam/dict.{type Dict}
import gleam/option.{type Option}
import gleam/set.{type Set}

pub type Char =
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
