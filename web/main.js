import { raw_board } from "../build/dev/javascript/scrabble/board.mjs";

function onReady(fn) {
  document.readyState !== "loading"
    ? fn()
    : document.addEventListener("DOMContentLoaded", fn);
}
function main() {
  const board = document.getElementById("board");
  const chars = raw_board.replace(/\s/g, "");
  for (let char of chars) {
    const cell = document.createElement("div");
    cell.className = `cell-${char}`;
    board.appendChild(cell);
  }

  console.log(board);
}

onReady(main);
