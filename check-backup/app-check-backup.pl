#!/usr/bin/env perl

# Title:         Plugin checks for Nagios backup!

# Description:   The plugin checks if the previous day's backup exists in the share 
# created on the backup server. If there is it notifies with an OK, if not it 
# notifies as a CRITICAL.

# Author:        Tácito Chaves 
# Contacts:      e-mail: tacito.ma@hotmail.com / skype: tacito.chaves
# Created in:    11/24/2014

use warnings;
use strict;

# adds the lib directory
use FindBin;
use lib "$FindBin::Bin/lib";

use POSIX qw(strftime);
# get date of yesterday
my $yesterday = strftime "%d_%m_%Y", localtime( time - 86400 );

# loads the module
use REMOTE::CheckBackup;
use REMOTE::Availability;

# instantiates and creates the object
my $self = REMOTE::CheckBackup->new;
my $c    = REMOTE::Availability->new;


# import data of the conection
my $fh     = $self->_read($ARGV[0]);

# takes the server ip network
my $host   = $self->_parse( $fh->{Destination} );

# checks if the host is accessible on the network
my $result = $c->check_host( $host );

if ( $result ne 100 ) {

    my $check_point = $self->check_assembly( $fh->{Directory} );

    if ( $check_point ne "is mounted" ) {
        $self->mount($fh);

        my $bkp = $self->get_bd( $fh->{Directory}, $yesterday );

        if ( defined $bkp and $bkp =~ m/$yesterday/ ) {
            print "OK - Backup Existe - $bkp\n";
            $self->ok($bkp);
        }
        else {
            print "CRITICAL - Backup não encontrado.\n";
            $self->critical;
        }

        $self->umount( $fh->{Directory} );
    }
}
else {
    print "Destination Host: $host Unreachable\n";
    $self->critical;
}
