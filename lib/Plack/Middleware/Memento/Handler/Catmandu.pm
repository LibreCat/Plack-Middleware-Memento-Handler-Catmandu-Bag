package Plack::Middleware::Memento::Handler::Catmandu;

use Catmandu::Sane;
use Catmandu;
use Catmandu::Plugin::Versioning qw/get_history/;
use Moo;

our $VERSION = '0.01';

with 'Plack::Middleware::Memento::Handler';

has store => (is => 'ro', required => 1);
has bag => (is => 'ro', reuqired => 1);


sub get_memento {}

sub get_all_mementos {
  my ($self, $id) = @_;
  my $bag = Catmandu->store($self->store )->bag($self->bag)->version_bag;

  my $mementos = $bag->get_history($id);
  my @time_map = map {
      [$_->{_id},$_->{date_updated}]
    } @$mementos;
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
