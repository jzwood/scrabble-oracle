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
 0 ___b___n_______  0
 1 joules_a___qat_  1
 2 oy_e_t_r____b__  2
 3 ___e_a_cone_o__  3
 4 _ruder___adorn_  4
 5 _____l_pig__t__  5
 6 _v___i_u____i__  6
 7 milliner____oof  7
 8 _v___g_g____no_  8
 9 _a_____e_____z_  9
10 ___nexus_____e_ 10
11 __mat________d_ 11
12 __e____________ 12
13 __w____________ 13
14 was____________ 14
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
 0 AAA_AAA_A__AAA_  0
 1 ______A_A_A___A  1
 2 __A_A_A_AAAA_A_  2
 3 AAA_A_A____A_A_  3
 4 A_____AAA_____A  4
 5 _AAAA_A___AA_A_  5
 6 A_AAA_A_AA_A_AA  6
 7 ________A__A___  7
 8 A_AAA_A_A__A__A  8
 9 A_AAAAA_A___A_A  9
10 _AA_____A___A_A 10
11 _A___AAA____A_A 11
12 _A_AA________A_ 12
13 AA_A___________ 13
14 ___A___________ 14
   012345678901234
"

  let actual =
    board.build_adjacent_cells(board)
    |> set.to_list()
    |> list.map(fn(cell) { #(cell, Square(Some(Tile("A", 0)), None)) })
    |> dict.from_list
    |> board.pretty_print

  assert actual == expected
}
