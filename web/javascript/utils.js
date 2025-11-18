export const DIRECTION_DOWN_CLASS = "direction-down";
export const LOADER = {
  START: Symbol("start"),
  STOP: Symbol("stop"),
};
export const WIDTH = 15;

export function loading(action) {
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

export function isDirectionDown() {
  return document.body.classList.contains(DIRECTION_DOWN_CLASS);
}

export function focus(elem, forward, down = isDirectionDown()) {
  let sibling = elem;
  if (down) {
    for (let i = 0; i < WIDTH; i++) {
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

export function resetTabindex() {
  const board = document.getElementById("board");
  Array.from(board.children).forEach((cell, index) => {
    cell.setAttribute("tabindex", tabindex(index, isDirectionDown()));
  });
}

export function tabindex(index, down) {
  return 1 +
    (down ? Math.floor(index / WIDTH) + WIDTH * (index % WIDTH) : index);
}

export function debounce(func, delay) {
  let timeout;
  return function (...args) {
    clearTimeout(timeout);
    timeout = setTimeout(() => {
      func.apply(this, args);
    }, delay);
  };
}

export function capitalize(value) {
  return value.toUpperCase().replace(/[^A-Z]/g, "");
}

export function saveBoard() {
  const board = document.getElementById("board");
  const state = Array.from(board.children).map((cell) =>
    cell.textContent || "_"
  ).join("");
  sessionStorage.setItem("board", state);
}

export function restoreBoard() {
  const board = document.getElementById("board");
  const state = sessionStorage.getItem("board");
  if (state) {
    Array.from(state).forEach((char, index) => {
      if (/^[a-zA-Z]$/.test(char)) {
        board.children[index].textContent = char;
      }
    });
  }
}

export function clearBoard() {
  const board = document.getElementById("board");
  for (let cell of board.children) {
    cell.textContent = "";
  }
}
