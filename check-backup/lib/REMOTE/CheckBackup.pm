package REMOTE::CheckBackup;

use strict;
use warnings;

sub new {
    return bless {}, shift;
}

# method to read and delivers remote access settings to the backup server
sub _read {
    my ( $self, $file ) = @_;

    $self->{_file} = $file if defined $file;
    open my $fh, '<', "$self->{_file}" or die "[error] file not found!\n";
    my @list = <$fh>;
    close $fh;

    for (@list) {

        chomp;
        my $line = $_;

        next if $line =~ m/^#/g;

        my ( $key, $val ) = split( /:/, $line );

        $self->{_config}->{$key} = $val;
    }

    return $self->{_config};
}

# just get the IP of the backup server on the local network
sub _parse {
    my ( $self, $dst ) = @_;

    $self->{_Destination} = $dst if defined $dst;

    $self->{_Destination} = $1 if $self->{_Destination} =~ m/^((\d{1,3}\.){3}\d+)/;

    return $self->{_Destination} if defined $dst;;
}

# checks if the share is already mounted on the server
sub check_assembly {
    my ( $self, $dir ) = @_;

    $self->{_assembly} = $dir if defined $dir;

    open my $df, "df -h |" or die "Error while checking the mounted directories!\n";
    my @list = <$df>;
    close $df;

    for my $l ( @list ) {
        return "is mounted" if $l =~ m/$self->{_assembly}/gi;
    }

}

# riding the remote server backup directory
sub mount {
    my ( $self, $config ) = @_;

    $self->{_username}    = $config->{Username} if defined $config->{Username};
    $self->{_password}    = $config->{Password} if defined $config->{Password};
    $self->{_destination} = $config->{Destination} if defined $config->{Destination};
    $self->{_directory}   = $config->{Directory} if defined $config->{Directory};
    
    open my $mount, "mount -t cifs -o user=$self->{_username},password=$self->{_password} \/\/$self->{_destination} $self->{_directory} |" or die "Error! Host Unreachable\n";
    my @a = (<$mount>);
    close($mount);
}

# disassembles sharing
sub umount {
    my ( $self, $dir ) = @_;

    $self->{_directory} = $dir if defined $dir;
   
    open my $umount, "umount $self->{_directory} |" or die "[error] Directory not mounted\n";
    my @l = <$umount>;
    close $umount;
 
    return "umounted";
}

# getting backup
sub get_bd {
    my ( $self, $dir, $date ) = @_;

    $self->{_directory} = $dir if defined $dir;
    $self->{_date}      = $date if defined $date;

    opendir my $dirname, "$self->{_directory}" or die "Directory: $self->{_directory} not found\n";
    my @list = readdir($dirname);
    close $dirname;

    map { return $_ if m/$self->{_date}/g } @list;
}

# return ok if exists the backup file
sub ok {
    my ( $self, $input ) = @_;
    $self->{_ok} = 0 if defined($input);
    return $self->{_ok};
}

# return critical if not exists the backup file
sub critical {
    my $self = shift;
    $self->{_critical} = 2;
    return $self->{_critical};
}

1;
