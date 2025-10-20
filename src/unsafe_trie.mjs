function empty() {
  return { terminal: false, children: {} };
}

export function buildDictionary(words) {
  const trie = empty();
  words
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
    return trie;
  }
  trie.children[char] ??= empty();
  insert(trie.children[char], tail);
}
