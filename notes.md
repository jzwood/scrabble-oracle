# cloze algorithm challenge

### given
- 1 cloze e.g. "AA___O__"
- 300_000 english words (ascii)

### challenge
write an algorithm to efficiently find all words that match the cloze.
for "AA___O__" the only valid word is "AARDWOLF"

### naive
```
words.find(regex: /^AA...O..$/)
```

### rules
- compile time computation allowed but cloze is only known at runtime
- speed performance prefered over space but not ad-absurdum
