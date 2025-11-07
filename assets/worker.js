import * as trie from "../build/dev/javascript/scrabble/trie.mjs";
import { unwrap } from "../build/dev/javascript/gleam_stdlib/gleam/result.mjs";
import { Empty } from "../build/dev/javascript/prelude.mjs";

const WORDS_FPATH = "./word_list.txt";

let dictionary;

fetch(WORDS_FPATH)
  .then((res) => res.text())
  .then((words) => {
    // global
    dictionary = trie.build(words);
  });

onmessage = ({ data }) => {
  if (dictionary == null) return null;
  console.log("DATA", data);
  //if (data.rack.length === 0) return null;
  //const result = calculate(data.rack, data.board, dictionary);
  //postMessage(result);
};

function calculate(rack, blanks, board, dictionary) {
  const result = scrabble.main(rack, blanks, board, dictionary);
  return unwrap(result, new Empty())
    .toArray()
    .map(([word, playspot, score]) => [word, playspot.toArray(), score]);
}
