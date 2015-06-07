#!/usr/bin/env perl

use warnings;
use strict;

use Net::SNMP;

my @IP_array  = ('192.166.254.5','192.166.254.20','192.166.254.15');
my $community = 'u3fr0I9b5';
my $snmp;
my $uptime;
my $IP;

foreach my $IP ( @IP_array) {

    $snmp->{$IP} = new SNMP::Util(
        -device    => $IP,
        -community => $community,
        -timeout   => 5,
        -retry     => 0,
        -poll      => 'on',
        -delimiter => ' ',
    );
}
 
#Now get the uptime for each switch
foreach my $IP (@IP_array) {
    $uptime = $snmp->{$IP}->get( 'v', 'sysUpTime.0' );
    print "Uptime for $IP = $uptime\n";
}
