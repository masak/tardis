use v6;

grammar Yapsi::Perl6::Grammar {
    regex TOP { ^ <statement> ** ';' $ }
    token statement { <expression> || '' }
    token expression { <variable> || <literal> || <declaration>
                       || <assignment> || <saycall> }
    token lvalue { <declaration> || <variable> }
    token variable { '$' \w+ }
    token literal { \d+ }
    rule  declaration { 'my' <variable> }
    rule  assignment { <lvalue> '=' <expression> }
    rule  saycall { 'say' <expression> }  # very temporary solution
}

my %d; # a variable gets an entry in %d when it's declared

multi sub find-vars(Match $/, 'statement') {
    if $<expression> -> $e {
        find-vars($e, 'expression');
    }
}

multi sub find-vars(Match $/, 'expression') {
    for <variable declaration assignment saycall> -> $subrule {
        if $/{$subrule} -> $e {
            find-vars($e, $subrule);
        }
    }
}

multi sub find-vars(Match $/, 'lvalue') {
    for <variable declaration> -> $subrule {
        if $/{$subrule} -> $e {
            find-vars($e, $subrule);
        }
    }
}

multi sub find-vars(Match $/, 'variable') {
    if !%d.exists( ~$/ ) {
        die 'Invalid. ', ~$/, "not declared before use";
    }
}

multi sub find-vars(Match $/, 'literal') {
    die "This multi variant should never be called";
}

multi sub find-vars(Match $/, 'declaration') {
    my $name = ~$<variable>;
    if %d{$name}++ {
        warn "Useless redeclaration of variable $name";
    }
}

multi sub find-vars(Match $/, 'assignment') {
    find-vars($<lvalue>, 'lvalue');
    find-vars($<expression>, 'expression');
}

multi sub find-vars(Match $/, 'saycall') {
    find-vars($<expression>, 'expression');
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

