import gleam/io
import gleam/list
import gleam/string
import gleeunit
import scrabble
import simplifile.{read, write}
import trie

pub fn main() -> Nil {
  gleeunit.main()
}

const words_path = "./assets/word_list.txt"

//const words_path = "./assets/test_words.txt"
const trie_dest = "./assets/trie.gleam"

const board = "
  4__B___N___1__4
  JOULES_A___QAT_
  OY2E_T1R1___B__
  1__E_A_CONE2O_1
  _RUDER___ADORN_
  _3___L_PIG__T3_
  _V1__I1U1___I__
  MILLINER___1OOF
  _V1__G1G1___NO_
  _A___3_E_3___Z_
  ___NEXUS__2__E_
  1_MAT__1___2_D_
  __E___1_1___2__
  _2W__3___3___2_
  WAS1___4___1__4
  "

const rack = "FEASTTH"

// gleeunit test functions end in `_test`
pub fn main_test_ignore() {
  io.println("reading words: ongoing")
  let assert Ok(words) = read(from: words_path)
  io.println("reading words: done")

  io.println("building dictionary: ongoing")
  //let dict =
    //string.split(words, "\n")
    //|> trie.build_dictionary()
  //|> scrabble.build_cloze_dictionary
  io.println("building dictionary: done")
  //string.inspect(dict)
  //|> write(trie_dest, _)
  //let assert Ok(words) = scrabble.main(rack, 0, board, dict)

  //words
  //|> string.inspect
  //|> io.println
}
