#!/bin/env perl

use strict;
use warnings;

use Data::Dumper;

my $info = {};

my $daemon= {
    zmprov => "/opt/zimbra/bin/zmprov",
    zmmailbox => "/opt/zimbra/bin/zmmailbox",
};

#open my $contas, "$daemon->{zmprov} -l gaa saude.ma.gov.br |" or die "Erro ao carregar as contas!\n";
my @contas = qw(tacito@saude.ma.gov.br suporte@saude.ma.gov.br);

for my $mail ( @contas ) {
    chomp $mail;

    # tamanho de contas
    for ( pegaTamanhoContas($mail) ) {
        s/\s+//g;
        $info->{$mail}->{tamanho} = $_;
    }

}

open my $fh, '>', "contas.csv" or die "Could not open file 'contas.csv' $!";

for my $key ( keys %{$info} ) {
    print $fh "'$key'" . "," . "'$info->{$key}->{tamanho}'\n";
}

# pega o tamanho de todas as contas
sub pegaTamanhoContas {
    my $self = shift;

    open my $fh, "$daemon->{zmmailbox} -z -m $self gms |" or die "Não foi possível carregar informações\n";
    my @tudo = <$fh>;
    close $fh;

    return @tudo;
}
