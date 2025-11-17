import { raw_board } from "../../build/dev/javascript/scrabble/board.mjs";
import {
  capitalize,
  clearBoard,
  debounce,
  DIRECTION_DOWN_CLASS,
  focus,
  isDirectionDown,
  LOADER,
  loading,
  resetTabindex,
  restoreBoard,
  saveBoard,
  tabindex,
} from "./utils.js";

function initBoard() {
  const board = document.getElementById("board");
  const chars = raw_board.replace(/\s/g, "");

  Array.from(chars).forEach((char, index) => {
    const cell = document.createElement("div");
    cell.className = `cell cell-${char} flex-center f4 f6-m overflow-hidden`;
    cell.setAttribute("tabindex", tabindex(index, false));
    cell.dataset.bonus = char;
    cell.setAttribute("tabindex", tabindex(index, false));
    cell.setAttribute("contenteditable", "plaintext-only");
    cell.addEventListener("input", (e) => {
      cell.textContent = capitalize(cell.textContent).slice(0, 1);
      if (cell.textContent.length > 0) {
        focus(cell, true);
      }
    });
    cell.addEventListener("keydown", (e) => {
      const key = e.key;
      const isBackspace = key === "Backspace";
      const isEmpty = cell.textContent.length === 0;
      if (/^[a-zA-Z]$/.test(key)) {
        // DO NOTHING
      } else if (isBackspace && isEmpty) {
        focus(cell, false);
      } else if (isBackspace && !isEmpty) {
        cell.textContent = "";
      } else if (key === "Enter" || /^[0-9]$/.test(key)) {
        document.body.classList.toggle(DIRECTION_DOWN_CLASS);
        resetTabindex();
      } else if (key === "ArrowUp") {
        focus(cell, false, true);
      } else if (key === "ArrowRight") {
        focus(cell, true, false);
      } else if (key === "ArrowDown") {
        focus(cell, true, true);
      } else if (key === "ArrowLeft") {
        focus(cell, false, false);
      } else {
        // DO NOTHING
      }
    });

    board.appendChild(cell);
  });
}

function updateResults(results) {
  const output = document.getElementById("output");
  const lis = results.map(([word, playspot, score]) => {
    const li = document.createElement("li");
    li.className = "dc f4";
    const scoreSpan = document.createElement("span");
    scoreSpan.textContent = score;
    scoreSpan.className = "tr";
    const wordSpan = document.createElement("span");
    wordSpan.textContent = word.toUpperCase();
    scoreSpan.className = "tr";
    li.append(scoreSpan, wordSpan);
    return li;
  });
  output.replaceChildren(...lis);
}

async function main() {
  try {
    const worker = new Worker("web/javascript/worker.js", { type: "module" });
    worker.onmessage = ({ data }) => {
      updateResults(data);
      loading(LOADER.STOP);
    };
    worker.onerror = (err) => {
      console.error(err);
    };

    const body = document.querySelector(".body");
    const board = document.getElementById("board");
    const blanks = document.getElementById("blanks");
    const rack = document.getElementById("rack");
    //const clear = document.getElementById("clear");

    initBoard();
    restoreBoard();
    loading(LOADER.START);
    body.classList.remove("hidden");

    const calculate = debounce(() => {
      const rackStr = rack.value;
      if (rackStr.length > 0) {
        const blanksInt = parseInt(blanks.selectedOptions[0].value, 10);
        const boardStr = Array.from(board.children)
          .map((cell) => cell.textContent.trim() || cell.dataset.bonus)
          .join("");

        worker.postMessage({
          board: boardStr,
          rack: rackStr,
          blanks: blanksInt,
        });
        loading(LOADER.START);
      }
    }, 500);

    document.addEventListener("visibilitychange", function () {
      // THEORETICALLY WILL BE CALLED WHEN TAB IS REFRESHED
      if (document.visibilityState == "hidden") {
        saveBoard();
      }
    });

    rack.addEventListener("input", (e) => {
      e.target.value = capitalize(e.target.value).slice(0, 7);
      calculate();
    });
    blanks.addEventListener("change", calculate);

    //clear.addEventListener("click", clearBoard);
    if (rack.value.length > 0) {
      calculate();
    }
    loading(LOADER.STOP);
  } catch (err) {
    console.error(err);
  }
}

// MAIN
(function (fn) {
  document.readyState !== "loading"
    ? fn()
    : document.addEventListener("DOMContentLoaded", fn);
})(main);
