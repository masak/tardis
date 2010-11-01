use v6;
use Yapsi;

class Tardis::Debugger is Yapsi::Runtime {
    has @.ticks;

    method tick() {
        my %p;
        my $lexpad = $.current-lexpad;
        while defined $lexpad {
            for $lexpad.names.kv -> $name, $slot {
                %p{$name} //= $lexpad.slots[$slot].fetch.?payload;
            }
            $lexpad.=outer;
        }
        @.ticks.push: { %p };
    }
}
