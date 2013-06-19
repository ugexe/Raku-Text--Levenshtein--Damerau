use v6;
use Text::Levenshtein::Damerau;
use Benchmark;

my Int $x    = 5; # string multiplier
my Str $str1 = "four"  x $x;
my Str $str2 = "fuoru" x $x;

# Note speed advantage of Text::Levenshtein::Damerau::ld 
# over Text::Levenshtein::distance after running :)

sub MAIN(Int $runs = 10) {
	say "start\t\tend\t\tdiff\tavg";
	say "------------------------------------------------";
	{
		say <# Text::Levenshtein::Damerau::dld($str1, $str2)>;
		my Int @stats = timethis($runs,  sub { dld($str1, $str2); }); 
		say @stats.join("\t");
	}
	say "------------------------------------------------";
	{
		say <# Text::Levenshtein::Damerau::ld($str1, $str2)>;
		my Int @stats = timethis($runs, sub { ld($str1, $str2); }); 
		say @stats.join("\t");
	}
	say "------------------------------------------------";
}
sub USAGE() {
    say "Usage: benchmark.p6 <number of runs>";
}