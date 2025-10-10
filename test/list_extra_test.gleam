import gleam/function
import gleam/int
import gleam/list
import gleam/string
import gleeunit
import list_extra

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn is_sorted_test() {
  assert list_extra.is_sorted([1, 2, 3, 4, 5], int.compare)
  assert False == list_extra.is_sorted([1, 2, 3, 5, 4], int.compare)
  assert list_extra.is_sorted(["A", "B", "a", "b"], string.compare)
  assert False == list_extra.is_sorted(["A", "a", "B", "b"], string.compare)
}

pub fn pairs_test() {
  let a = list.range(1, 3)
  let b = ["a", "b"]
  assert list_extra.pairs(a, b)
    == [#(1, "b"), #(1, "a"), #(2, "b"), #(2, "a"), #(3, "b"), #(3, "a")]
  assert list_extra.pairs_by([2, 4], [10, 30], int.add)
    |> list.sort(int.compare)
    == [12, 14, 32, 34]
}

pub fn map_test() {
  let a = list.range(22, 45)
  assert list_extra.map(a, int.add(_, 10)) |> list.sort(int.compare)
    == list.map(a, int.add(_, 10))
}

pub fn filter_test() {
  let a = list.range(22, 45)
  assert list_extra.filter(a, int.is_even) |> list.sort(int.compare)
    == list.filter(a, int.is_even)
  let a = list.range(3, -19)
  assert list_extra.filter(a, int.is_odd)
    |> list.sort(int.compare)
    |> list.reverse
    == list.filter(a, int.is_odd)
}

pub fn filter_all_test() {
  let a = list.range(0, 25)
  assert list_extra.filter_all(a, [
      fn(x) { x > 18 },
      fn(x) { x < 22 },
      int.is_odd,
    ])
    |> list.sort(int.compare)
    == [19, 21]
  assert list_extra.filter_all(a, [
      int.is_odd,
      int.is_even,
    ])
    == []
}

pub fn group_test() {
  let a = [1, 2, 3, 2]
  assert list_extra.group(a, int.is_even, function.identity)
    == list.group(a, int.is_even)
  let a = list.range(1, 20) |> list.window(3) |> list.flatten
  assert list_extra.group(a, int.is_even, function.identity)
    == list.group(a, int.is_even)
}

pub fn append_test() {
  let a = list.range(3, 13)
  let b = list.range(14, 27)
  assert list_extra.append(a, b) |> list.sort(int.compare)
    == list.append(a, b) |> list.sort(int.compare)

  let a = ["a", "r", "d", "w", "q"]
  let b = ["p", "e", "e", "q", "v", "a"]
  assert list_extra.append(a, b) |> list.sort(string.compare)
    == list.append(a, b) |> list.sort(string.compare)
}
