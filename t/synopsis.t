    use Text::Levenshtein::Damerau;

    my @names = 'John','Jonathan','Jose','Juan','Jimmy';
    my $name_mispelling = 'Jonh';

    my $dl = Text::Levenshtein::Damerau.new(
        max             => 0,       # default 
        targets         => @names,  # required
        sources         => [$name_mispelling]
    );

    say "Lets search for a 'John' but mistyped...";
    $dl.get_results;

    my %results = $dl.results;

    # Display each string and is distance
    for %results.kv -> $source,%vhash {
        for %vhash.values -> $target {
            say "source:$source target:$target dld:" ~ (%results{$source}{$target} // "<max exceeded>");
        }
    }

    # More info
    say "----------------------------";
    say "\$dl.best_distance:        {$dl.best_distance}";
    say "-";
    say "\$dl.targets:              {~$dl.targets}";
    say "\$dl.best_target:          {$dl.best_target}";
    say "-";
    say "\@names:                   {~@names}";