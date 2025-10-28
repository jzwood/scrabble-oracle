const USAGE = "USAGE: deno run --allow-read precompute.js <words_path>";

const [filepath, ...rest] = Deno.args;
let words = await Deno.readTextFile(filepath);

const trie = {};

words.split("\n").forEach((word) => {
  insert(trie, Array.from(word));
});

function insert(trie, word) {
  const [char, ...tail] = word;
  if (!char) return trie;
  const terminal = tail.length === 0;
  if (!trie[char]) {
    trie[char] = {};
  }
  trie[char].terminal ||= terminal;
  insert(trie[char], tail);
}

await Deno.writeTextFile("assets/words.json", JSON.stringify(trie), {
  encoding: "utf8",
});
