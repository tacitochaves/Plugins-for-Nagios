#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;

use lib "$FindBin::Bin/lib";

use SPAM::Plugin;

my $cnf = SPAM::Plugin->new;
$cnf->open_file("$FindBin::Bin/spam.txt");

for my $key ( keys %{ $cnf->spam } ) {
    print "$key => " . $cnf->spam($key) . "\n" if $cnf->spam($key) >= 50;
}
