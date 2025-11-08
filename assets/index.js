import { raw_board } from "../build/dev/javascript/scrabble/board.mjs";

const LOADER = {
  START: Symbol("start"),
  STOP: Symbol("stop"),
};

(function (fn) {
  document.readyState !== "loading"
    ? fn()
    : document.addEventListener("DOMContentLoaded", fn);
})(main);

function capitalize(value) {
  return value.toUpperCase().replace(/[^A-Z]/g, "");
}

function loading(action) {
  const loader = document.getElementById("loader");
  switch (action) {
    case LOADER.START:
      loader.classList.add("loader");
      break;
    case LOADER.STOP:
      loader.classList.remove("loader");
      break;
  }
}

function initBoard() {
  const board = document.getElementById("board");
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
}

function updateResults(results) {
  const output = document.getElementById("output");
  const lis = results.map(([word, playspot, score]) => {
    const li = document.createElement("li");
    li.className = "dc f4";
    const span1 = document.createElement("span");
    span1.textContent = score;
    span1.className = "tr";
    const span2 = document.createElement("span");
    span2.textContent = word;
    span1.className = "tr";
    li.replaceChildren(span1, span2);
    return li;
  });
  output.replaceChildren(...lis);
}

async function main() {
  try {
    const worker = new Worker("assets/worker.js", { type: "module" });
    worker.onmessage = ({ data }) => {
      updateResults(data);
      loading(LOADER.STOP);
    };

    const body = document.querySelector(".body");
    const board = document.getElementById("board");
    const blanks = document.getElementById("blanks");
    const rack = document.getElementById("rack");

    initBoard();
    loading(LOADER.START);
    body.classList.remove("hidden");

    const calculate = debounce(() => {
      const rackStr = rack.value;
      if (rackStr.length > 0) {
        const blanksInt = parseInt(blanks.selectedOptions[0].value, 10);
        const boardStr = Array.from(board.children)
          .map((cell) => cell.textContent || "_")
          .join("");

        worker.postMessage({
          board: boardStr,
          rack: rackStr,
          blanks: blanksInt,
        });
        loading(LOADER.START);
      }
    }, 500);

    rack.addEventListener("input", (e) => {
      e.target.value = capitalize(e.target.value).slice(0, 7);
      calculate();
    });
    blanks.addEventListener("change", calculate);

    loading(LOADER.STOP);
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
