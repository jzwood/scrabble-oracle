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

pub fn main_test() {
  io.println("reading words: ongoing")
  let assert Ok(words) = read(from: words_path)
  io.println("reading words: done")
  let dict = trie.build(words)
}
