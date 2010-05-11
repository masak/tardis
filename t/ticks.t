use v6;

use Test;
plan *;

use Tardis;
use Yapsi;

my @programs-ticks =
    '',                                 1,    'empty program',
    'my $a',                            1,    'uninitialised variable',
    'my $a = 42',                       2,    'initalised variable',
    'my $a = 42; ++$a',                 3,    'pre-increment',
    'my $a = 42; my $b; { $b = 5 }',    3,    'immediate blocks',
    'my $a = 42; { my $b = 5 }',        4,    'variable initialisation in immediate blocks',
    '{}; my $a = 42; { my $b = 5 };',   4,    'multiple immediate blocks',
;


for @programs-ticks -> $program, $ticks, $message {
    my Yapsi::Compiler  $c .= new;
    my Tardis::Debugger $d .= new;

    my @sic = $c.compile($program);
    $d.run(@sic);

    is +$d.ticks, $ticks, $message;
}

done_testing;
