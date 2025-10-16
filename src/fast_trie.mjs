export function build(words) {
  const trie = empty();
  words
    .split("\n")
    .forEach((word) => {
      insert(trie, Array.from(word));
    });
  console.log("TRIE", trie);
  return trie;
}

function empty() {
  return { terminal: false, children: {} };
}

function insert(trie, word) {
  const [char, ...tail] = word;
  if (!char) return trie;
  trie.terminal ||= tail.length === 0;
  trie.children[char] ??= empty();
  insert(trie.children[char], tail);
}
