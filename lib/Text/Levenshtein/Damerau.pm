module Text::Levenshtein::Damerau;
use v6;

sub edistance ( Str $source, Str $target, Int $max_distance = 0 ) is export
{
    my Int $source_length = $source.chars;
    my Int $target_length = $target.chars;
    my Int $lengths_max = $source_length + $target_length;

    return -1 if ($max_distance !== 0 && abs($source_length - $target_length) > $max_distance);
    return ($source_length??$source_length!!$target_length) if (!$target_length || !$source_length);

    my Int %dictionary_count; 
    my Int @scores = ( [$lengths_max,$lengths_max], [$lengths_max,0] );              

    # Work Loops
    for 1..$source_length -> $source_index  {
        my Int $swap_count = 0;
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
 
    my Int $score = @scores[$source_length+1][$target_length+1];
    return ($max_distance !== 0 && $max_distance < $score)??(-1)!!$score;
}
