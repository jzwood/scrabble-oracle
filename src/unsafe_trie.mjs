import {
  has_key as hasKey,
  insert as updateMap,
} from "../gleam_stdlib/gleam/dict.mjs?v=7491977C-51EC-43A8-8114-F12FFB84A3D9";
import { new_map as emptyMap } from "../gleam_stdlib/gleam_stdlib.mjs?v=7491977C-51EC-43A8-8114-F12FFB84A3D9";
import { Trie } from "./trie.mjs?v=7491977C-51EC-43A8-8114-F12FFB84A3D9";

function empty() {
  return new Trie(false, emptyMap());
}

export function build(words) {
  const trie = empty();
  words
    .trim()
    .split("\n")
    .forEach((word) => {
      const chars = Array.from(word);
      insert(trie, chars);
    });
  return trie;
}

function insert(trie, word) {
  const [char, ...tail] = word;
  if (char == null) {
    trie.terminal = true;
  } else {
    const child = trie.children.get(char);
    if (child == null) {
      trie.children = updateMap(trie.children, char, empty());
      insert(trie.children.get(char), tail);
    } else {
      insert(child, tail);
    }
  }
}
