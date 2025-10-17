import gleam/dict
import gleam/result
import gleam/string

pub fn build_dictionary(words: List(String)) -> Dictionary {
  list.fold(words, Dictionary(empty(), empty()), fn(acc, word) {
    let Dictionary(forward, backward) = acc
    let chars = string.to_graphemes(word)
    let forward = insert(forward, chars)
    let backward =
      list.scan(chars, [], list.prepend) |> list.fold(backward, insert)
    Dictionary(forward, backward)
  })
}

fn empty() -> Trie {
  Trie(False, dict.new())
}

pub fn insert(trie: Trie, word: String) -> Trie {
  case string.pop_grapheme(word) {
    Error(Nil) -> Trie(True, trie.children)
    Ok(#(char, tail)) ->
      dict.get(trie.children, char)
      |> result.unwrap(empty())
      |> insert(tail)
      |> dict.insert(trie.children, char, _)
      |> Trie(trie.terminal, _)
  }
}
