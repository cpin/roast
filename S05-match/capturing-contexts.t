use v6;

use Test;

plan 18;

if !eval('("a" ~~ /a/)') {
  skip_rest "skipped tests - rules support appears to be missing";
  exit;
}

# old: L<S05/Return values from matches/"A match always returns a Match object" >
# L<S05/Match objects/"A match always returns a " >
{
  my $match = 'abd' ~~ m/ (a) (b) c || (\w) b d /;
  isa_ok( $match, 'Match', 'Match object returned');
  isa_ok( $/, 'Match', 'Match object assigned to $/');
  ok( $/ === $match, 'Same match objects');
}

# old: L<S05/Return values from matches/"The array elements of a C<Match> object are referred to" >
# L<S05/Accessing captured subpatterns/"The array elements of a " >
{
  'abd' ~~ m/ (a) (b) c || (\w) b d /;
  ok( $/[0] eq 'a', 'positional capture accessible');
  ok( @($/).[0] eq 'a', 'array context - correct number of positional captures');
  ok( @($/).elems == 1, 'array context - correct number of positional captures');
  ok( $/.list.elems == 1, 'the .list methods returns a list object');
}

# old: L<S05/Return values from matches/"When used as a hash, a C<Match> object" >
# L<S05/Match objects/"When used as a hash" >
{
  'abd' ~~ m/ <alpha> <alpha> c || <alpha> b d /;
  ok( $/<alpha> eq 'a', 'named capture accessible');
  ok( %($/).keys == 1, 'hash context - correct number of named captures');
  ok( %($/).<alpha> eq 'a', 'hash context - named capture accessible');
  ok( $/.hash.keys[0] eq 'alpha', 'the .hash method returns a hash object');
}

# RT 62530
#?rakudo skip 'augment'
{
  augment class Match { method keys () {return %(self).keys }; };
  rule a {H};
  "Hello" ~~ /<a>/;
  is $/.keys, 'a', 'get rule result';
  my $x = $/;
  is $x.keys, 'a', 'match copy should be same as match';
}

# RT #64946
{
    regex o { o };
    "foo" ~~ /f<o>+/;

    #?rakudo todo 'RT #64946'
    is ~$<o>, 'o o', 'match list stringifies like a normal list';
    isa_ok $<o>, List;
    # I don't know what difference 'isa' makes, but it does.
    # Note that calling .WHAT (as in the original ticket) does not have
    # the same effect.
    is ~$<o>, 'o o', 'match list stringifies like a normal list AFTER "isa"';
}

# RT #64948
{
    #?rakudo todo 'RT #64948'
    ok %( 'foo' ~~ /foo/ ).can( 'exists' ),
       'Match coerced to Hash has "exists" method';

    my %match_as_hash = %( 'foo' ~~ /foo/ );
    ok %match_as_hash.can( 'exists' ),
       'Match stored in Hash has "exists" method';
}

# vim: ft=perl6
