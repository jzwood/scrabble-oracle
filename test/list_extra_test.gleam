import gleam/int
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
