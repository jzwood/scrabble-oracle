import gleeunit
import trie
import types.{Rack}

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
ABACKS
ABANDS
"

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn main_test() {
  let forward = trie.build(test_words)
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

  let cloze = [Ok("A"), Ok("B"), Ok("A"), Error(Nil), Error(Nil), Error(Nil)]
  let rack = Rack(["N", "D", "S"], 0)
  assert ["ABANDS"] == trie.explore(forward, cloze, rack)

  let cloze = [Error(Nil), Ok("B"), Ok("A"), Ok("N"), Error(Nil), Error(Nil)]
  let rack = Rack(["A", "D", "S"], 0)
  assert ["ABANDS"] == trie.explore(forward, cloze, rack)

  let cloze = [Error(Nil), Error(Nil), Error(Nil), Error(Nil), Error(Nil)]
  let rack = Rack(["A", "A", "R", "T", "I"], 0)
  assert ["AARTI"] == trie.explore(forward, cloze, rack)
}
