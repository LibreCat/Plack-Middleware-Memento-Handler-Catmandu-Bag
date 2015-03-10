package Plack::Middleware::Memento::Handler::Catmandu;

use Catmandu::Sane;
use Catmandu;
use Catmandu::Util qw/is_instance/;
use DateTime::Format::ISO8601;
use DateTime::Format::Mail;
use Moo;

our $VERSION = '0.01';

with 'Plack::Middleware::Memento::Handler';

has store => (is => 'ro', required => 1);
has bag => (is => 'ro', required => 1);
has uri_pattern => (is => 'ro', required => 1);


sub _get_all_versions {
  my ($self, $id) = @_;
  my $store = $self->store;
  unless (is_instance($store)) {
    $store = Catmandu->store($store);
  }
  my $bag = $store->bag($self->bag);
  return $bag->get_history($id);
}

sub _calc_date_diff {
  my ($mem_date, $date_updated) = @_;

my $parser = DateTime::Format::ISO8601->new();
my $parser2 = DateTime::Format::Mail->new();
my $dt1 = $parser->parse_datetime($date_updated);
my $dt2 = $parser2->parse_datetime($mem_date);

$dt1->epoch() - $dt2->epoch();

}

sub get_memento {
  my ($self,$id, $memento_time) = @_;

  my $mementos = $self->_get_all_versions($id);

  my @diff = map {
    my $rec = $_;
    [$rec->{_id}, $rec->{date_updated}, _calc_date_diff($memento_time, $rec->{date_updated})];
  } @$mementos;

  my @closest = sort {$a->[2] <=> $b->[2]} @diff;
  #$closest[0]->[0,1];
  my $c = shift @closest;
  pop @$c;
  return $c;
}

sub get_all_mementos {
  my ($self, $id) = @_;

  my @time_map = map {
      [sprintf($self->uri_pattern, $_->{_id}), $_->{date_updated}]
    } @{$self->_get_all_versions($id)};

  return \@time_map;
}

1;
__END__

=encoding utf-8

=head1 NAME

Plack::Middleware::Memento::Handler::Catmandu - Blah blah blah

=head1 SYNOPSIS

  use Plack::Middleware::Memento::Handler::Catmandu;

=head1 DESCRIPTION

Plack::Middleware::Memento::Handler::Catmandu is

=head1 AUTHOR

Nicolas Steenlant E<lt>nicolas.steenlant@ugent.beE<gt>

=head1 COPYRIGHT

Copyright 2015- Nicolas Steenlant

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
