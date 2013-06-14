use v6;
use Test;
plan 23;

use Text::Levenshtein::Damerau;

is( edistance('four','four'),   0, 'test edistance matching');
is( edistance('four','for'),    1, 'test edistance insertion');
is( edistance('four','fourth'), 2, 'test edistance deletion');
is( edistance('four','fuor'),   1, 'test edistance transposition');
is( edistance('four','fxxr'),   2, 'test edistance substitution');
is( edistance('four','FOuR'),   3, 'test edistance case');
is( edistance('four',''), 	    4, 'test edistance target empty');
is( edistance('','four'), 	    4, 'test edistance source empty');
is( edistance('',''), 		    0, 'test edistance source & target empty');
is( edistance('11','1'), 	    1, 'test edistance numbers');
is( edistance('xxx','x',1),    -1, 'test edistance > max distance setting');
is( edistance('xxx','xx',1),    1, 'test edistance <= max distance setting');

# some extra maxDistance tests
is( edistance("xxx","xxxx",1),  1,  'test xs_edistance misc 1');
is( edistance("xxx","xxxx",2),  1,  'test xs_edistance misc 2');
is( edistance("xxx","xxxx",3),  1,  'test xs_edistance misc 3');
is( edistance("xxxx","xxx",1),  1,  'test xs_edistance misc 4');
is( edistance("xxxx","xxx",2),  1,  'test xs_edistance misc 5');
is( edistance("xxxx","xxx",3),  1,  'test xs_edistance misc 6');


# Test some utf8
is( edistance('ⓕⓞⓤⓡ','ⓕⓞⓤⓡ'), 	0, 'test edistance matching (utf8)');
is( edistance('ⓕⓞⓤⓡ','ⓕⓞⓡ'), 	1, 'test edistance insertion (utf8)');
is( edistance('ⓕⓞⓤⓡ','ⓕⓞⓤⓡⓣⓗ'), 2, 'test edistance deletion (utf8)');
is( edistance('ⓕⓞⓤⓡ','ⓕⓤⓞⓡ'), 	1, 'test edistance transposition (utf8)');
is( edistance('ⓕⓞⓤⓡ','ⓕⓧⓧⓡ'), 	2, 'test edistance substitution (utf8)');

