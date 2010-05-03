use v6;
use Yapsi;

class Tardis::Debugger is Yapsi::Runtime {
    has @.ticks;

    method tick() {
        my %p;
        for $!env.pads.keys -> $block {
            my @variables;
            for $!env.pads{$block}.keys -> $var {
                push @variables, $var => self.get-value-of($var);
            }
            %p{$block} = @variables;
        }
        @.ticks.push: \%p;
    }
}
