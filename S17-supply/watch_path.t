use v6;
use lib 't/spec/packages';

use Test;

plan 23;

my $forawhile = .5;
my $filename = "watch_path_checker";
END { unlink $filename if $filename }  # make sure we cleanup

unlink $filename; # in case we missed the cleanup
ok !$filename.IO.e, "make sure we don't have a file";

{
    my $s = IO::Notification.watch_path('.').uniq;
    ok $s ~~ Supply, 'Did we get a Supply?';

    my @seen;
    my $tap = $s.tap( -> \event { @seen.push(event) } );
    isa_ok $tap, Tap, 'did we get a tap?';

    my $handle = open( $filename, :w );
    isa_ok $handle, IO::Handle, 'did we get a handle?';

    sleep $forawhile;
    is +@seen, 1, 'did we get an event for creating the file';

    ok $handle.say( "Hello world" ), 'did the write go ok';

    sleep $forawhile;
    is +@seen, 1, 'did we NOT get an event for writing to the file';

    ok $handle.close, 'did the file close ok';

    sleep $forawhile;
    is +@seen, 2, 'did we NOT get an event for closing the file';

    $handle = open( $filename, :a );
    isa_ok $handle, IO::Handle, 'did we get a handle again?';

    sleep $forawhile;
    is +@seen, 2, 'did we NOT get an event for opening the file again';

    ok $handle.say( "Hello world again" ), 'did the second write work';

    sleep $forawhile;
    is +@seen, 2, 'did we NOT get an event for writing to the file again';

    ok $handle.close, 'did closing the file again work';

    sleep $forawhile;
    is +@seen, 3, 'did we get an event for closing the file again';

    my $content = $filename.IO.slurp;
    is $content, "Hello world\nHello world again\n", "was the file written ok";

    sleep $forawhile;
    is +@seen, 3, 'a slurp should not cause any file events';

    unlink $filename;
    ok !$filename.IO.e, "test file removed successfully";

    sleep $forawhile;
    is +@seen, 4, 'the unlink caused an event';

    ok $tap.close, 'could we close the tap';
    $s.done;

    is +@seen.grep( IO::Notification::Change ), +@seen, 'only Change objects';
    is +@seen.grep( { .path eq $filename } ), +@seen, 'only about our file';

    # probably fragile, would have expected at least 1 FileChanged in here
    is +@seen.grep( { .event ~~ FileRenamed } ), +@seen, 'only renaming';
}