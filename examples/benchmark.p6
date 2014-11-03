use v6;
use Text::Levenshtein::Damerau; 
use Text::Levenshtein;
use Benchmark;

# benchmark.p6 <number of runs>
sub MAIN(Int $runs = 10) {
    for 1,100,1000,10000,100000 -> Int $multiplier {
        my Str $str1 = "four" x $multiplier;
        my Str $str2 = "fuoru" x $multiplier;
        say "Testing lengths:\n\$str1 = {$str1.chars}\n\$str1 = {$str2.chars}";

        my %results = timethese($runs, {
            'dld     ' => sub { Text::Levenshtein::Damerau::{"&dld($str1,$str2)"} },
            'ld      ' => sub { Text::Levenshtein::Damerau::{"&ld($str1,$str2)"}  },
            'distance' => sub { Text::Levenshtein::{"&distance($str1,$str2)"}     },
        });

        say ('func','start','end','diff','avg').join("\t\t");
        for %results.kv -> $description, @result {
            say ($description,@result).join("\t");
        }

        say "------------------------------------------------";
    }
}
