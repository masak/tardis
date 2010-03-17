use v6;

use Test;
plan *;

use Yapsi;
my Yapsi::Compiler $c .= new;

my @programs-that-parse =
    '',
    ';',
    'my $a',
    'my $a;',
;

for @programs-that-parse -> $program {
    my $can-parse = False;
    try {
        $c.compile($program);
        $can-parse = True;
    }
    ok $can-parse, "will parse '$program'";
}

my @programs-that-don't-parse =   # '
    '$a',
    'my',
    '$a; my $a',
    'my $a =',
;

for @programs-that-don't-parse -> $program { # '
    my $can-parse = False;
    try {
        $c.compile($program);
        $can-parse = True;
    }
    ok !$can-parse, "will not parse '$program'";
}

done_testing;