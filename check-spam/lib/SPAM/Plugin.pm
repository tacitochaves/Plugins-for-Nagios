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
sub open_queue {
    my ( $self, $mailq ) = @_;

    open my $out, "$mailq |" or die "[error] comand not found =>  $!\n";
    my @queue = <$out>;
    close $out;

    map { $self->{_spam}->{$1}++ if /\d{2}:\d{2}:\d{2}\s+?(\w+\@.*$)/ } @queue;

    return $self->{_spam};
}

sub return_code {
    my ( $self, $input ) = @_;

    return 2 if defined $input;

    return 0;
  
    $self;
}

1;
