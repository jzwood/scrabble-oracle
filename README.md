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

## Prior Art
- https://www.cs.cmu.edu/afs/cs/academic/class/15451-s06/www/lectures/scrabble.pdf

## Algorithm
0. precompute dictionary with set of all words and lookups for cloze compatible words

```
pub type ClozeChar {
  Char(char: String, index: Int)
}

pub type ClozeKey {
  Key(length: Int, char: ClozeChar)
  DefaultKey(length: Int)
}

pub type Dictionary {
  Dictionary(clozes: Dict(ClozeKey, List(String)), words: Set(String))
}
```

1. get coordinates (aka playspot) of every legal place to play (i.e. physically legal, no dictionary checks yet)
  e.g. <playspot> = [(x,y),(x,y),(x,y),(x,y),(x,y),(x,y),(x,y),(x,y)]
2. pair each of these with their corresponding cloze
  cloze: `_R__`
  e.g. {<playspot>, `A_`}
3. group these pairings by cloze
  now each cloze will be associated with 1+ playspots
  e.g. %{<cloze>: list<playspot>}
4. for every cloze find every dictionary valid word that is compatible with cloze and rack (using pre-computed dictionary)
  e.g. #(list<playspots>, list<word>)
  4.1.
    - decompose into #(playspot, word) pairs
5. remove from list of letter combo/playspot coords any pairing that, if played, produces a word not in the dictionary
  - check both main axis and all cross-axes
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
