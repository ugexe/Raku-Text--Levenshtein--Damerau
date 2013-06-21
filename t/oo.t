use v6;
use Test;
plan 7;
use Text::Levenshtein::Damerau;

{
	my @names = 'John','Jonathan','Jose','Juan','Jimmy';
	my $name_mispelling = 'Jonh';

	my $dl = Text::Levenshtein::Damerau.new( targets => @names );
	$dl.get_results(source => $name_mispelling);
	my %results = $dl.results;

	is( $dl.best_target, @names[$dl.best_index], 	'test $dl.best_target and $dl.best_index');
	is( $dl.best_target, 'John', 					'test $dl.best_target manually');
	is( $dl.best_distance, 1, 						'test $dl.best_distance');
	is( %results<John><index>, 0, 					'test .results index');
	is( %results<John><distance>, 1, 				'test .results distance');
	is( %results<Jose><index>, 2, 					'test .results index again');
	is( %results<Jose><distance>, 2, 				'test .results distance again');
}
