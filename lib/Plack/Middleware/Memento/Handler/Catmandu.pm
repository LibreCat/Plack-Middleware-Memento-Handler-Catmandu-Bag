package Plack::Middleware::Memento::Handler::Catmandu;

use Catmandu::Sane;
use Catmandu;
use Catmandu::Util qw(is_instance);
use DateTime::Format::ISO8601;
use DateTime::Format::Mail;
use Moo;

our $VERSION = '0.01';

with 'Plack::Middleware::Memento::Handler';

has store => (is => 'ro', required => 1);
has bag => (is => 'ro', required => 1);
has uri_pattern => (is => 'ro', required => 1);

has iso8601 => (is => 'lazy');
has rfc2822 => (is => 'lazy');

sub _build_iso8601 {
    DateTime::Format::ISO8601->new;
}

sub _build_rfc2822 {
    DateTime::Format::Mail->new;
}

sub _get_all_versions {
    my ($self, $id) = @_;
    my $store = $self->store;
    unless (is_instance($store)) {
    $store = Catmandu->store($store);
    }
    my $bag = $store->bag($self->bag);
    $bag->get_history($id);
}

sub _calc_date_diff {
    my ($self, $mem_date, $date_updated) = @_;

    my $dt1 = $self->iso8601->parse_datetime($date_updated);
    my $dt2 = $self->rfc2822->parse_datetime($mem_date);

    abs($dt1->epoch - $dt2->epoch);
}

sub get_memento {
  my ($self,$id, $memento_time) = @_;

  my $mementos = $self->_get_all_versions($id);

  my @diff = map {
    my $rec = $_;
    [sprintf($self->uri_pattern, "$rec->{_id}_$rec->{_version}"), $self->_calc_date_diff($memento_time, $rec->{date_updated})];
  } @$mementos;

  my @closest = sort {$a->[1] <=> $b->[1]} @diff;
  $closest[0]->[0];
}

sub get_all_mementos {
  my ($self, $id) = @_;

  [ map {
      my $dt = $self->iso8601->parse_datetime($_->{date_updated});
      my $date = $self->rfc2822->format_datetime($dt);
      [sprintf($self->uri_pattern, "$_->{_id}_$_->{_version}"), $date]
    } @{$self->_get_all_versions($id)} ];
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
