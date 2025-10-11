import board
import gleam/dict
import gleam/list
import gleam/string
import gleeunit
import types.{Rack}

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn init_board_test() {
  let empty_board = board.init()
  let expected_size = 15 * 15
  assert dict.size(empty_board) == expected_size
}

pub fn is_alphanum_test() {
  assert board.is_alphanum(
    "1234qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM_",
  )
  assert False == board.is_alphanum("0")
  assert False == board.is_alphanum("5")
  assert False == board.is_alphanum("6")
  assert False == board.is_alphanum("7")
  assert False == board.is_alphanum("8")
  assert False == board.is_alphanum("9")
  assert False == board.is_alphanum("!")
  assert False == board.is_alphanum("&")
  assert False == board.is_alphanum("~")
  assert False == board.is_alphanum("$")
  assert False == board.is_alphanum("]")
  assert False == board.is_alphanum("?")
  assert False == board.is_alphanum("@")
}

pub fn parse_rack_test() {
  assert Ok(Rack(chars: ["A", "B", "D", "E", "H", "Q", "T"], num_blanks: 0))
    == board.parse_rack("AHBETDQ", 0)
  assert Ok(Rack(chars: ["D", "I", "O", "U"], num_blanks: 1))
    == board.parse_rack("IOUD", 1)
  assert Error("rack has unidentifiable letters")
    == board.parse_rack("HELLO!", 1)
}
