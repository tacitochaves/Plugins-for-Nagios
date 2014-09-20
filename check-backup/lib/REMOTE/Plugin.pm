package REMOTE::Plugin;

use strict;
use warnings;

sub new {
    my $class = shift;
    my $self = {
        _sharing  => shift,
        _ok       => shift,
        _critical => shift, 
    };

    bless $self, $class;
    
    return $self;
}

sub verify_sharing {
    my ( $self, $point_mounted ) = @_;

    open ( my $df, "df -h |" ) or die "Error! Comand error!\n";
    my @dir_mounted = (<$df>);
    close($df);

    $self->{_sharing} = $point_mounted if defined($point_mounted);

    foreach my $i ( @dir_mounted ) {
		return "is mounted" if $i =~ m/$self->{_sharing}/;
    }
}

sub mount {
    my $conf = {
        username   => "database",
        password   => "OA2xXFPPbGtFIbQwXS6W",
        destination => "192.165.254.7/bancos_mysqls_postgre",
        directory  => "/mnt/banco/",
    };

    open( my $mount, "mount -t cifs -o user=$conf->{username},password=$conf->{password} \/\/$conf->{destination} $conf->{directory} |") or
        die "Error! Host Unreachable\n";
    my @a = (<$mount>);
    close($mount);
}

sub umount {
    open my $umount, "umount -f \/\/192.165.254.7/bancos_mysqls_postgre |" or die "Umount Error $!\n";
    my @u = (<$umount>);
    close $umount;
    return "umounted";
}

sub ok {
    my ( $self, $input ) = @_;
    $self->{_ok} = 0 if defined($input);
    return $self->{_ok};
}

sub critical {
    my ( $self, $input ) = @_;
    $self->{_critical} = 2 if ! defined($input);
    return $self->{_critical};
}

1;
