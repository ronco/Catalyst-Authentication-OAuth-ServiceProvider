package Catalyst::Authentication::OAuth::ServiceProvider::AccessToken;

use Moose;

has authinfo => ( is => 'rw', isa => 'HashRef' );
has [qw/token token_secret/] => ( is => 'rw', isa => 'Str' );

__PACKAGE__->meta->make_immutable;

1;

__END__
