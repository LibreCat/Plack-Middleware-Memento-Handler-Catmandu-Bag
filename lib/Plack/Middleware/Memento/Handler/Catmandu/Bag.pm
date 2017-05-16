package Plack::Middleware::Memento::Handler::Catmandu::Bag;

use Catmandu::Sane;

our $VERSION = '0.01';

use Catmandu;
use Catmandu::Util qw(is_instance);
use DateTime::Format::ISO8601;
use Plack::Request;
use Moo;
use namespace::clean;

with 'Plack::Middleware::Memento::Handler';

has store    => (is => 'ro');
has bag      => (is => 'ro'); # TODO type check
has _bag     => (is => 'lazy');
has _iso8601 => (is => 'lazy');

sub _build__bag {
    my ($self) = @_;
    Catmandu->store($self->store)->bag($self->bag);
}

sub _build__iso8601 {
    DateTime::Format::ISO8601->new;
}

sub get_all_mementos {
    my ($self, $uri_r, $req) = @_;

    my $bag = $self->_bag;
    my ($id) = $uri_r =~ m|[^/]+$| || return;
    my $versions = $self->_bag->get_history($id) || return;

    [ map {
        my $data = $_;
        my $dt = $self->_iso8601->parse_datetime($data->{$bag->datestamp_updated_key});
        my $id = $data->{$bag->id_key};
        my $version = $data->{$bag->version_key};
        my $uri_m = $req->base."/$id/$version";
        [$self->_uri_m($req, $data), $dt];
    } @$versions ];
}

1;
__END__

=encoding utf-8

=head1 NAME

Plack::Middleware::Memento::Handler::Catmandu::Bag - Catmandu::Bag handler for Plack::Middleware::Memento

=head1 SYNOPSIS

    builder {
      enable 'Memento', handler => 'Catmandu::Bag', store => 'mystore', bag => 'mybag';
      $app
    };

=head1 AUTHOR

Nicolas Steenlant E<lt>nicolas.steenlant@ugent.beE<gt>

=cut
