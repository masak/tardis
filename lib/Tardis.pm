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
    method traverse(&callback) {
        &callback(self);
    }
}

class AST::Node::Op is AST::Node {}

class Tardis::Pad {
    has Str @.variables;

    method variable($name) {
        'Any'
    }
}

class Tardis::Tick {
    has Tardis::Pad $.pad;
}

class Tardis::Debugger {
    has AST::Node::Statementlist $!program;
    has Tardis::Tick @.ticks;
    has Tardis::Pad $!pad; # XXX: but there is more than one pad.

    submethod BUILD($!program) {
        my @variables;
        $!program.traverse: method {
            if self ~~ AST::Node::Declaration {
                push @variables, $.variable.name;
            }
        };
        $!pad = Tardis::Pad.new(:@variables);
    }

    method run() {
        @!ticks.push( Tardis::Tick.new(:pad($!pad)) );
        @!ticks.push( Tardis::Tick.new(:pad($!pad)) ) for $!program.statements;
    }
}
