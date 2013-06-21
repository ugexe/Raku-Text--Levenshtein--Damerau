use v6;
use Test;
plan 39;
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

# test max distance
is( ld("foo","four",1),			  Inf,"(max distance) Correct ld foo four");
is( ld("foo","foo",1),				0,"(max distance) Correct ld foo foo");
is( ld("cow","cat",2),				2,"(max distance) Correct ld cow cat");
is( ld("cat","moocow",5),			5,"(max distance) Correct ld cat moocow");
is( ld("cat","cowmoo",4),		  Inf,"(max distance) Correct ld cat cowmoo");
is( ld("sebastian","sebastien",4),	1,"(max distance) Correct ld sebastian sebastien");
is( ld("more","cowbell",0),			5,"(max distance) Correct ld more cowbell");
is( ld("a","xxxxxxxx",5),		  Inf,"(max distance) length difference shortcut");

# some extra maxDistance tests
is( ld("xxx","xxxx",1),     1,  'test ld misc 1');
is( ld("xxx","xxxx",2),     1,  'test ld misc 2');
is( ld("xxx","xxxx",3),     1,  'test ld misc 3');
is( ld("xxxx","xxx",1),     1,  'test ld misc 4');
is( ld("xxxx","xxx",2),     1,  'test ld misc 5');
is( ld("xxxx","xxx",3),     1,  'test ld misc 6');
is( ld("xxxxxx","xxx",2), Inf,  'test ld misc 7');
is( ld("xxxxxx","xxx",3),   3,  'test ld misc 8');
is( ld("a","xxxxxxxx",5), Inf,  'test ld misc 9 (length shortcut)');




# Test some utf8
is( ld('ⓕⓞⓤⓡ','ⓕⓞⓤⓡ'), 		0, 'test ld matching (utf8)');
is( ld('ⓕⓞⓤⓡ','ⓕⓞⓡ'), 		1, 'test ld insertion (utf8)');
is( ld('ⓕⓞⓤⓡ','ⓕⓞⓤⓡⓣⓗ'), 	2, 'test ld deletion (utf8)');
is( ld('ⓕⓞⓤⓡ','ⓕⓤⓞⓡ'), 		2, 'test ld (no) transposition (utf8)');
is( ld('ⓕⓞⓤⓡ','ⓕⓧⓧⓡ'), 		2, 'test ld substitution (utf8)');
