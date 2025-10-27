import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import list_extra
import types.{type Char, type Cloze, type Rack, Rack}

pub type Trie {
  Trie(terminal: Bool, children: Dict(Char, Trie))
}

@external(javascript, "./unsafe_trie.mjs", "build")
pub fn build(words: String) -> Trie

pub fn member(trie: Trie, word: String) -> Bool {
  member_inner(trie, string.to_graphemes(word))
}

fn member_inner(trie: Trie, word: List(Char)) -> Bool {
  case word {
    [] -> trie.terminal
    [char, ..tail] ->
      case dict.get(trie.children, char) {
        Ok(trie) -> member_inner(trie, tail)
        Error(Nil) -> False
      }
  }
}

pub fn explore(trie: Trie, cloze: Cloze, rack: Rack) -> List(String) {
  explore_inner([#(trie, cloze, rack, [])], [])
}

/// EXPLORE_INNER recursively explores a trie while conforming to cloze and rack
/// given that each trie node can branch and we want explore_inner to be TCO, we
/// need to explicitly track frontier inputs and accumulated results
fn explore_inner(
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
            True ->
              explore_inner(tail_entries, [
                list.reverse(trail) |> string.concat(),
                ..acc
              ])
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
