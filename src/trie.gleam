import function_extra.{compose}
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

pub fn discover(
  dictionary: Dictionary,
  cloze: Cloze,
  rack: Rack,
) -> List(String) {
  let Dictionary(forward, backward) = dictionary
  case list.split_while(cloze, result.is_error) {
    #(_, []) -> explore(forward, cloze, rack)
    #(before, [Ok(char), ..after]) ->
      explore(backward, [Ok(char), ..list.reverse(before)], rack)
    // PULL THIS OUT OF COMPOSE -- WE NEED DIG PREFIX BELOW
    //|> list.filter_map(compose(dig(forward, _), string.reverse))
    //|> list_extra.flat_map(explore(_, after,,_))
    _ -> panic as "unreachable state reached"
    //
  }
}

pub fn explore(trie: Trie, cloze: Cloze, rack: Rack) -> List(String) {
  explore_inner([#(trie, cloze, rack, [])], [])
}

// TODO redo the comments -- the logic changed
pub fn explore_inner(
  entry_points: List(#(Trie, Cloze, Rack, List(Char))),
  acc: List(String),
) -> List(String) {
  case entry_points {
    [] -> acc
    [entry, ..tail_entries] -> {
      let #(trie, cloze, rack, trail) = entry
      case cloze {
        [] ->
          case trie.terminal {
            True -> [list.reverse(trail) |> string.concat(), ..acc]
            False -> explore_inner(tail_entries, acc)
          }
        [Ok(char), ..cloze] ->
          case dict.get(trie.children, char) {
            // cloze head not in trie: dead end
            Error(Nil) -> explore_inner(tail_entries, acc)
            // cloze head in trie: recurse
            Ok(trie) ->
              explore_inner(
                [#(trie, cloze, rack, [char, ..trail]), ..tail_entries],
                acc,
              )
          }
        // cloze head unspecified
        [Error(Nil), ..cloze] ->
          dict.to_list(trie.children)
          |> list.filter_map(fn(tup) {
            let #(key, trie) = tup
            case list_extra.pop(rack.chars, key) {
              // key in trie not found in rack but rack contains > 1 blanks: recurse with 1 fewer blank
              None if rack.num_blanks > 0 ->
                Ok(
                  #(trie, cloze, Rack(rack.chars, rack.num_blanks - 1), [
                    key,
                    ..trail
                  ]),
                )
              // key in trie not found in rack: dead end
              None -> Error(Nil)
              // key in trie found in rack: recurse
              Some(rack_chars) ->
                Ok(
                  #(trie, cloze, Rack(rack_chars, rack.num_blanks), [
                    key,
                    ..trail
                  ]),
                )
            }
          })
          |> list_extra.append(tail_entries)
          |> explore_inner(acc)
      }
    }
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
