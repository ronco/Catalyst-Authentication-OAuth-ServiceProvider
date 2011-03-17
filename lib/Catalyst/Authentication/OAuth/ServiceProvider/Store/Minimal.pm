package Catalyst::Authentication::OAuth::ServiceProvider::Store::Minimal;

use Moose;
use namespace::autoclean;

use Catalyst::Authentication::OAuth::ServiceProvider::AccessToken;

has [qw/access_tokens consumers/] =>
  ( is => 'rw', isa => 'HashRef', lazy => 1, default => sub { {} } );

with 'Catalyst::Authentication::OAuth::ServiceProvider::Store';

sub find_access_token {
    my ( $self, $token_string ) = @_;

    if ( exists $self->access_tokens->{$token_string} ) {
        return Catalyst::Authentication::OAuth::ServiceProvider::AccessToken->new(
            token => $token_string,
            %{ $self->access_tokens->{$token_string} }
        );
    }
    else {
        return undef;
    }

}

sub find_consumer_secret {
    my ( $self, $consumer_key ) = @_;

    if ( exists $self->consumers->{$consumer_key} ) {
        return $self->consumers->{$consumer_key};
    }
    else {
        return undef;
    }

}
__PACKAGE__->meta->make_immutable;

1;
