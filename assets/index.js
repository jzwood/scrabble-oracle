import * as trie from "../build/dev/javascript/scrabble/trie.mjs";
import { raw_board } from "../build/dev/javascript/scrabble/board.mjs";
import * as scrabble from "../build/dev/javascript/scrabble/scrabble.mjs";
import { unwrap } from "../build/dev/javascript/gleam_stdlib/gleam/result.mjs";
import { Empty } from "../build/dev/javascript/prelude.mjs";

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

    const results = [];
    const worker = new Worker("assets/worker.js", { type: "module" });
    worker.onmessage = ({ data }) => {
      results = data.results;
    };

    // CREATE BOARD
    const board = document.getElementById("board");
    const blanks = document.getElementById("blanks");
    const rack = document.getElementById("rack");
    const output = document.getElementById("output");

    const chars = raw_board.replace(/\s/g, "");
    for (let char of chars) {
      const cell = document.createElement("div");
      cell.className = `cell cell-${char} flex-center f4 f6-m`;
      cell.dataset.bonus = char;
      cell.setAttribute("contenteditable", "plaintext-only");
      cell.addEventListener("input", (e) => {
        const elem = e.target;
        elem.textContent = capitalize(elem.textContent).slice(0, 1);
        if (elem.textContent.length > 0) elem.nextSibling.focus();
      });
      cell.addEventListener("keydown", (e) => {
        const elem = e.target;
        const isBackspace = e.key === "Backspace";
        const isEmpty = elem.textContent.length === 0;
        if (isBackspace && isEmpty) {
          elem.previousSibling.focus();
        } else if (isBackspace && !isEmpty) {
          elem.textContent = "";
        }
      });
      board.appendChild(cell);
    }

    const calculate = debounce(() => {
      const blanksInt = parseInt(blanks.selectedOptions[0].value, 10);
      const rackStr = rack.value;
      const boardStr = Array.from(board.children)
        .map((cell) => cell.textContent || "_")
        .join("");
      worker.postMessage({ board: boardStr, rack: rackStr, blanks: blanksInt });
    }, 500);

    // INIT RACK
    racks.addEventListener("input", (e) => {
      e.target.value = capitalize(e.target.value);
      calculate();
    });
    blanks.addEventListener("change", calculate)

    // TODO: end loading UI
  } catch (err) {
    console.error(err);
  }
}

function debounce(func, delay) {
  let timeout;
  return function (...args) {
    clearTimeout(timeout);
    timeout = setTimeout(() => {
      func.apply(this, args);
    }, delay);
  };
}
