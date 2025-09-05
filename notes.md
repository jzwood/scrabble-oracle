# cloze algorithm challenge

### given
- 1 cloze e.g. "AA___O__"
- 300_000 english words (ascii)

### challenge
write an algorithm to efficiently find all words that match the cloze.
for example the only valid word for the cloze "AA___O__" is "AARDWOLF".

### naive
```
words.find(regex: /^AA...O..$/)
```

### rules
- compile time computation allowed but cloze is only known at runtime
- speed performance preferred over space but not ad-absurdum


### solution
- create dict with the keys 1-15 which maps to all words of that length
- if no known letters
    - linear scan
-

Dict(
  Int, // cloze length
  Dict(
    #(Int, String) // index of first known letter and letter
    List(String) // word list
  )
)

what about
Dict(
  #(Int, Int, String) // cloze length, index of first known letter, letter
  List(String) // word list
)


KABELES
#(7, 1, K)
#(7, 2, A)
#(7, 3, B)
#(7, 4, E)
#(7, 5, L)
#(7, 6, E)
#(7, 7, S)

let scrabble_words = ...
list.fold(scrabble_words, dict.new(), fn(acc, word) {
    let length = string.length(word)
    to_graphemes(word)
    |> list.index_map(pair.new)
    |> list_extra.group_inner(_, to_key: fn(tup) {
        let #(char, index) = tup
        #(length, index, char)
    }, to_val: pair.first, acc)
})
