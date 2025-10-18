import gleam/io
import gleam/list
import gleam/string
import gleeunit
import scrabble
import simplifile.{read, write}
import trie.{Dictionary}
import types.{type Cloze, Rack}

const test_words = "
AA
AAHED
AALII
AARGH
AARTI
ABACA
ABACI
ABACK
ABACS
ABAFT
ABAKA
ABAMP
ABAND
"

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn main_test() {
  let Dictionary(forward, _backward) = trie.build_dictionary(test_words)
  let cloze = [Ok("A"), Error(Nil), Ok("A"), Error(Nil), Error(Nil)]
  let rack = Rack(["C", "I", "S", "K"], 2)

  assert ["ABACA", "ABACI", "ABACK", "ABACS", "ABAKA"]
    == trie.explore(forward, cloze, rack)

  let rack = Rack(["C", "I", "S", "K"], 1)
  assert ["ABACI", "ABACK", "ABACS"] == trie.explore(forward, cloze, rack)

  let rack = Rack(["B", "C", "I", "S", "K"], 0)
  assert ["ABACI", "ABACK", "ABACS"] == trie.explore(forward, cloze, rack)

  let cloze = [Ok("A"), Ok("A")]
  let rack = Rack(["A", "A"], 0)
  assert ["AA"] == trie.explore(forward, cloze, rack)
}
