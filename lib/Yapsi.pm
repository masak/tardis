use v6;

grammar Yapsi::Perl6::Grammar {
    regex TOP { ^ <statement> ** ';' $ }

    token statement { <expression> | '' }

    token expression { <variable> || <declaration> }

    token variable { '$' \w+ }

    rule  declaration { 'my' <variable> }
}

class Yapsi::Compiler {
    method compile($program) {
        die "Could not parse"
            unless Yapsi::Perl6::Grammar.parse($program);
    }
}
