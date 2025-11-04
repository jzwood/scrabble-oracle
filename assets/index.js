import { raw_board } from "../build/dev/javascript/scrabble/board.mjs";

(function (fn) {
  document.readyState !== "loading"
    ? fn()
    : document.addEventListener("DOMContentLoaded", fn);
})(main);

function getWords(callback) {
  fetch("assets/word_list.txt")
    .then((res) => res.text())
    .then(callback)
    .catch((err) => {
      console.error(err);
    });
}

function main() {
  getWords((words) => {
    const board = document.getElementById("board");
    const chars = raw_board.replace(/\s/g, "");
    for (let char of chars) {
      const cell = document.createElement("div");
      cell.className = `cell-${char}`;
      board.appendChild(cell);
    }

    const rack = document.getElementById("rack");
    rack.addEventListener("input", (e) => {
      e.target.value = e.target.value.toUpperCase().replace(/[^A-Z]/g, "");
    });

    console.log(board, words);
  });
}
