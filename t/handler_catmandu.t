use strict;
use Test::More;
use Catmandu::Store::Hash;
use YAML;

use_ok 'Plack::Middleware::Memento::Handler::Catmandu';
require_ok 'Plack::Middleware::Memento::Handler::Catmandu';

my $store = Catmandu::Store::Hash->new(bags => {test => {plugins => ['Datestamps', 'Versioning']}});

my $bag = $store->bag('test');

my $obj = Plack::Middleware::Memento::Handler::Catmandu->new(store => $store, bag => 'test', uri_pattern => 'http://example.com/%s');

$bag->add({_id => 1, name => 'Larry'});
sleep 1;
$bag->add({_id => 1, name => 'Albert'});
sleep 1;
$bag->add({_id => 1, name => 'Santa Claus'});

#print Dump $store->bag('test_version')->get('1.1');

#print Dump ($obj->get_all_mementos(001));
print Dump $obj->get_memento(1,"Tue, 10 Mar 2015 14:05:00 GMT");
done_testing;
