import board
import gleam/dict
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/set
import gleam/string
import gleeunit
import io_extra.{debug}
import types.{Rack, Square, Tile}

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
  let expected =
    "
   012345678901234
 0 ___B___N_______  0
 1 JOULES_A___QAT_  1
 2 OY_E_T_R____B__  2
 3 ___E_A_CONE_O__  3
 4 _RUDER___ADORN_  4
 5 _____L_PIG__T__  5
 6 _V___I_U____I__  6
 7 MILLINER____OOF  7
 8 _V___G_G____NO_  8
 9 _A_____E_____Z_  9
10 ___NEXUS_____E_ 10
11 __MAT________D_ 11
12 __E____________ 12
13 __W____________ 13
14 WAS____________ 14
   012345678901234
"

  let actual = board.pretty_print(board)
  assert actual == expected
}

pub fn build_adjacent_cells_test() {
  let assert Ok(board) = board.parse_board(test_board)

  let expected =
    "
   012345678901234
 0 XXX_XXX_X__XXX_  0
 1 ______X_X_X___X  1
 2 __X_X_X_XXXX_X_  2
 3 XXX_X_X____X_X_  3
 4 X_____XXX_____X  4
 5 _XXXX_X___XX_X_  5
 6 X_XXX_X_XX_X_XX  6
 7 ________X__X___  7
 8 X_XXX_X_X__X__X  8
 9 X_XXXXX_X___X_X  9
10 _XX_____X___X_X 10
11 _X___XXX____X_X 11
12 _X_XX________X_ 12
13 XX_X___________ 13
14 ___X___________ 14
   012345678901234
"

  let actual =
    board.build_adjacent_cells(board)
    |> set.to_list()
    |> list.map(fn(cell) { #(cell, Square(Some(Tile("X", 0)), None)) })
    |> dict.from_list
    |> board.pretty_print

  assert actual == expected
}
