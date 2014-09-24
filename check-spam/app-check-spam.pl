#!/usr/bin/env perl

# Title:         Plugin that checks if any account is involved in SPAM attacks!

# Description:   The plugin checks if any account is inserted in an attack SPAM. The plugin captures all
# the emails that are queued to send mail, if any to be repeated for at least 50 times, we understand that
# this is not normal behavior, and the plugin will alarm CRITICAL informing the account involved.

# Author:        Tácito Chaves
# Contacts:      e-mail: tacito.ma@hotmail.com / skype: tacito.chaves
# Created in:    09/23/2014

use strict;
use warnings;

use FindBin;

use lib "$FindBin::Bin/lib";

use SPAM::Plugin;

my $cnf = SPAM::Plugin->new;
$cnf->open_file("$FindBin::Bin/spam2.txt");

# inicializes the flag
my $flag;

for my $key ( keys %{ $cnf->spam } ) {

    # show spammed account
    print "CRITICAL SPAM - $key = " . $cnf->spam($key) . "\n" if $cnf->spam($key) >= 50 and ++$flag;
    
}

# show if no spam
print "OK - Sem SPAM \n" unless $flag;

# sendig the return code
$cnf->return_code($flag);
