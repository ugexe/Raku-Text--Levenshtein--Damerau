class Text::Levenshtein::Damerau;

# WARNING
# edistance is the only stable (and documented) function.
# The rest of the (undocumented) methods and API may change.

# TODO
# option to ignore case
# option to pass a @.source to iterate over each $.source
# add type to @.targets (change @.targets to @!targets for Str?)
# pod? or just README.md?
# credit Ben Bullock for his levenshtein work

# Values the user can edit
has @.targets       is rw;
has Str $.source        is rw;
has Int $.max_distance  is rw;

# Values the user can only read
has %.results is rw;
has Int $.best_index    is rw;
has Int $.best_distance is rw;
has Str $.best_target   is rw;


submethod BUILD(:@!targets, Str :$!source, Int :$!max_distance = 0) {
    # nothing to do here, the signature binding
    # does all the work for us.
}


method get_results(:$.source) {    
    # use loop instead of for so we can return the index in some cases
    loop (my Int $index = 0; $index <= @.targets.elems - 1; $index++) {
        my Str $target     = @.targets[$index];
        my $distance       = dld( $.source, $target, $.max_distance );
        %.results{$target} = { index => $index, distance => $distance };

        if !$.best_distance.defined || $.best_distance > $distance {
            $.best_index    = $index;
            $.best_distance = $distance;
            $.best_target   = $target;
        }
    }
}



sub dld ( Str $source, Str $target, Int $max_distance = 0 ) returns Int is export
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


sub ld ( Str $source, Str $target, Int $max_distance = 0 ) is export
{
    # optimized levenshtein algorithm modified from
    # Ben Bullock's (Perl 5) Text::Fuzzy XS/C code
    my Int $source_length = $source.chars;
    my Int $target_length = $target.chars;
    my Int $large_value;

    if ($max_distance >= 0) {
        $large_value = $max_distance + 1;
    }
    else {
        if ($target_length > $source_length) {
            $large_value = $target_length;
        }
        else {
            $large_value = $source_length;
        }
    }

    my @scores;

    # move this loop inside the second for loop below?
    loop (my $j = 0; $j <= $target_length; $j++) {
        @scores[0][$j] = $j;
    }


    for 1..$source_length -> Int $source_index  {
        my Int $next;
        my Int $prev;
        my Str $source_char = $source.substr($source_index-1,1);
        my $col_min = $large_value;
        my Int $min_target = 1;
        my Int $max_target = $target_length;

        if ($max_distance >= 0) {
            if ($source_index > $max_distance) {
                $min_target = $source_index - $max_distance;
            }
            if ($target_length > $max_distance + $source_index) {
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

        for 1..$target_length -> Int $target_index  {
            if ($target_length < $min_target || $target_length > $max_target) {
                @scores[$next][$target_length] = $large_value;
            }
            else {
                my Str $target_char = $target.substr($target_index - 1, 1);

                if ($source_char eq $target_char) {
                    @scores[$next][$target_length] = @scores[$prev][$target_length - 1];
                }
                else {
                    my Int $delete     = @scores[$prev][$target_length]     + 1; #[% delete_cost %];
                    my Int $insert     = @scores[$next][$target_length - 1] + 1; #[% insert_cost %];
                    my Int $substitute = @scores[$prev][$target_length - 1] + 1; #[% substitute_cost %];
                    my Int $minimum    = $delete;

                    if ($insert < $minimum) {
                        $minimum = $insert;
                    }
                    if ($substitute < $minimum) {
                        $minimum = $substitute;
                    }
                    @scores[$next][$target_length] = $minimum;
                }
            }

            if ($col_min.defined && @scores[$next][$target_length] < $col_min) {
                $col_min = @scores[$next][$target_length];
            }
        }

        if ($max_distance > 0) {
            if ($col_min.defined && $col_min > $max_distance) {
                return 10000;
            }
        }
    }

    return @scores[$source_length % 2][$target_length];
}
