# NAME

Text::Levenshtein::Damerau:: - Damerau Levenshtein edit distance.

# SYNOPSIS

    use v6;
    use Text::Levenshtein::Damerau;

    say edistance('Neil','Niel');
    # prints 1

# DESCRIPTION

Returns the true Damerau Levenshtein edit distance of strings with adjacent transpositions. 

    use Text::Levenshtein::Damerau;

    say edistance('ⓕⓞⓤⓡ','ⓕⓤⓞⓡ'), 
    # prints 1

# METHODS

## edistance

Arguments: source string and target string.

- _OPTIONAL 3rd argument_ int (max distance; only return results with $int distance or less). 0 = unlimited. Default = 0.

Returns: int that represents the edit distance between the two argument. Stops calculations and returns -1 if max distance is set and reached.

Calculates the edit distance between a source and target string.

    use Text::Levenshtein::Damerau;
    say edistance('AABBCC','AABCBCD');
    # prints 2

    # Max edit distance of 1
    say edistance('AABBCC','AABCBCD',1); # distance is 2
    # prints -1

# BUGS

Please report bugs to:

[https://github.com/ugexe/Perl6-Text--Levenshtein--Damerau/issues](https://github.com/ugexe/Perl6-Text--Levenshtein--Damerau/issues)

# AUTHOR

Nick Logan <`ugexe@cpan.org`\>
