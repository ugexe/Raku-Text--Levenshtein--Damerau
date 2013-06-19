use v6;
use Test;
plan 22;
use Text::Levenshtein::Damerau;


is( ld('four','for'), 		1, 'test ld insertion');
is( ld('four','four'), 		0, 'test ld matching');
is( ld('four','fourth'), 	2, 'test ld deletion');
is( ld('four','fuor'), 		2, 'test ld (no) transposition');
is( ld('four','fxxr'), 		2, 'test ld substitution');
is( ld('four','FOuR'), 		3, 'test ld case');
is( ld('four',''), 			4, 'test ld target empty');
is( ld('','four'), 			4, 'test ld source empty');
is( ld('',''), 				0, 'test ld source and target empty');
is( ld('111','11'), 		1, 'test ld numbers');

is( ld("foo","four"),				2,"Correct ld foo four");
is( ld("foo","foo"),				0,"Correct ld foo foo");
is( ld("cow","cat"),				2,"Correct ld cow cat");
is( ld("cat","moocow"),				5,"Correct ld cat moocow");
is( ld("cat","cowmoo"),				5,"Correct ld cat cowmoo");
is( ld("sebastian","sebastien"),	1,"Correct ld sebastian sebastien");
is( ld("more","cowbell"),			5,"Correct ld more cowbell");


# Test some utf8
is( ld('ⓕⓞⓤⓡ','ⓕⓞⓤⓡ'), 		0, 'test ld matching (utf8)');
is( ld('ⓕⓞⓤⓡ','ⓕⓞⓡ'), 		1, 'test ld insertion (utf8)');
is( ld('ⓕⓞⓤⓡ','ⓕⓞⓤⓡⓣⓗ'), 	2, 'test ld deletion (utf8)');
is( ld('ⓕⓞⓤⓡ','ⓕⓤⓞⓡ'), 		2, 'test ld (no) transposition (utf8)');
is( ld('ⓕⓞⓤⓡ','ⓕⓧⓧⓡ'), 		2, 'test ld substitution (utf8)');
