import gleam/list
import gleam/pair
import list_extra

pub fn new(list: List(a)) -> #(List(a), List(fn(a) -> Bool)) {
  pair.new(list, [])
}

pub fn filter(
  tup: #(List(a), List(fn(a) -> Bool)),
  pred: fn(a) -> Bool,
) -> #(List(a), List(fn(a) -> Bool)) {
  pair.map_second(tup, list.prepend(_, pred))
}

pub fn eval(tup: #(List(a), List(fn(a) -> Bool))) -> List(a) {
  let #(list, preds) = tup
  list_extra.filter(list, fn(a) { list.all(preds, fn(pred) { pred(a) }) })
}
