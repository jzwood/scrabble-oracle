function empty() {
  return { terminal: false, children: {} };
}

export function buildDictionary(words) {
  const forward = empty();
  const backward = empty();
  words
    .split("\n")
    .forEach((word) => {
      const chars = Array.from(word);
      insert(forward, chars);
      chars.reverse();
      do {
        insert(backward, chars);
      } while (chars.pop());
    });
  return { forward, backward };
}

function insert(trie, word) {
  const [char, ...tail] = word;
  if (!char) {
    trie.terminal = true;
    return trie;
  }
  trie.children[char] ??= empty();
  insert(trie.children[char], tail);
}
