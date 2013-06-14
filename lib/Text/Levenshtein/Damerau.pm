module Text::Levenshtein::Damerau;
use v6;

sub edistance ( Str $source, Str $target, Int $max_distance = 0 ) is export
{
    my $source_length = $source.chars;
    my $target_length = $target.chars;

    return -1 if ($max_distance !== 0 && abs($source_length - $target_length) > $max_distance);
    return ($source_length??$source_length!!$target_length) if (!$target_length || !$source_length);

    my $lengths_max = $source_length + $target_length;
    my Int %dictionary_count; 
    my Int @scores = ( [$lengths_max,$lengths_max], [$lengths_max,0] );              

    # Work Loops
    for 1..$source_length -> $source_index  {
        my $swap_count = 0;
        %dictionary_count{ $source.substr( $source_index - 1, 1 ) } = 0;
        push @scores, [$lengths_max,$source_index]; 

        for 1..$target_length -> $target_index {
            if ( $source_index == 1 ) {
                %dictionary_count{ $target.substr( $target_index - 1, 1 ) } = 0;
                @scores[1][$target_index+1] = $target_index;
                @scores[0][$target_index+1] = $lengths_max;
            }

            my $target_char_count =
                %dictionary_count{ $target.substr( $target_index - 1, 1 ) };

            my $swap_score = @scores[$target_char_count][$swap_count] +
                ( $source_index - $target_char_count - 1 ) + 1 +
                ( $target_index - $swap_count - 1 );

            if ($source.substr( $source_index - 1, 1 ) ne
                $target.substr( $target_index - 1, 1 ) )
            {
                @scores[$source_index+1][$target_index+1] = min (
                    @scores[$source_index][$target_index]  +1,
                    @scores[$source_index+1][$target_index]+1,
                    @scores[$source_index][$target_index+1]+1,
                    $swap_score
                );
            }
            else {
                $swap_count = $target_index;

                @scores[$source_index+1][$target_index+1] = min (
                  @scores[$source_index][$target_index], $swap_score
                );
            }
        }

        %dictionary_count{ $source.substr( $source_index - 1, 1 ) } =
          $source_index;
    }
 
    my $score = @scores[$source_length+1][$target_length+1];
    return ($max_distance !== 0 && $max_distance < $score)??(-1)!!$score;
}


=encoding utf8

=head1 NAME

Text::Levenshtein::Damerau:: - Damerau Levenshtein edit distance.

=head1 SYNOPSIS

    use v6;
    use Text::Levenshtein::Damerau;

    say edistance('Neil','Niel');
    # prints 1

=head1 DESCRIPTION

Returns the true Damerau Levenshtein edit distance of strings with adjacent transpositions. 

    use Text::Levenshtein::Damerau;

    say edistance('ⓕⓞⓤⓡ','ⓕⓤⓞⓡ'), 
    # prints 1

=head1 METHODS

=head2 edistance

Arguments: source string and target string.

=over

=item * I<OPTIONAL 3rd argument> int (max distance; only return results with $int distance or less). 0 = unlimited. Default = 0.

=back

Returns: int that represents the edit distance between the two argument. Stops calculations and returns -1 if max distance is set and reached.

Calculates the edit distance between a source and target string.

    use Text::Levenshtein::Damerau;
    say edistance('AABBCC','AABCBCD');
    # prints 2

    # Max edit distance of 1
    say edistance('AABBCC','AABCBCD',1); # distance is 2
    # prints -1

=head1 BUGS

Please report bugs to:

L<https://github.com/ugexe/Perl6-Text--Levenshtein--Damerau/issues>

=head1 AUTHOR

Nick Logan <F<ugexe@cpan.org>>

=cut
