import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import types.{type Char, type Rack}

pub type Trie {
  Trie(terminal: Bool, children: Dict(Char, Trie))
}

pub type Dictionary {
  Dictionary(forward: Trie, backward: Trie)
}

pub fn empty() -> Trie {
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

//pub fn build_dictionary(words: List(String)) -> Trie {
//list.fold(words, empty(), fn(trie, word) {
//let chars = string.to_graphemes(word)
//list.scan(chars, [], list.prepend) |> list.fold(trie, insert)
//})
//}

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

pub fn member(trie: Trie, word: List(Char)) -> Bool {
  case word {
    [] -> trie.terminal
    [char, ..tail] ->
      case dict.get(trie.children, char) {
        Ok(trie) -> member(trie, tail)
        Error(Nil) -> False
      }
  }
}

pub fn explore(trie: Trie, rack: Rack) -> List(String) {
  todo
}
