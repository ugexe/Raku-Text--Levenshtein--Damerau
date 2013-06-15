use v6;
use Text::Levenshtein::Damerau;
use Benchmark;

sub MAIN(Int $runs = 10000) {
	say "start\t\tend\t\tdiff\tavg";
	say "------------------------------------------------";
	{
		say "#small strings";
		my Str $str1 = "four";
		my Str $str2 = "fuor";
		my Int @stats = timethis($runs,  sub { edistance($str1, $str2); }); 
		say @stats.join("\t");
	}
	say "------------------------------------------------";
	{
		say "#medium strings";
		my Str $str1 = "four" x 1000;
		my Str $str2 = "fuoru" x 1000;
		my Int @stats = timethis($runs, sub { edistance($str1, $str2); }); 
		say ~@stats;
	}
	say "------------------------------------------------";
	{
		say "#large strings";
		my Str $str1 = "four" x 100000;
		my Str $str2 = "fuoru" x 100000;
		my Int @stats = timethis($runs, sub { edistance($str1, $str2); }); 
		say ~@stats;
	}
	say "------------------------------------------------";
}
sub USAGE() {
    say "Usage: benchmark.p6 <number of runs>";
}