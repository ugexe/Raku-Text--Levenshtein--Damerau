## Text::Levenshtein::Damerau

Levenshtein and Damerau Levenshtein edit distances

## Synopsis

    use Text::Levenshtein::Damerau;

    say dld('Neil','Niel'); # damerau levenstein distance
    # prints 1

    say ld('Neil','Niel'); # levenshtein distance
    prints 2

## Description

Returns the true Levenshtein or Damerau Levenshtein edit distance of strings with adjacent transpositions. 

### Routines

#### dld($source, $target, $max? --> Int)

Damerau Levenshtein Distance (Levenshtein Distance including transpositions)

`$max distance. 0 = unlimited. Default = 0`

    use Text::Levenshtein::Damerau;
    say dld('AABBCC','AABCBCD');
    # prints 2

    # Max edit distance of 1
    say dld('AABBCC','AABCBCD',1); # distance is 2
    # prints Int

#### ld($source, $target, $max? --> Int)

Levenshtein Distance (no transpositions)

`$max distance. 0 = unlimited. Default = 0`

    use Text::Levenshtein::Damerau;
    say ld('AABBCC','AABCBCD');
    # prints 3

    # Max edit distance of 1
    # Uses regular Levenshtein distance (no transpositions)
    say ld('AABBCC','AABCBCD',1); # distance is 3
    # prints Int

## Bugs

Please report bugs to:

https://github.com/ugexe/Raku-Text--Levenshtein--Damerau/issues
