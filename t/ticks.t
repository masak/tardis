use v6;

use Test;
plan *;

use Tardis;

my @programs-ticks =
   '',
    "",
    'empty program',

   'my $a',
    "\$a = Any()",
    'uninitialised variable',

   'my $a = 42',
    "\$a = Any()\t\$a = 42",
    'initalised variable',

   'my $a = 42; ++$a',
    "\$a = Any()\t\$a = 42\t\$a = 43",
    'pre-increment',

   'my $a = 42; my $b; { $b = 5 }',
    "\$a = Any()\n\$b = Any()\t\$a = 42\n\$b = Any()\t\$a = 42\n\$b = Any()\t\$a = 42\n\$b = 5",
    'immediate blocks',

   'my $a = 42; { my $b = 5 }',
    "\$a = Any()\t\$a = 42\t\$b = Any()\n\$a = 42\t\$b = 5\n\$a = 42",
    'variable initialisation in immediate blocks',

   '{}; my $a = 42; { my $b = 5 };',
    "\$a = Any()\t\$a = Any()\t\$a = 42\t\$b = Any()\n\$a = 42\t\$b = 5\n\$a = 42",
    'multiple immediate blocks',

;

for @programs-ticks -> $program, $ticks, $message {
    my Yapsi::Compiler  $c .= new;
    my Tardis::Debugger $d .= new;

    my @sic = $c.compile($program);
    $d.run(@sic);

    my $result = $d.ticks.map({.fmt("%s = %s")}).join("\t");
    is $result , $ticks, $message;
}

done_testing;
