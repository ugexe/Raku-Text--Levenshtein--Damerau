class Text::Levenshtein::Damerau;

# WARNING
# edistance is the only stable (and documented) function.
# The rest of the (undocumented) methods and API may change.

has Str @.targets is rw;
has Str $.source is rw;
has Int $.max_distance is rw;
has Int $.best_index is rw;
has Int $.best_distance is rw;
has Str $.best_target is rw;
has %.results is rw;

method get_results(:$.source) {    
    # use loop instead of for so we can return the index in some cases
    loop (my Int $index = 0; $index <= @.targets.elems - 1; $index++) {
        my Str $target     = @.targets[$index];
        my $distance       = edistance( $.source, $target, $.max_distance );
        %.results{$target} = { index => $index, distance => $distance };

        if !$.best_distance.defined || $.best_distance > $distance {
            $.best_index    = $index;
            $.best_distance = $distance;
            $.best_target   = $target;
        }
    }
}



sub edistance ( Str $source, Str $target, Int $max_distance = 0 ) returns Int is export
{
    my Int $source_length = $source.chars;
    my Int $target_length = $target.chars;
    my Int $lengths_max = $source_length + $target_length;

    return Nil if ($max_distance !== 0 && abs($source_length - $target_length) > $max_distance);
    return ($source_length??$source_length!!$target_length) if (!$target_length || !$source_length);

    my Int %dictionary_count; 
    my Int @scores = ( [$lengths_max,$lengths_max], [$lengths_max,0] );              
    
    # Work Loops
    for 1..$source_length -> Int $source_index  {
        my Int $swap_count = 0;
        %dictionary_count{ $source.substr( $source_index - 1, 1 ) } = 0;
        push @scores, [$lengths_max,$source_index]; 

        for 1..$target_length -> Int $target_index {
            if $source_index == 1 {
                %dictionary_count{ $target.substr( $target_index - 1, 1 ) } = 0;
                @scores[1][$target_index+1] = $target_index;
                @scores[0][$target_index+1] = $lengths_max;
            }

            my Int $target_char_count =
                %dictionary_count{ $target.substr( $target_index - 1, 1 ) };

            my Int $swap_score = @scores[$target_char_count][$swap_count] +
                ( $source_index - $target_char_count - 1 ) + 1 +
                ( $target_index - $swap_count - 1 );

            if $source.substr( $source_index - 1, 1 ) 
               ne $target.substr( $target_index - 1, 1 ) {
                @scores[$source_index+1][$target_index+1] = [min]
                    @scores[$source_index][$target_index]  +1,
                    @scores[$source_index+1][$target_index]+1,
                    @scores[$source_index][$target_index+1]+1,
                    $swap_score;
            }
            else {
                $swap_count = $target_index;

                @scores[$source_index+1][$target_index+1] = [min] 
                  @scores[$source_index][$target_index], $swap_score;
            }
        }

        %dictionary_count{ $source.substr( $source_index - 1, 1 ) } =
          $source_index;

        # This is where the max_distance abort ideally happens
    }
 
    my Int $score = @scores[$source_length+1][$target_length+1];
    return ($max_distance !== 0 && $max_distance < $score)??(Nil)!!$score;
}
