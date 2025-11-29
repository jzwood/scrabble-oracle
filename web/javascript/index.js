import { raw_board } from "../../build/dev/javascript/scrabble/board.mjs?v=6517E3F6-1285-4480-8BB7-5FF561E4D041";
import {
  capitalize,
  clearBoard,
  debounce,
  DIRECTION_DOWN_CLASS,
  focus,
  isAlphaChar,
  isDirectionDown,
  LOADER,
  loading,
  resetTabindex,
  restoreBoard,
  saveBoard,
  tabindex,
  WIDTH,
} from "./utils.js?v=6517E3F6-1285-4480-8BB7-5FF561E4D041";

function initBoard(calculate) {
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
      if (isAlphaChar(key)) {
        calculate();
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

function showPlayspot(playspot) {
  const board = document.getElementById("board");
  for (let cell of board.children) {
    cell.classList.remove("active");
  }
  playspot.forEach(({ x, y }) => {
    board.children[y * WIDTH + x].classList.add("active");
  });
}

function updateResults(results) {
  const output = document.getElementById("output");
  if (results.length === 0) {
    output.classList.remove("grid");
    const message = document.createElement("div");
    message.textContent = "no playable words";
    output.replaceChildren(message);
    return null;
  }
  const padLeft = results[0][2].toString().length;
  const lis = results.map(([word, playspot, score]) => {
    const li = document.createElement("li");
    li.className = "gh2 f4";
    li.style.display = "inline-flex";
    const scoreSpan = document.createElement("span");
    scoreSpan.textContent = score.toString().padStart(padLeft, " ");
    scoreSpan.className = "tr";
    const wordButton = document.createElement("button");
    wordButton.textContent = word.toUpperCase();
    wordButton.className = "bw0 tl";
    wordButton.addEventListener("click", () => {
      showPlayspot(playspot);
    });
    li.append(scoreSpan, wordButton);
    return li;
  });
  output.replaceChildren(...lis);
  output.style["grid-template-columns"] = "";
  output.classList.remove("grid");
  const width = Array.from(output.children).reduce((acc, child) => {
    const { width } = child.getBoundingClientRect();
    return width > acc ? width : acc;
  }, 0);
  output.classList.add("grid");
  output.style["grid-template-columns"] =
    `repeat(auto-fit, minmax(${width}px, ${width}px))`;
}

async function main() {
  try {
    const worker = new Worker("web/javascript/worker.js", { type: "module" });
    worker.onmessage = ({ data }) => {
      updateResults(data);
      loading(LOADER.STOP);
    };
    worker.onerror = (err) => {
      loading(LOADER.STOP);
      console.error(err);
    };

    const body = document.querySelector(".body");
    const board = document.getElementById("board");
    const blanks = document.getElementById("blanks");
    const rack = document.getElementById("rack");
    const menuLabel = document.getElementById("menu");
    const menuOptions = document.querySelector("menu");
    const help = document.getElementById("help");
    const clear = document.getElementById("clear");

    const calculate = () => {
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
    };
    const calculate500 = debounce(calculate, 500);
    const calculate1000 = debounce(calculate, 1000);

    initBoard(calculate1000);
    restoreBoard();
    body.classList.remove("hidden");

    const closeMenu = () => menuOptions.classList.add("hidden");
    const toggleMenu = () => menuOptions.classList.toggle("hidden");
    const onPopoverClose = (event) => {
      if (event.newState === "closed") {
        closeMenu();
      }
    };

    document.addEventListener("visibilitychange", function () {
      // THEORETICALLY WILL BE CALLED WHEN TAB IS REFRESHED
      if (document.visibilityState == "hidden") {
        saveBoard();
      }
    });
    help.addEventListener("toggle", onPopoverClose);
    clear.addEventListener("toggle", onPopoverClose);
    clear.querySelector(".no").addEventListener("click", () => {
      clear.hidePopover();
    });
    clear.querySelector(".yes").addEventListener("click", () => {
      clearBoard();
      clear.hidePopover();
    });
    rack.addEventListener("input", (e) => {
      e.target.value = capitalize(e.target.value).slice(0, 7);
      calculate500();
    });
    blanks.addEventListener("change", calculate500);

    menuLabel.addEventListener("click", toggleMenu);

    menuLabel.addEventListener("blur", (e) => {
      const target = e?.relatedTarget?.getAttribute("popovertarget");
      switch (target) {
        case "help":
        case "clear":
        case "pricing":
          break;
        default:
          closeMenu();
      }
    });

    calculate();
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
