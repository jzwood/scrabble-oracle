import * as scrabble from "../../build/dev/javascript/scrabble/scrabble.mjs?v=5F1E1E35-F148-47B5-8BBD-D747D2E22187";
import * as trie from "../../build/dev/javascript/scrabble/trie.mjs?v=5F1E1E35-F148-47B5-8BBD-D747D2E22187";
import { Empty } from "../../build/dev/javascript/prelude.mjs?v=5F1E1E35-F148-47B5-8BBD-D747D2E22187";
import { unwrap } from "../../build/dev/javascript/gleam_stdlib/gleam/result.mjs?v=5F1E1E35-F148-47B5-8BBD-D747D2E22187";

const WORDS_FPATH =
  "../static/text/word_list.txt?v=5F1E1E35-F148-47B5-8BBD-D747D2E22187";
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
