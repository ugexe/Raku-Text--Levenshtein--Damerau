use v6;
use Text::Levenshtein::Damerau;
use Text::Levenshtein;
use Benchmark;

# benchmark.p6 <number of runs>
sub MAIN(Int $runs = 10) {
    my Str $str1 = "four" x $multiplier;
    my Str $str2 = "fuoru" x $multiplier;

    for 1,100,1000,10000,100000 -> Int $multiplier {
        say "Testing lengths:\n\$str1 = {$str1.chars}\n\$str1 = {$str2.chars}";

        say "start\t\tend\t\tdiff\tavg";

        my $results = timethese($runs, {
            'Text::Levenshtein::Damerau::dld' => sub {},
            'Text::Levenshtein::Damerau::ld'  => sub {},
            'Text::Levenshtein::ld'           => sub {},
        });

        say "------------------------------------------------";
    }
}