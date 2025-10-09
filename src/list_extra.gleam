import gleam/dict.{type Dict}
import gleam/list
import gleam/order.{type Order, Eq, Gt, Lt}

/// note: modified from gleam/list to include value transform
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

/// note: does not preserve order
pub fn append(first: List(a), second: List(a)) -> List(a) {
  case first {
    [] -> second
    [first, ..rest] -> append(rest, [first, ..second])
  }
}

/// note: does not preserve order
pub fn filter(list: List(a), keeping predicate: fn(a) -> Bool) -> List(a) {
  list.fold(list, [], fn(acc, a) {
    case predicate(a) {
      False -> acc
      True -> [a, ..acc]
    }
  })
}

/// note: does not preserve order
pub fn exclude(list: List(a), excluding predicate: fn(a) -> Bool) -> List(a) {
  list.fold(list, [], fn(acc, a) {
    case predicate(a) {
      True -> acc
      False -> [a, ..acc]
    }
  })
}

/// note: does not preserve order
pub fn map(list: List(a), with fun: fn(a) -> b) -> List(b) {
  list.fold(list, [], fn(acc, a) { [fun(a), ..acc] })
}

/// produces every pair between 2 lists as a 2-tuple
pub fn pairs(xs: List(a), ys: List(b)) -> List(#(a, b)) {
  list.flat_map(xs, fn(x) { map(ys, fn(y) { #(x, y) }) })
}

/// produces every pair between 2 lists as a 2-tuple applied to function
pub fn pairs_by(xs: List(a), ys: List(b), fxn: fn(a, b) -> c) -> List(c) {
  list.flat_map(xs, fn(x) { map(ys, fn(y) { fxn(x, y) }) })
}

/// applies multiple predicates to a list in 1 pass
/// note: does not preserve order
pub fn filter_all(xs: List(a), predicates: List(fn(a) -> Bool)) -> List(a) {
  filter(xs, fn(x) { list.all(predicates, fn(fxn) { fxn(x) }) })
}

/// predicate testing whether list is already sorted
pub fn is_sorted(xs: List(a), cmp: fn(a, a) -> Order) -> Bool {
  case xs {
    [] -> True
    [_] -> True
    [x, y, ..tail] -> {
      case cmp(x, y) {
        Lt | Eq -> is_sorted([y, ..tail], cmp)
        Gt -> False
      }
    }
  }
}
