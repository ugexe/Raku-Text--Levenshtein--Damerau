use v6;

# TODO:
# Perl6-ify the code
# Try to implement $max_distance for damerau levenshtein
# Switch levenshtein to 2 vector version?
# More helpers, like ordering the %.results, transposition => 0 (use &ld)

class Text::Levenshtein::Damerau {

    has Str @.targets;
    has Str @.sources;
    has Int $.max_distance;  # undef = no max distance
    has Int $.results_limit; # Only return X closest results
    has Hash %.results       is rw;
    has Int $.best_index     is rw;
    has Num $.best_distance  is rw;
    has Str $.best_target    is rw;


    submethod BUILD(:@!sources, :@!targets, Int :$!max_distance = 0) {
        # nothing to do here, the signature binding
        # does all the work for us.
    }

    method get_results {    
        await do for @.sources -> $source {
            await do for @.targets -> $target {
                start {
                    my $distance       = dld( $source, $target, $.max_distance );
                    %.results{$target} = { distance => $distance };
        
                    if !$.best_distance.defined || $.best_distance > $distance {
                        $.best_distance = $distance;
                        $.best_target   = $target;
                    }
                }
            }
        }
    }

    # Core algorithm functions
    sub dld ( Str $source, Str $target, Int $max_distance = 0 ) returns Num is export {
        my Int $source_length = $source.chars;
        my Int $target_length = $target.chars;
        my Int $lengths_max = $source_length + $target_length;
        return Inf if ($max_distance !== 0 && abs($source_length - $target_length) > $max_distance);
        return ($source_length??$source_length.Num!!$target_length.Num) if (!$target_length || !$source_length);

        my Int %dictionary_count; 
        my Array @scores = ( [$lengths_max,$lengths_max], [$lengths_max,0] );              
        
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
     
        my Num $score = @scores[$source_length+1][$target_length+1].Num;
        return ($max_distance !== 0 && $max_distance < $score)??(Inf)!!$score;
    }


    sub ld ( Str $source, Str $target, Int $max_distance = 0 ) returns Num is export {
        my Int $source_length = $source.chars;
        my Int $target_length = $target.chars;
        #return Inf if ($max_distance !== 0 && abs($source_length - $target_length) > $max_distance);
        return ($source_length??$source_length.Num!!$target_length.Num) if (!$target_length || !$source_length);

        my Array @scores = ([0..$target_length],[]);
        my Int $large_value;

        # some cruft that will be refactored
        if $max_distance > 0 {
            $large_value = $max_distance + 1;
        }
        else {
            if $target_length > $source_length {
                $large_value = $target_length;
            }
            else {
                $large_value = $source_length;
            }
        }


        for 1..$source_length+1 -> Int $source_index  {
            my Int $next;
            my Int $prev;
            my Str $source_char = $source.substr($source_index-1,1);
            my Int $col_min = $large_value;
            my Int $min_target = 1;
            my Int $max_target = $target_length;

            if $max_distance > 0 {
                if $source_index > $max_distance {
                    $min_target = $source_index - $max_distance;
                }
                if $target_length > $max_distance + $source_index {
                    $max_target = $max_distance + $source_index;
                }
            }

            $next = $source_index % 2;

            if ($next == 1) {
                $prev = 0;
            }
            else {
                $prev = 1;
            }

            @scores[$next][0] = $source_index;

            for 1..$target_length+1 -> Int $target_index  {
                if ($target_index < $min_target || $target_index > $max_target) {
                    @scores[$next][$target_index] = $large_value;
                }
                else {
                    if $source_char eq $target.substr($target_index - 1, 1) {
                        @scores[$next][$target_index] = @scores[$prev][$target_index - 1];
                    }
                    else {
                        my Int $delete     = @scores[$prev][$target_index]     + 1; #[% delete_cost %];
                        my Int $insert     = @scores[$next][$target_index - 1] + 1; #[% insert_cost %];
                        my Int $substitute = @scores[$prev][$target_index - 1] + 1; #[% substitute_cost %];
                        my Int $minimum    = $delete;

                        if ($insert < $minimum) {
                            $minimum = $insert;
                        }
                        if ($substitute < $minimum) {
                            $minimum = $substitute;
                        }

                        @scores[$next][$target_index] = $minimum;
                    }
                }


                if @scores[$next][$target_index] < $col_min {
                    $col_min = @scores[$next][$target_index];
                }
            }

            # doesnt work when the expected score == max_distance
            #if $max_distance !== 0 && $col_min > $max_distance {
            #    return Inf;
            #}
        }

        
        my $score = @scores[$source_length % 2][$target_length].Num;
        return ($score > $max_distance && $max_distance !== 0)??Inf!!$score;
    }
}