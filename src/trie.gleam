import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode.{type DecodeError}
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import types.{type Char, type Rack}

pub type Trie {
  Trie(terminal: Bool, children: Dict(Char, Trie))
}

pub type Dictionary {
  Dictionary(forward: Trie, backward: Trie)
}

@external(javascript, "./unsafe_trie.mjs", "build")
pub fn unsafe_build_trie(words: String) -> Dynamic

pub fn decode_trie() -> decode.Decoder(Trie) {
  use <- decode.recursive
  use terminal <- decode.field("terminal", decode.bool)
  use children <- decode.field(
    "children",
    decode.dict(decode.string, decode_trie()),
  )
  decode.success(Trie(terminal, children))
}

pub fn empty() -> Trie {
  Trie(False, dict.new())
}

pub fn build(words: String) -> Trie {
  case decode.run(unsafe_build_trie(words), decode_trie()) {
    Ok(trie) -> {
      trie
    }
    Error(reasons) -> {
      let errors = reasons |> string.inspect
      panic as errors
    }
  }
}

//pub fn build_dictionary(words: List(String)) -> Dictionary {
//list.fold(words, Dictionary(empty(), empty()), fn(acc, word) {
//let Dictionary(forward, backward) = acc
//let chars = string.to_graphemes(word)
//let forward = insert(forward, chars)
//let backward =
//list.scan(chars, [], list.prepend) |> list.fold(backward, insert)
//Dictionary(forward, backward)
//})
//}

pub fn build_dictionary(words: String) -> Dictionary {
  let forward = build(words)

  let backward =
    string.split(words, "\n")
    |> list.flat_map(fn(word) {
      string.to_graphemes(word)
      |> list.scan([], list.prepend)
      |> list.map(string.join(_, ""))
    })
    |> string.join("\n")
    |> build

  Dictionary(forward, backward)
}

pub fn insert_old(trie: Trie, word: List(Char)) -> Trie {
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

pub fn insert(trie: Trie, word: List(Char)) -> Trie {
  case word {
    [] -> Trie(True, trie.children)
    [char, ..tail] -> {
      dict.get(trie.children, char)
      |> result.unwrap(empty())
      |> insert(tail)
      |> dict.insert(trie.children, char, _)
      |> Trie(trie.terminal, _)
    }
  }
}

pub fn fast_insert(trie: Trie, word: String) -> Trie {
  case string.pop_grapheme(word) {
    Error(Nil) -> Trie(True, trie.children)
    Ok(#(char, tail)) ->
      dict.get(trie.children, char)
      |> result.unwrap(empty())
      |> fast_insert(tail)
      |> dict.insert(trie.children, char, _)
      |> Trie(trie.terminal, _)
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
