import gleam/dict.{type Dict}
import gleam/list
import gleam/pair

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

pub fn filter(list: List(a), keeping predicate: fn(a) -> Bool) -> List(a) {
  list.fold_right(list, [], fn(acc, a) {
    case predicate(a) {
      False -> acc
      True -> [a, ..acc]
    }
  })
}

pub fn fusion_new(list: List(a)) -> #(List(a), List(fn(a) -> Bool)) {
  pair.new(list, [])
}

pub fn fusion_filter(
  tup: #(List(a), List(fn(a) -> Bool)),
  pred: fn(a) -> Bool,
) -> #(List(a), List(fn(a) -> Bool)) {
  pair.map_second(tup, list.prepend(_, pred))
}

pub fn fusion_eval(tup: #(List(a), List(fn(a) -> Bool))) -> List(a) {
  let #(list, preds) = tup
  filter(list, fn(a) { list.all(preds, fn(pred) { pred(a) }) })
}

pub fn exclude(list: List(a), excluding predicate: fn(a) -> Bool) -> List(a) {
  list.fold_right(list, [], fn(acc, a) {
    case predicate(a) {
      True -> acc
      False -> [a, ..acc]
    }
  })
}

pub fn map(list: List(a), with fun: fn(a) -> b) -> List(b) {
  list.fold_right(list, [], fn(acc, a) { [fun(a), ..acc] })
}

pub fn pairs(xs: List(a), ys: List(b)) -> List(#(a, b)) {
  list.flat_map(xs, fn(x) { list.map(ys, fn(y) { #(x, y) }) })
}

pub fn pairs_by(xs: List(a), ys: List(b), fxn: fn(a, b) -> c) -> List(c) {
  list.flat_map(xs, fn(x) { list.map(ys, fn(y) { fxn(x, y) }) })
}
