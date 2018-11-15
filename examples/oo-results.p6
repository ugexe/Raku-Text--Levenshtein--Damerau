use v6;
use Text::Levenshtein::Damerau;

my @names = 'John','Jonny','Jose','Juan','Jimmy';
my $name_mispelling = 'Jonh';

say "Lets search for a 'John' but mistyped...";
my $dl = Text::Levenshtein::Damerau.new(
    targets         => @names,
    sources         => [$name_mispelling],
);
$dl.get_results;

my %results = $dl.results;

# Display each string and is distance
say "RESULT\t\tDISTANCE\tQUERY";
for %results.kv -> $string,$info {
    for $info.kv -> $index, $distance {
        say "{$index}\t\t{$distance}\t\t$string\n";
    }
}

# Show various attributes
say "----------------------------";
say "\$dl.best_distance:         {$dl.best_distance}";
say "\$dl.best_target:           {$dl.best_target}";
say "-";
say "\$dl.targets:               {~$dl.targets}";

