import board
import gleam/dict
import gleam/io
import gleam/list
import gleam/string
import gleeunit
import types.{Rack}

const test_board = "
  4__B___N___1__4
  JOULES_A___QAT_
  OY2E_T1R1___B__
  1__E_A_CONE2O_1
  _RUDER___ADORN_
  _3___L_PIG__T3_
  _V1__I1U1___I__
  MILLINER___1OOF
  _V1__G1G1___NO_
  _A___3_E_3___Z_
  ___NEXUS__2__E_
  1_MAT__1___2_D_
  __E___1_1___2__
  _2W__3___3___2_
  WAS1___4___1__4
  "

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

pub fn pretty_print_test() {
  let assert Ok(board) = test_board |> board.parse_board()

  io.println("")
  board
  |> board.pretty_print()
  |> io.println
}
