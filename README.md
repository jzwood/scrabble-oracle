# scrabble

## Prior Art

- https://www.cs.cmu.edu/afs/cs/academic/class/15451-s06/www/lectures/scrabble.pdf
- https://github.com/jzwood/ScrabbleOracle

## Algorithm

1. precompute dictionary with set of all words and lookups for cloze compatible
   words

        pub type ClozeKey {
          Key(length: Int, index: Int, char: String)
          DefaultKey(length: Int)
        }

        pub type Dictionary {
          Dictionary(clozes: Dict(ClozeKey, List(String)), words: Set(String))
        }

2. get coordinates (aka playspot) of every legal place to play (i.e. physically
   legal, no dictionary checks yet)
   - filter each playspot by 3 criteria:
     - is at least one playspot cell empty?
     - is at least one playspot cell perpendicularly adjacent to an already
       played word?
     - is the playspot not a subword? ie the square before first letter and
       after last letter empty?
3. pair each of these with their corresponding cloze on the board
   - `#(playspot, "A_")`
4. group these pairings by cloze
   - now each cloze will be associated with 1+ playspots
   - `dict(cloze, list(playspot))`
5. for every cloze find every dictionary valid word that is compatible with
   cloze and rack
   - use pre-computed dictionary to get filtered list of words, then perform
     linear scan
   - `#(list(playspots), list(word))`
6. flatten into `#(playspot, word)` pairs
7. remove from `#(playspot, word)` list any pairing that, if played, produces a
   word not in the dictionary
   - check both main axis and all cross-axes
8. score all remaining valid playable spots and order from highest point value
   to lowest

## Terminology

- Cloze
  - a string with unknown characters
  - e.g. `HE__O`, `W_RLD`

- Playspot
  - a list of cells
  - e.g. `[(x,y),(x,y),(x,y),(x,y),(x,y),(x,y),(x,y),(x,y)]`

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
