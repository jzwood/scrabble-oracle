//export function build(words) {
  //const trie = empty();
  //words
    //.split("\n")
    //.forEach((word) => {
      //insert(trie, Array.from(word));
    //});
  //return trie;
//}

//export function buildBackwards(words) {
  //const trie = empty();
  //words
    //.split("\n")
    //.forEach((word) => {
      //const chars = Array.from(word).reverse();
      //do {
        //insert(trie, chars);
      //} while (chars.pop());
    //});
  //return trie;
//}

function empty() {
  return { terminal: false, children: {} };
}

export function buildDictionary(words) {
  const forward = empty();
  const backward = empty();
  words
    .split("\n")
    .forEach((word) => {
      const chars = Array.from(word)
      insert(forward, chars);
      chars.reverse();
      do {
        insert(backward, chars);
      } while (chars.pop());
    });
  return {forward, backward}
}

function insert(trie, word) {
  const [char, ...tail] = word;
  if (!char) return trie;
  trie.terminal ||= tail.length === 0;
  trie.children[char] ??= empty();
  insert(trie.children[char], tail);
}
