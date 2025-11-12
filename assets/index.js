import { raw_board } from "../build/dev/javascript/scrabble/board.mjs";

const LOADER = {
  START: Symbol("start"),
  STOP: Symbol("stop"),
};

const DIRECTION_DOWN_CLASS = "direction-down";

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

function isDirectionDown() {
  return document.body.classList.contains(DIRECTION_DOWN_CLASS);
}

function focus(elem, forward) {
  let sibling = elem;
  if (isDirectionDown()) {
    for (let i = 0; i < 15; i++) {
      sibling = forward ? sibling?.nextSibling : sibling?.previousSibling;
    }
  } else {
    sibling = forward ? elem?.nextSibling : elem?.previousSibling;
  }
  if (sibling) {
    sibling.focus();
    return sibling;
  }
  return elem;
}

function resetTabindex() {
  const board = document.getElementById("board");
  Array.from(board.children).forEach((cell, index) => {
    cell.setAttribute("tabindex", tabindex(index, isDirectionDown()));
  });
}

function tabindex(index, down) {
  const width = 15;
  return 1 +
    (down ? Math.floor(index / width) + width * (index % width) : index);
}

function initBoard() {
  const board = document.getElementById("board");
  const chars = raw_board.replace(/\s/g, "");
  let active;

  Array.from(chars).forEach((char, index) => {
    const cell = document.createElement("div");
    cell.className = `cell cell-${char} flex-center f4 f6-m overflow-hidden`;
    cell.setAttribute("tabindex", tabindex(index, false));
    cell.addEventListener("keydown", (e) => {
      const key = e.key;
      const isBackspace = key === "Backspace";
      const isEmpty = cell.textContent.length === 0;
      if (/^[a-zA-Z]$/.test(key)) {
        cell.textContent = capitalize(key);
        active = focus(cell, true);
      } else if (isBackspace && isEmpty) {
        active = focus(cell, false);
      } else if (isBackspace && !isEmpty) {
        active = cell;
        cell.textContent = "";
      } else {
        active = cell;
      }
    });

    cell.addEventListener("click", (e) => {
      cell.focus();
      if (active === cell) {
        document.body.classList.toggle(DIRECTION_DOWN_CLASS);
        resetTabindex();
      } else {
        active = cell;
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
    const span1 = document.createElement("span");
    span1.textContent = score;
    span1.className = "tr";
    const span2 = document.createElement("span");
    span2.textContent = word;
    span1.className = "tr";
    li.append(span1, span2);
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

// MAIN
(function (fn) {
  document.readyState !== "loading"
    ? fn()
    : document.addEventListener("DOMContentLoaded", fn);
})(main);
