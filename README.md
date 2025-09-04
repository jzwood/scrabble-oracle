# scrabble

[![Package Version](https://img.shields.io/hexpm/v/scrabble)](https://hex.pm/packages/scrabble)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/scrabble/)

```sh
gleam add scrabble@1
```
```gleam
import scrabble

pub fn main() -> Nil {
  // TODO: An example of the project in use
}
```

## Algorithm
1. get coordinates (aka playspot) of every legal place to play (i.e. physically legal, no dictionary checks yet)
  e.g. <playspot> = [(x,y),(x,y),(x,y),(x,y),(x,y),(x,y),(x,y),(x,y)]
2. pair each of these with their corresponding cloze
  cloze example: `_R__`
  e.g. {<playspot>, `A_`}
3. group these pairings by cloze
  now each cloze will be associated with 1+ playspot coordinates
  e.g. %{<cloze>: list<playspot>}
4. a) for every cloze find every possible string combo that the input rack can produce (implementation uses [trie](https://en.wikipedia.org/wiki/Trie))
  these are random combinations of letters -- not necessarily real words
  e.g. %{<cloze>: %{playspots: list<playspots>, words: list<word>}}
4. b) ALT: for every cloze find every dictionary valid word that is compatible with cloze and rack.
  e.g. #(list<playspots>, list<word>)
  can be decomposed into #(playspot, word)
5. remove from list of letter combo/playspot coords any pairing that, if played, produces a word not in the dictionary
6. score all remaining valid playable spots and order from highest point value to lowest


@TODO
figure out how get all playspots works
if it doesn't take end-cap letters into account then doing an initial dictionary filter is WRONG b/c cloze _A_ might be put between other others words so you can't know what'll be valid until you check later.
@EDIT
I think this is fine. I can make sure get_cloze includes ends



Further documentation can be found at <https://hexdocs.pm/scrabble>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
