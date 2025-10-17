import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode.{type Decoder}
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import list_extra
import types.{type Char, type Cloze, type Rack, Rack}

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

pub fn member(trie: Trie, word: String) -> Bool {
  case string.pop_grapheme(word) {
    Error(Nil) -> trie.terminal
    Ok(#(char, tail)) ->
      case dict.get(trie.children, char) {
        Ok(trie) -> member(trie, tail)
        Error(Nil) -> False
      }
  }
}

pub fn walk_up(trie: Trie, cloze: Cloze, rack: Rack) -> List(String) {
  //let start_char =
  todo
}

// THINK ABOUT HOW TO MAKE THIS MORE GENERIC SUCH THAT WALK_UP AND IS_MEMBER
// COULD BOTH BE IMPLEMENTED WITH IT. CRITICALLY, WE CARE ABOUT WHETHER TRIE IS
// LEAF NODE, AKA dict.size(trie.children) == 0
// HMMM IS THAT TRUE???
pub fn explore(
  trie: Trie,
  cloze: Cloze,
  rack: Rack,
  trail: List(Char),
) -> List(String) {
  case cloze {
    [] ->
      case trie.terminal {
        True -> [list.reverse(trail) |> string.concat()]
        False -> []
      }
    [Ok(char), ..cloze] ->
      case dict.get(trie.children, char) {
        // cloze head not in trie: dead end
        Error(Nil) -> []
        // cloze head in trie: recurse
        Ok(trie) -> explore(trie, cloze, rack, [char, ..trail])
      }
    // cloze head unspecified
    [Error(Nil), ..cloze] ->
      dict.to_list(trie.children)
      |> list.flat_map(fn(tup) {
        let #(key, trie) = tup
        case list_extra.pop(rack.chars, key) {
          // key in trie not found in rack but rack contains > 1 blanks: recurse with 1 fewer blank
          None if rack.num_blanks > 0 ->
            explore(trie, cloze, Rack(rack.chars, rack.num_blanks - 1), [
              key,
              ..trail
            ])
          // key in trie not found in rack: dead end
          None -> []
          // key in trie found in rack: recurse
          Some(rack_chars) ->
            explore(trie, cloze, Rack(rack_chars, rack.num_blanks), [
              key,
              ..trail
            ])
        }
      })
  }
}

pub fn dig(trie: Trie, path: String) -> Result(Trie, Nil) {
  case string.pop_grapheme(path) {
    Error(Nil) -> Ok(trie)
    Ok(#(char, path)) ->
      dict.get(trie.children, char)
      |> result.try(dig(_, path))
  }
}
// compare trie.children keys against first char

// CLOZE: ___A_B__C
// CLOZE: Z__A_B__C
// rack: ABCD
// trie: {x, y, z}
//
// explore: Trie, word -> true
