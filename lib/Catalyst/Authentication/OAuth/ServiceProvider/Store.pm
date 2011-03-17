package Catalyst::Authentication::OAuth::ServiceProvider::Store;

use Moose::Role;

requires qw/find_access_token find_consumer_secret/;

1;
