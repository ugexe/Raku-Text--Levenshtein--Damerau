use v6;
class Text::Levenshtein::Damerau;

has @.targets        is rw;
has @.sources        is rw;
has $.max            is rw;  # Nil/-1 = no max distance
has $.results_limit  is rw; # Only return X closest results
has %.results        is rw;
has $.best_index     is rw;
has $.best_distance  is rw;
has $.best_target    is rw;


submethod BUILD(:@!sources, :@!targets, Int :$!max) {
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


sub dld (Str $source is copy, Str $target is copy, Int $max?) is export {
    my Int $maxd = ($max.defined && $max >= 0) ?? $max !! $source.chars max $target.chars;
    my Int $sourceLength  = $source.chars;
    my Int $targetLength = $target.chars;
    my Int (@currentRow, @previousRow, @transpositionRow);

    # Swap source/target so that $sourceLength always contains the shorter string
    if ($sourceLength > $targetLength) {
        ($source,$target)             .= reverse;
        ($sourceLength,$targetLength) .= reverse;
    }

    return ((!$max.defined || $maxd <= $targetLength)
        ?? $targetLength !! Nil) if 0 ~~ any($sourceLength|$targetLength);

    my Int $diff = $targetLength - $sourceLength;
    return Nil if $max.defined && $diff > $maxd;
    
    @previousRow[$_] = $_ for 0..$sourceLength+1;


    my Str $lastTargetCh = '';
    for 1..$targetLength -> Int $i {
        my Str $targetCh = $target.substr($i - 1, 1);
        @currentRow[0]   = $i;

        my Int $start = [max] $i - $maxd - 1, 1;
        my Int $end   = [min] $i + $maxd + 1, $sourceLength;

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
                    !! $maxd;

            $lastSourceCh = $sourceCh;
        }

        $lastTargetCh = $targetCh;

        my Int @tempRow   = @transpositionRow;
        @transpositionRow = @previousRow;
        @previousRow      = @currentRow;
        @currentRow       = @tempRow;
    }

    return (!$max.defined || @previousRow[$sourceLength] <= $maxd) ?? @previousRow[$sourceLength] !! Nil;
}

sub ld ( Str $source is copy, Str $target is copy, Int $max?) is export {
    my Int $maxd = ($max.defined && $max >= 0) ?? $max !! $source.chars max $target.chars;
    my Int $sourceLength = $source.chars;
    my Int $targetLength = $target.chars;
    my Int (@currentRow, @previousRow);

    #Swap source/target so that $sourceLength always contains the shorter string
    if ($sourceLength > $targetLength) {
        ($source,$target)             .= reverse;
        ($sourceLength,$targetLength) .= reverse;
    }

    return ((!$max.defined || $maxd <= $targetLength)
        ?? $targetLength !! Nil) if 0 ~~ any($sourceLength|$targetLength);

    my Int $diff = $targetLength - $sourceLength;
    return Nil if $max.defined && $diff > $maxd;

    @previousRow[$_] = $_ for 0..$sourceLength+1;

    for 1..$targetLength -> $i {
        my Str $targetCh = $target.substr($i - 1, 1);
        my Int $start = [max] $i - $maxd - 1, 1;
        my Int $end   = [min] $i + $maxd + 1, $sourceLength;
        @currentRow[0]   = $i;

        for $start..$end -> $j {
            my Str $sourceCh = $source.substr($j - 1, 1);
            @currentRow[$j] = [min] 
                @currentRow\[$j - 1] + 1,
                @previousRow[$j    ] + 1,
                @previousRow[$j - 1] + ($targetCh eq $sourceCh ?? 0 !! 1);

            return Nil if( @currentRow[0] == $j 
                && $maxd < (($diff => @currentRow[@currentRow[0]])
                    ?? ($diff - @currentRow[@currentRow[0]]) 
                    !! (@currentRow[@currentRow[0]] + $diff))
            );
        }

        @previousRow[$_] = @currentRow[$_] for 0..@currentRow.end;
    }

    return (!$max.defined || @currentRow[*-1] <= $maxd) ?? @currentRow[*-1] !! Nil;
}
