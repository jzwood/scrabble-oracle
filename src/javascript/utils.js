export const DIRECTION_DOWN_CLASS = "direction-down";
export const LOADER = {
  START: Symbol("start"),
  STOP: Symbol("stop"),
};

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

export function resetTabindex() {
  const board = document.getElementById("board");
  Array.from(board.children).forEach((cell, index) => {
    cell.setAttribute("tabindex", tabindex(index, isDirectionDown()));
  });
}

export function tabindex(index, down) {
  const width = 15;
  return 1 +
    (down ? Math.floor(index / width) + width * (index % width) : index);
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
