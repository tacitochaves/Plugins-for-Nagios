package SPAM::Plugin;
use strict;
use warnings;

sub new {
    return bless {}, shift;
}

# acessors
sub spam {
    my ( $self, $key, $value ) = @_;
    $self->{_spam}->{$key} = $value if $key && $value;
    return $self->{_spam}->{$key} if $key && !$value;
    return $self->{_spam};
}

# methods
sub open_file {
    my ( $self, $name ) = @_;

    open my $fh, '<', $name or die "[error] file not found => $!\n";
    my @queue = <$fh>;
    close $fh;

    map { $self->{_spam}->{$1}++ if /\d{2}:\d{2}:\d{2}\s+?(\w+\@.*$)/ } @queue;

    return $self->{_spam};
}

1;
