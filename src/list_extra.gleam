import gleam/dict.{type Dict}
import gleam/list

// MODIFIED FROM GLEAM/LIST TO INCLUDE VALUE TRANSFORM
pub fn group(
  list: List(v),
  by key: fn(v) -> k,
  transform fxn: fn(v) -> z,
) -> Dict(k, List(z)) {
  group_inner(list, key, fxn, dict.new())
}

pub fn group_inner(
  list: List(v),
  to_key: fn(v) -> k,
  to_val: fn(v) -> z,
  groups: Dict(k, List(z)),
) -> Dict(k, List(z)) {
  case list {
    [] -> groups
    [first, ..rest] -> {
      let key = to_key(first)
      let val = to_val(first)
      let groups = case dict.get(groups, key) {
        Error(_) -> dict.insert(groups, key, [val])
        Ok(existing) -> dict.insert(groups, key, [val, ..existing])
      }
      group_inner(rest, to_key, to_val, groups)
    }
  }
}

pub fn append(first: List(a), second: List(a)) -> List(a) {
  case first {
    [] -> second
    [first, ..rest] -> append(rest, [first, ..second])
  }
}

pub fn pairs(xs: List(a), ys: List(b)) -> List(#(a, b)) {
  list.flat_map(xs, fn(x) { list.map(ys, fn(y) { #(x, y) }) })
}
