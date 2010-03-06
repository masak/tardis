use v6;

class AST::Node::Declaration {}
class AST::Node::Assignment {}
class AST::Node::Variable {}
class AST::Node::Literal {}
class AST::Node::Op {}

class Tardis::Pad {
    method variables() {
        0
    }

    method variable($name) {
        'Any'
    }
}

class Tardis::Tick {
    method pad() {
        Tardis::Pad.new();
    }
}

class Tardis::Debugger {
    has @!program;
    has Tardis::Tick @.ticks;

    method run() {
        @!ticks.push( Tardis::Tick.new() );     # empty starting state
        for @!program -> $statement {
            @!ticks.push( Tardis::Tick.new() ); # state after statement
        }
    }
}
