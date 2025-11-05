import * as trie from "../build/dev/javascript/scrabble/trie.mjs";

const WORDS_FPATH = "./word_list.txt";

fetch(WORDS_FPATH)
  .then((res) => res.text())
  .then((words) => {
    const dictionary = trie.build(words);
    postMessage(dictionary);
  });
