use v6;
use Text::Levenshtein::Damerau;
use Benchmark;

sub MAIN(Int $runs = 10000) {
	say "start\t\tend\t\tdiff\tavg";
	say "------------------------------------------------";
	{
		say "#small strings";
		my @stats = timethis($runs,  sub { edistance("four","fuoru"); }); 
		say @stats.join("\t");
	}
	say "------------------------------------------------";
	{
		say "#medium strings";
		my @stats = timethis($runs, sub { edistance("four" x 1000,"fuoru" x 1000); }); 
		say ~@stats;
	}
	say "------------------------------------------------";
	{
		say "#large strings";
		my @stats = timethis($runs, sub { edistance("four" x 100000,"fuoru" x 100000); }); 
		say ~@stats;
	}
	say "------------------------------------------------";
}
sub USAGE() {
    say "Usage: benchmark.p6 <number of runs>";
}