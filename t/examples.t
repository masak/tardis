use v6;
use Test;

use Tardis;

my Tardis::Debugger $debugger .= new(program => AST::Node::Statementlist.new());
$debugger.run;

is +$debugger.ticks, 1, 'empty program has 1 tick';
is +$debugger.ticks[0].pad.variables, 0,
   'there are no variables in the current pad';

$debugger .= new(
    program => AST::Node::Statementlist.new(
        AST::Node::Assignment.new(
            AST::Node::Declaration.new(
                'my',
                AST::Node::Variable.new('$a')
            ),
            AST::Node::Literal.new(42)
        )
    )
);
$debugger.run;

is +$debugger.ticks, 2, 'single-assignment program has 2 ticks';

{
    my @ticks = $debugger.ticks;
    is +@ticks[0].pad.variables, 1,
       'there is one variable in the current pad';
    is @ticks[0].pad.variables<$a>, 'Any',
       'before assignment, var is undefined';
    is @ticks[1].pad.variables<$a>, '42',
       'after assignment, var is 42';
}

$debugger .= new(
    program => AST::Node::Statementlist.new(
        AST::Node::Assignment.new(
            AST::Node::Declaration.new(
                'my',
                AST::Node::Variable.new('$a')
            ),
            AST::Node::Op.new(
                'postfix:<++>',
                AST::Node::Variable.new('$a')
            )
        )
    )
);
$debugger.run;

is +$debugger.ticks, 3, 'assignment with ++ has 3 ticks';

{
    my @ticks = $debugger.ticks;
    is @ticks[0].pad.variables<$a>, 'Any',
       'at start, var is undefined';
    is @ticks[1].pad.variables<$a>, 1,
       'after postfix:<++>, var is 1';
    is @ticks[2].pad.variables<$a>, 'Any',
       'after assignment, var is undefined';
}

done_testing;
