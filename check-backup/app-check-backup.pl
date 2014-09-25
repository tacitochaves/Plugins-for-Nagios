#!/usr/bin/env perl

# Title:         Plugin checks for Nagios backup!

# Description:   The plugin checks if the previous day's backup exists in the share 
# created on the backup server. If there is it notifies with an OK, if not it 
# notifies as a CRITICAL.

# Author:        Tácito Chaves 
# Contacts:      e-mail: tacito.ma@hotmail.com / skype: tacito.chaves
# Created in:    09/20/2014

use warnings;
use strict;

use POSIX qw(strftime);

# get date of yesterday
my $yesterday = strftime "%d_%m_%Y", localtime( time - 86400 );

# adds the lib directory
use FindBin;
use lib "$FindBin::Bin/lib";

# loads the module
use REMOTE::Plugin;

# instantiates and creates the object
my $remote = REMOTE::Plugin->new;

# checks if the share already exists
my $df = $remote->verify_sharing("/mnt/banco");

# the backup directory     
my $dirname = "/mnt/banco/";

# check if the directory is mounted
my $umount;
if ( $df ne "is mounted" ) {

    $remote->mount;

    # opening the directory
    opendir( my $dir, $dirname ) or die "Error in opening dir $dirname\n";

    # saving the contents of a directory in the array
    my @list = readdir($dir); 
    close($dir);

    # creating a new variable with match on the current date
    my $match;
    foreach ( @list ) {
        if ( $_ =~ m/$yesterday/ ) {
            $match = $_;
        }
    }

    # shows the backup if it exists and your return code
    if (defined ($match)) {
        print "OK - Backup Existe - $match\n" if $yesterday;
        $remote->ok($match);
    }
    else {
        print "CRITICAL - Backup não encontrado.\n";
        $remote->critical($match);
    }
}

# disassemble sharing
$umount = $remote->umount;
