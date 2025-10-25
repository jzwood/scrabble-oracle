import gleam/string
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

pub fn build_test() {
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

pub fn member_test() {
  let forward = trie.build(test_words)
  assert trie.member(forward, "AA")
  assert trie.member(forward, "AA")
  assert trie.member(forward, "AAHED")
  assert trie.member(forward, "AALII")
  assert trie.member(forward, "AARGH")
  assert trie.member(forward, "AARTI")
  assert trie.member(forward, "ABACA")
  assert trie.member(forward, "ABACI")
  assert trie.member(forward, "ABACK")
  assert trie.member(forward, "ABACS")
  assert trie.member(forward, "ABAFT")
  assert trie.member(forward, "ABAKA")
  assert trie.member(forward, "ABAMP")
  assert trie.member(forward, "ABAND")
  assert trie.member(forward, "ABACKS")
  assert trie.member(forward, "ABANDS")
  assert False == trie.member(forward, string.reverse("AAHED"))
  assert False == trie.member(forward, string.reverse("AALII"))
  assert False == trie.member(forward, string.reverse("AARGH"))
  assert False == trie.member(forward, string.reverse("AARTI"))
  assert False == trie.member(forward, string.reverse("ABACA"))
  assert False == trie.member(forward, string.reverse("ABACI"))
  assert False == trie.member(forward, string.reverse("ABACK"))
  assert False == trie.member(forward, string.reverse("ABACS"))
  assert False == trie.member(forward, string.reverse("ABAFT"))
  assert False == trie.member(forward, string.reverse("ABAKA"))
  assert False == trie.member(forward, string.reverse("ABAMP"))
  assert False == trie.member(forward, string.reverse("ABAND"))
  assert False == trie.member(forward, string.reverse("ABACKS"))
  assert False == trie.member(forward, string.reverse("ABANDS"))
}
