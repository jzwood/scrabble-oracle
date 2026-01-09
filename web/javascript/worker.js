import * as scrabble from "../../build/dev/javascript/scrabble/scrabble.mjs?v=1BFC74D6-970C-4602-857F-B14ACBDF960F";
import * as trie from "../../build/dev/javascript/scrabble/trie.mjs?v=1BFC74D6-970C-4602-857F-B14ACBDF960F";
import { Empty } from "../../build/dev/javascript/prelude.mjs?v=1BFC74D6-970C-4602-857F-B14ACBDF960F";
import { unwrap } from "../../build/dev/javascript/gleam_stdlib/gleam/result.mjs?v=1BFC74D6-970C-4602-857F-B14ACBDF960F";

const WORDS_FPATH =
  "../static/text/sowpods.txt?v=1BFC74D6-970C-4602-857F-B14ACBDF960F";
const LIMIT = 25;

let dictionary;
let queue;

fetch(WORDS_FPATH)
  .then((res) => res.text())
  .then((words) => {
    // global
    dictionary = trie.build(words);
    if (queue) {
      const result = calculate(queue, dictionary);
      postMessage(result);
    }
  });

onmessage = ({ data }) => {
  if (dictionary == null) {
    queue = data;
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
