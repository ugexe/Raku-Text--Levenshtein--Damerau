# NAME

Text::Levenshtein::Damerau:: - Levenshtein and Damerau Levenshtein edit distances.

# SYNOPSIS

    use v6;
    use Text::Levenshtein::Damerau;

    say dld('Neil','Niel'); # damerau levenstein distance
    # prints 1

    say ld('Neil','Niel'); # levenshtein distance
    prints 2

# DESCRIPTION

Returns the true Levenshtein or Damerau Levenshtein edit distance of strings with adjacent transpositions. Experimental OO features started; example in examples/oo_results.p6

    use Text::Levenshtein::Damerau;

    say dld('ⓕⓞⓤⓡ','ⓕⓤⓞⓡ'), 
    # prints 1

# METHODS

## dld

Damerau Levenshtein Distance (Levenshtein Distance including transpositions)

Arguments: source string and target string.

- _OPTIONAL 3rd argument_ int $max distance. 0 = unlimited. Default = 0.

Returns: int that represents the edit distance between the two argument. Stops calculations and returns Nil if max distance is set and reached.


    use Text::Levenshtein::Damerau;
    say dld('AABBCC','AABCBCD');
    # prints 2

    # Max edit distance of 1
    say dld('AABBCC','AABCBCD',1); # distance is 2
    # prints Nil

## ld

Levenshtein Distance (no transpositions)

Arguments: source string and target string.

- _OPTIONAL 3rd argument_ int $max distance. 0 = unlimited. Default = 0. 

Returns: int that represents the edit distance between the two argument. Stops calculations and returns Nil if max distance is set and reached.

    use Text::Levenshtein::Damerau;
    say ld('AABBCC','AABCBCD');
    # prints 3

    # Max edit distance of 1
    say ld('AABBCC','AABCBCD',1); # distance is 3
    # prints Nil

# BUGS

Please report bugs to:

[https://github.com/ugexe/Perl6-Text--Levenshtein--Damerau/issues](https://github.com/ugexe/Perl6-Text--Levenshtein--Damerau/issues)

# AUTHOR

Nick Logan <`ugexe@cpan.org`\>
