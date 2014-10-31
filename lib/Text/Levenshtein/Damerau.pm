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


    sub dld (Str $source is copy, Str $target is copy, Int $max is copy = 0) is export {
        $max = $max > 0 ?? $max !! $source.chars max $target.chars;
        my Int $sourceLength  = $source.chars;
        my Int $targetLength = $target.chars;
        my Int (@currentRow, @previousRow, @transpositionRow);

        return [max] $sourceLength,$targetLength if 0 ~~ any($sourceLength|$targetLength);

        # Swap source/target so that $sourceLength always contains the shorter string
        if ($sourceLength > $targetLength) {
            ($source,$target)             .= reverse;
            ($sourceLength,$targetLength) .= reverse;
        }

        $max = $targetLength unless $max >= 0;
        return Nil if $targetLength - $sourceLength > $max;
        @currentRow      = @previousRow = @transpositionRow = ()
            if $sourceLength > @currentRow.elems;
        
        @previousRow[$_] = $_ for 0..$sourceLength+1;

        my Str $lastTargetCh = '';
        for 1..$targetLength -> Int $i {
            my Str $targetCh = $target.substr($i - 1, 1);
            @currentRow[0]   = $i;

            my Int $start = [max] $i - $max - 1, 1;
            my Int $end   = [min] $i + $max + 1, $sourceLength;

            my Str $lastSourceCh = '';
            for $start..$end -> Int $j {
                my Str $sourceCh = $source.substr($j - 1, 1);
                my Int $cost     = $sourceCh eq $targetCh ?? 0 !! 1;

                @currentRow[$j] = [min] 
                    @currentRow\[$j - 1] + 1, 
                    @previousRow[$j >= @previousRow.elems ?? *-1 !! $j] + 1,
                    @previousRow[$j - 1] + $cost,
                    ($sourceCh eq $lastTargetCh && $targetCh eq $lastSourceCh)
                        ?? @transpositionRow[$j - 2] + $cost
                        !! $max;;

                $lastSourceCh = $sourceCh;
            }

            $lastTargetCh = $targetCh;

            my Int @tempRow   = @transpositionRow;
            @transpositionRow = @previousRow;
            @previousRow      = @currentRow;
            @currentRow       = @tempRow;
        }

        return @previousRow[$sourceLength] <= $max ?? @previousRow[$sourceLength] !! Nil;
    }

    sub ld ( Str $source is copy, Str $target is copy, Int $max is copy = 0 ) returns Any is export {
        $max = $max > 0 ?? $max !! $source.chars max $target.chars;
        my Int $sourceLength = $source.chars;
        my Int $targetLength = $target.chars;
        my Int (@currentRow, @previousRow);
        my Int $diff = ($sourceLength max $targetLength) - ($sourceLength min $targetLength);

        return [max] $sourceLength,$targetLength if 0 ~~ any($sourceLength|$targetLength);
        $max = $targetLength unless $max >= 0;

        #Swap source/target so that $sourceLength always contains the shorter string
        if ($sourceLength > $targetLength) {
            ($source,$target)             .= reverse;
            ($sourceLength,$targetLength) .= reverse;
        }

        return Nil if $diff > $max;
        @currentRow = @previousRow= () if $sourceLength > @currentRow.elems;

        @previousRow[$_] = $_ for 0..$sourceLength+1;

        for 1..$targetLength+1 -> $i {
            my Str $targetCh = $target.substr($i - 1, 1);
            @currentRow[0]   = $i + 1;

            my Int $start = [max] $i - $max - 1, 1;
            my Int $end   = [min] $i + $max + 1, $sourceLength;

            for $start..$end -> $j {
                my Str $sourceCh = $source.substr($j - 1, 1);

                @currentRow[$j] = [min] 
                    @currentRow\[$j - 1] + 1,
                    @previousRow[$j    ] + 1,
                    @previousRow[$j - 1] + ($targetCh eq $sourceCh ?? 0 !! 1);

                return Nil if( @currentRow[0] == $j && $max < 
                    (($targetLength - $sourceLength > @currentRow[@currentRow[0]])
                    ?? ($diff - @currentRow[@currentRow[0]]) 
                    !! (@currentRow[@currentRow[0]] + $diff))
                );
            }

            if $i < $targetLength {
                @previousRow[$_] = @currentRow[$_] for 0..$targetLength+1;
            }
        }

        return @currentRow[*-1] <= $max ?? @currentRow[*-1] !! Nil;
    }
}