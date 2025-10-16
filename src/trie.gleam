import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode.{type DecodeError, type Decoder}
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

@external(javascript, "./unsafe_trie.mjs", "buildDictionary")
fn unsafe_build_dictionary(words: String) -> Dynamic

fn decode_trie() -> Decoder(Trie) {
  use <- decode.recursive
  use terminal <- decode.field("terminal", decode.bool)
  use children <- decode.field(
    "children",
    decode.dict(decode.string, decode_trie()),
  )
  decode.success(Trie(terminal, children))
}

fn decode_dictionary() -> Decoder(Dictionary) {
  use forward <- decode.field("forward", decode_trie())
  use backward <- decode.field("forward", decode_trie())
  decode.success(Dictionary(forward, backward))
}

pub fn build_dictionary(words: String) -> Dictionary {
  case decode.run(unsafe_build_dictionary(words), decode_dictionary()) {
    Ok(dictionary) -> {
      dictionary
    }
    Error(reasons) -> {
      let errors = reasons |> string.inspect
      panic as errors
    }
  }
}

//pub fn build_dictionary(words: String) -> Dictionary {
  //io.println("forward: ongoing")
  //let forward = unsafe_build(words)
  //io.println("forward: done")

  //io.println("backward: setup")
  //let backward =
    //string.split(words, "\n")
    //|> list.flat_map(fn(word) {
      //string.to_graphemes(word)
      //|> list.scan([], list.prepend)
      //|> list.map(string.join(_, ""))
    //})
    //|> string.join("\n")
    //|> fn(words) {
        //io.println("backward: setup done")
        //io.println("backward: ongoing")
        //words
      //}
    //|> unsafe_build
    //io.println("backward: done")

  //Dictionary(forward, backward)
//}

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
