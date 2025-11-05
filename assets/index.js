import { raw_board } from "../build/dev/javascript/scrabble/board.mjs";
import * as scrabble from "../build/dev/javascript/scrabble/scrabble.mjs";
import * as trie from "../build/dev/javascript/scrabble/trie.mjs";

(function (fn) {
  document.readyState !== "loading"
    ? fn()
    : document.addEventListener("DOMContentLoaded", fn);
})(main);

function capitalize(value) {
  return value.toUpperCase().replace(/[^A-Z]/g, "");
}

async function main() {
  try {
    // TODO: start loading UI

    // CREATE BOARD
    const board = document.getElementById("board");
    const chars = raw_board.replace(/\s/g, "");
    for (let char of chars) {
      const cell = document.createElement("div");
      cell.className = `cell cell-${char} flex-center f6`;
      cell.setAttribute("contenteditable", "plaintext-only");
      cell.addEventListener("input", (e) => {
        const elem = e.target;
        elem.textContent = capitalize(elem.textContent).slice(0, 1);
        if (elem.textContent.length > 0) elem.nextSibling.focus();
      });
      board.appendChild(cell);
    }

    let rack = "";
    let blanks = 0;

    // INIT RACK
    document
      .getElementById("rack")
      .addEventListener("input", (e) => {
        rack = capitalize(e.target.value);
        e.target.value = rack;
      });

    document
      .getElementById("blanks")
      .addEventListener("change", (e) => {
        blanks = parseInt(e.target.selectedOptions[0].value, 10);
      });

    // FETCH WORDS & BUILD DICTIONARY
    const words = await fetch("assets/word_list.txt").then((res) => res.text());
    const dictionary = trie.build(words);

    // TODO: end loading UI
  } catch (err) {
    console.error(err);
  }
}
