import gleam/dict.{type Dict}
import gleam/option.{None, Some}
import types.{type Char}

pub type Trie {
  Trie(terminal: Bool, children: Dict(Char, Trie))
}

pub fn empty() -> Trie {
  Trie(False, dict.new())
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
