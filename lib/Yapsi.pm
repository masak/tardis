use v6;

grammar Yapsi::Perl6::Grammar {
    regex TOP { ^ <statement> ** ';' $ }
    token statement { <expression> || '' }
    token expression { <variable> || <declaration> }
    token variable { '$' \w+ }
    rule  declaration { 'my' <variable> }
}

my %d; # a variable gets an entry in %d when it's declared

multi sub find-vars(Match $/, 'statement') {
    if $<expression> -> $e {
        find-vars($e, 'expression');
    }
}

multi sub find-vars(Match $/, 'expression') {
    for <variable declaration> -> $subrule {
        if $/{$subrule} -> $e {
            find-vars($e, $subrule);
        }
    }
}

multi sub find-vars(Match $/, 'variable') {
    if !%d.exists( ~$/ ) {
        die 'Invalid. ', ~$/, "not declared before use.\n";
    }
}

multi sub find-vars(Match $/, 'declaration') {
    my $name = ~$<variable>;
    if %d{$name}++ {
        warn "Useless redeclaration of variable $name\n";
    }
}

multi sub find-vars($/, $node) {
    die "Don't know what to do with a $node";
}

class Yapsi::Compiler {
    method compile($program) {
        die "Could not parse"
            unless Yapsi::Perl6::Grammar.parse($program);
        %d = ();
        for $<statement> -> $statement {
            find-vars($statement, 'statement');
        }
    }
}

