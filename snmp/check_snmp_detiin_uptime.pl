#!/usr/bin/env perl

use warnings;
use strict;

use Net::SNMP;
use Getopt::Long;
use Data::Dumper;

my $PROGNAME = "$0";

my %OPTION = (
    "host"           => undef,
    "snmp-community" => undef,
    "snmp-version"   => undef,
    "snmp-port"      => undef,
    "snmptimeout"    => undef,

    'help'     => undef,
);

my %ERRORS = ('OK' => 0, 'WARNING' => 1, 'CRITICAL' => 2, 'UNKNOWN' => 3);
my $OID_sysUpTime = '1.3.6.1.2.1.1.3.0';

sub print_help ();
sub print_usage ();

Getopt::Long::Configure('bundling');

GetOptions (
    "H|hostname|host=s"                 => \$OPTION{'host'},
    "C|community=s"                     => \$OPTION{'snmp-community'},
    "v|snmp|snmp-version=s"             => \$OPTION{'snmp-version'},
    "P|snmpport|snmp-port=i"            => \$OPTION{'snmp-port'},
    "snmp-timeout=i"                    => \$OPTION{'snmptimeout'},

    "h"         => \$OPTION{'help'},            "help"              => \$OPTION{'help'},
    "o=s"       => \$OPTION{'oid'},             "oid=s"             => \$OPTION{'oid'},
);

my $host      = $OPTION{'host'}           if defined $OPTION{'host'};
my $warning   = $OPTION{'warning'}        if defined $OPTION{'warning'};
my $critical  = $OPTION{'critical'}       if defined $OPTION{'critical'};
my $version   = $OPTION{'snmp-version'}   if defined $OPTION{'snmp-version'};
my $community = $OPTION{'snmp-community'} if defined $OPTION{'snmp-community'};
my $oid       = $OPTION{'oid'}            if defined $OPTION{'oid'};

if ( !$host or !$version or !$community or !$oid) {
    print "Você precisa definir todos os parâmetros obrigatórios\n";
    exit($ERRORS{UNKNOWN});
}

my ( $session, $error ) = Net::SNMP->session(
    -hostname  => $host,
    -community => $community,
    -timeout   => 10,
);

if ( ! defined $session ) {
    printf "ERROR: %s.\n", $error;
    exit( $ERRORS{WARNING} );
}

my $result = $session->get_request( -varbindlist => [$oid], );

if ( ! defined $result ) {
    printf "ERROR: %s.\n", $session->error();
    $session->close();
    exit( $ERRORS{WARNING} );
}

$result = $result->{$oid};

my $number   = $1 if ( $result =~ m/^(\d+\:?[0-9]?[0-9]?)/g );
my $tempo    = $1 if ( $result =~ m/(seconds|minutes?|hour|days?)/g );

my $status = 'OK';
if ( $tempo ne 'day' ) {
    $status = 'WARNING';
}

printf "$status - Uptime (in %s): %s" . "|" . "uptime=$number$tempo" . "\n", $tempo, $number;
exit( $ERRORS{$status} );

#print "$number $tempo $schedule\n";
sub print_usage () {
    print "Usage:";
    print "$PROGNAME\n";
    print "   -H (--hostname)   Hostname to query (required)\n";
    print "   -C (--community)  SNMP read community (defaults to public)\n";
    print "                     used with SNMP v1 and v2c\n";
    print "   -v (--snmp-version)  1 for SNMP v1 (default)\n";
    print "                        2 for SNMP v2c\n";
    print "                        3 for SNMP v3\n";
    print "   -P (--snmp-port)  SNMP port (default: 161)\n";
    print "   --snmp-timeout    SNMP Timeout\n";
    print "   -o (--oid)        \t OID to check\n";
    print "   -w (--warning)    \t Warning level \n";
    print "   -c (--critical) \t Critical level \n";
    print "   -h (--help)      \t usage help\n";
}

sub print_help () {
    print "###########################################################\n";
    print "#    Copyright (c) 2014-2015 Cibernix Tecnologia          #\n";
    print "#    Bugs to http://cibernix.com                          #\n";
    print "#    Author: Tácito Chaves                                #\n";
    print "###########################################################\n";
    print_usage();
    print "\n";
}
