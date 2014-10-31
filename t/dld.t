use v6;
use Test;
plan 27;
use Text::Levenshtein::Damerau;

is( dld('four','four'),     0,  'test dld matching');
is( dld('four','for'),      1,  'test dld insertion');
is( dld('four','fourth'),   2,  'test dld deletion');
is( dld('four','fuor'),     1,  'test dld transposition');
is( dld('four','fxxr'),     2,  'test dld substitution');
is( dld('four','FOuR'),     3,  'test dld case');
is( dld('four',''),         4,  'test dld target empty');
is( dld('','four'),         4,  'test dld source empty');
is( dld('',''),             0,  'test dld source & target empty');
is( dld('11','1'),          1,  'test dld numbers');
is( dld('xxx','x',1),       Nil,'test dld > max distance setting');
is( dld('abab','baba',1),   Nil,'test dld > max distance setting (bypass length eject)');
is( dld('xxx','xx',1),      1,  'test dld <= max distance setting');

# some extra maxDistance tests
is( dld("xxx","xxxx",1),    1,  'test dld misc 1');
is( dld("xxx","xxxx",2),    1,  'test dld misc 2');
is( dld("xxx","xxxx",3),    1,  'test dld misc 3');
is( dld("xxxx","xxx",1),    1,  'test dld misc 4');
is( dld("xxxx","xxx",2),    1,  'test dld misc 5');
is( dld("xxxx","xxx",3),    1,  'test dld misc 6');
is( dld("xxxxxx","xxx",2),  Nil,'test dld misc 7');
is( dld("xxxxxx","xxx",3),  3,  'test dld misc 8');
is( dld("a","xxxxxxxx",5),  Nil,'test dld misc 9 (length shortcut)');

# Test some utf8
is( dld('ⓕⓞⓤⓡ','ⓕⓞⓤⓡ'),     0,  'test dld matching (utf8)');
is( dld('ⓕⓞⓤⓡ','ⓕⓞⓡ'),      1,  'test dld insertion (utf8)');
is( dld('ⓕⓞⓤⓡ','ⓕⓞⓤⓡⓣⓗ'),   2,  'test dld deletion (utf8)');
is( dld('ⓕⓞⓤⓡ','ⓕⓤⓞⓡ'),     1,  'test dld transposition (utf8)');
is( dld('ⓕⓞⓤⓡ','ⓕⓧⓧⓡ'),     2,  'test dld substitution (utf8)');

