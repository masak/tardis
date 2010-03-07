use v6;

class AST::Node {
    method traverse(&callback) {
        die "No .traverse method specified for {self.WHAT}";
    }
}

class AST::Node::Statementlist is AST::Node {
    has AST::Node @.statements;

    method new(AST::Node *@statements) {
        self.bless(self.CREATE, :@statements);
    }

    method traverse(&callback) {
        .traverse(&callback) for @!statements;
        &callback(self);
    }
}

class AST::Node::Variable is AST::Node {
    has Str $.name;

    method new(Str $name) {
        self.bless(self.CREATE, :$name);
    }

    method traverse(&callback) {
        &callback(self);
    }
}

class AST::Node::Declaration is AST::Node {
    has AST::Node::Variable $.variable;

    method new(Str $type, AST::Node::Variable $variable) {
        self.bless(self.CREATE, :$variable);
    }

    method traverse(&callback) {
        $!variable.traverse(&callback);
        &callback(self);
    }
}

class AST::Node::Assignment is AST::Node {
    has AST::Node $.lhs;
    has AST::Node $.rhs;

    method new(AST::Node $lhs, AST::Node $rhs) {
        self.bless(self.CREATE, :$lhs, :$rhs);
    }

    method traverse(&callback) {
        $!lhs.traverse(&callback);
        $!rhs.traverse(&callback);
        &callback(self);
    }
}

class AST::Node::Literal is AST::Node {
    has $.value;

    method new($value) {
        self.bless(self.CREATE, :$value);
    }

    method traverse(&callback) {
        &callback(self);
    }
}

class AST::Node::Op is AST::Node {
    method traverse(&callback) {
        &callback(self);
    }
}

class Tardis::Pad {
    has %.variables;

    method modify(Str $varname, $value) {
        my %new-variables = %!variables;
        %new-variables{$varname} = $value;
        self.bless(self.CREATE, :variables(%new-variables));
    }
}

class Tardis::Tick {
    has Tardis::Pad $.pad;

    method new(:$pad) {
        self.bless(self.CREATE, :$pad);
    }
}

class Tardis::Debugger {
    has AST::Node::Statementlist $!program;
    has Tardis::Tick @.ticks;
    has Tardis::Pad $!pad; # XXX: there is more than one pad in general

    submethod BUILD($!program) {
        my %variables;
        $!program.traverse: method {
            if self ~~ AST::Node::Declaration {
                %variables{$.variable.name} = Any;
            }
        };
        $!pad = Tardis::Pad.new(:%variables);
    }

    method run() {
        my $pad = $!pad.clone;
        @!ticks.push( Tardis::Tick.new(:pad($pad.clone)) );
        # XXX: A for loop won't cut it for a deeply nested assignment. We'd
        #      need something a bit more like AST::Node.traverse.
        for $!program.statements -> $statement {
            if $statement ~~ AST::Node::Assignment {
                my $assignment = $statement;
                my $varname
                    = $assignment.lhs ~~ AST::Node::Declaration
                      ?? $assignment.lhs.variable.name
                      !! $assignment.lhs ~~ AST::Node::Variable
                         ?? $assignment.lhs.name
                         !! die 'Expected variable, found ',
                                $assignment.lhs.WHAT;
                $assignment.rhs ~~ AST::Node::Literal # XXX: Wrong
                    or die 'Expected literal, found ', $assignment.rhs.WHAT;
                my $value = $assignment.rhs.value;
                $pad.=modify($varname, $value);
            }
            @!ticks.push( Tardis::Tick.new(:pad($pad.clone)) );
        }
    }
}
