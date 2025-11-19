import * as scrabble from "../../build/dev/javascript/scrabble/scrabble.mjs?v=F1F705B6-EAED-422E-806F-40640EBA6459";
import * as trie from "../../build/dev/javascript/scrabble/trie.mjs?v=F1F705B6-EAED-422E-806F-40640EBA6459";
import { Empty } from "../../build/dev/javascript/prelude.mjs?v=F1F705B6-EAED-422E-806F-40640EBA6459";
import { unwrap } from "../../build/dev/javascript/gleam_stdlib/gleam/result.mjs?v=F1F705B6-EAED-422E-806F-40640EBA6459";

const WORDS_FPATH =
  "../static/text/word_list.txt?v=F1F705B6-EAED-422E-806F-40640EBA6459";
const LIMIT = 25;

let dictionary;

fetch(WORDS_FPATH)
  .then((res) => res.text())
  .then((words) => {
    // global
    dictionary = trie.build(words);
  });

onmessage = ({ data }) => {
  if (dictionary == null) {
    postMessage([]);
  } else {
    const result = calculate(data, dictionary);
    postMessage(result);
  }
};

function calculate({ rack, blanks, board }, dictionary) {
  const result = scrabble.main(rack, blanks, board, dictionary);
  return unwrap(result, new Empty())
    .toArray()
    .slice(0, LIMIT)
    .map(([word, playspot, score]) => [word, playspot.toArray(), score]);
}
