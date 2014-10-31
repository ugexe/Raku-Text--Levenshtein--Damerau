use v6;

# TODO:
# Perl6-ify the code
# Try to implement $max for damerau levenshtein
# Switch levenshtein to 2 vector version?
# More helpers, like ordering the %.results, transposition => 0 (use &ld)

class Text::Levenshtein::Damerau {
    has @.targets;
    has @.sources;
    has $.max;  # Nil/-1 = no max distance
    has $.results_limit; # Only return X closest results
    has %.results       is rw;
    has $.best_index     is rw;
    has $.best_distance  is rw;
    has $.best_target    is rw;


    submethod BUILD(:@!sources, :@!targets, Int :$!max = 0) {
        # nothing to do here, the signature binding
        # does all the work for us.
    }

    method get_results {    
        await do for @.sources -> $source {
            await do for @.targets -> $target {
                start {
                    my $distance       = dld( $source, $target, $.max );
                    %.results{$target} = { distance => $distance };
        
                    if !$.best_distance.defined || $.best_distance > $distance {
                        $.best_distance = $distance;
                        $.best_target   = $target;
                    }
                }
            }
        }
    }

    # Java BUILD?
    #public DamerauLevensteinMetric(int maxLength) {
    #        currentRow = new int[maxLength + 1];
    #        previousRow = new int[maxLength + 1];
    #        transpositionRow = new int[maxLength + 1];
    #}


    sub dld (Str $source is copy, Str $target is copy, Int $max is copy = 0) is export {
        $max = $max > 0 ?? $max !! [max] $source.chars, $target.chars;
        my Int $firstLength = $source.chars;
        my Int $secondLength = $target.chars;
        my Int @currentRow;
        my Int @previousRow;
        my Int @transpositionRow;

        if ($firstLength == 0) {
            return $secondLength;
        }
        elsif ($secondLength == 0) {
            return $firstLength;
        }

        if ($firstLength > $secondLength) {
            my Str $tmp   = $source;
            $source       = $target;
            $target       = $tmp;
            $firstLength  = $secondLength;
            $secondLength = $target.chars;
        }

        if ($max < 0) {
            $max = $secondLength;
        }


        if ($secondLength - $firstLength > $max) {
            return Nil;
            # return $max + 1; or we can this to return Int and not Any for Nil
        }

        if ($firstLength > @currentRow.elems) {
            @currentRow       = ();
            @previousRow      = ();
            @transpositionRow = ();
        }

        for 0..$firstLength+1 -> Int $init {
            @previousRow[$init] = $init;
        }

        my Str $lastSecondCh = '';
        loop (my Int $i = 1; $i <= $secondLength; $i++) {
            my Str $secondCh = $target.substr($i - 1, 1);
            @currentRow[0] = $i;

            my Int $start = [max] 
                $i - $max - 1, 
                1;

            my Int $end   = [min] 
                $i + $max + 1, 
                $firstLength;

            my Str $lastFirstCh = '';
            loop (my Int $j = $start; $j <= $end; $j++) {
                my Str $firstCh = $source.substr($j - 1, 1);
                my Int $cost  = $firstCh eq $secondCh ?? 0 !! 1;
                my Int $value = [min] 
                    @currentRow\[$j - 1] + 1, 
                    @previousRow[$j>=@previousRow.elems??*-1!!$j] + 1,
                    @previousRow[$j - 1] + $cost;
                if ($firstCh eq $lastSecondCh && $secondCh eq $lastFirstCh) {
                    $value = [min] 
                        $value, 
                        @transpositionRow[$j - 2] + $cost;
                }

                @currentRow[$j] = $value;
                $lastFirstCh    = $firstCh;
            }

            $lastSecondCh = $secondCh;

            my Int @tempRow   = @transpositionRow;
            @transpositionRow = @previousRow;
            @previousRow      = @currentRow;
            @currentRow       = @tempRow;
        }

        return @previousRow[$firstLength] <= $max ?? @previousRow[$firstLength] !! Nil;
    }


    sub ld ( Str $source, Str $target, Int $max = 0 ) returns Num is export {
        my Int $source_length = $source.chars;
        my Int $target_length = $target.chars;
        #return Inf if ($max !== 0 && abs($source_length - $target_length) > $max);
        return ($source_length??$source_length.Num!!$target_length.Num) if (!$target_length || !$source_length);

        my Array @scores = ([0..$target_length],[]);
        my Int $large_value;

        # some cruft that will be refactored
        if $max > 0 {
            $large_value = $max + 1;
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

            if $max > 0 {
                if $source_index > $max {
                    $min_target = $source_index - $max;
                }
                if $target_length > $max + $source_index {
                    $max_target = $max + $source_index;
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

            # doesnt work when the expected score == max
            #if $max !== 0 && $col_min > $max {
            #    return Inf;
            #}
        }

        
        my $score = @scores[$source_length % 2][$target_length].Num;
        return ($score > $max && $max !== 0)??Inf!!$score;
    }
}