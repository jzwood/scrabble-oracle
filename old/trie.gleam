import gleam/dict
import gleam/result
import gleam/string

pub type Char = String
pub type Trie {
  Trie(terminal: Bool, children: Dict(Char, Trie))
}

fn empty() -> Trie {
  Trie(False, dict.new())
}

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

pub fn insert(trie: Trie, word: List(Char)) -> Trie {
  case word {
    [] -> Trie(True, trie.children)
    [char, ..tails] ->
      dict.get(trie.children, char)
      |> result.unwrap(empty())
      |> insert(tail)
      |> dict.insert(trie.children, char, _)
      |> Trie(trie.terminal, _)
  }
}

pub fn insert(trie: Trie, word: List(Char)) -> Trie {
  case word {
    [] -> Trie(True, trie.children)
    [char, ..tail] -> {
      Trie(
        trie.terminal,
        dict.upsert(trie.children, char, fn(maybe_trie) {
          case maybe_trie {
            None -> insert(empty(), tail)
            Some(trie) -> insert(trie, tail)
          }
        }),
      )
    }
  }
}

