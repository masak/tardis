use v6;

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
    method run() {
    }

    method ticks() {
        ()
    }
}
