package Catalyst::Authentication::Credential::OAuth::ServiceProvider;

use Moose;
use Net::OAuth;
use Catalyst::Exception ();
use Catalyst::Utils     ();

use Try::Tiny;

use Yada::Yada::Yada;

use namespace::autoclean;

our $VERSION = '0.01';

has oauth_store => ( is => 'ro', isa => 'HashRef', required => 1 );
has store => (
    is         => 'ro',
    does       => 'Catalyst::Authentication::OAuth::ServiceProvider::Store',
    lazy_build => 1
);

sub _build_store {
    my ($self) = @_;
    my $storeclass = $self->oauth_store->{class};
    ## follow catalyst class naming - a + prefix means a fully qualified class, otherwise it's
    ## taken to mean C::A::OAuth::ServiceProvider::Store::(specifiedclass)
    if ( $storeclass !~ /^\+(.*)$/ ) {
        $storeclass =
          "Catalyst::Authentication::OAuth::ServiceProvider::Store::${storeclass}";
    }
    else {
        $storeclass = $1;
    }

    try {
        Catalyst::Utils::ensure_class_loaded($storeclass);
    }
    catch {
        if ( $_ !~ /can't locate/ ) {    #'
            Catalyst::Exception->throw($_);
        }
        else {
            Catalyst::Exception->throw(
                "Unable to load OAuth Store class: " . $self->oauth_store->{class} );
        }
    };

    my $store = try {
        $storeclass->new( $self->oauth_store );
    }
    catch {
        Catalyst::Exception->throw("Error initializing OAuth store: $_");
    };
}

sub BUILDARGS {
    my ( $self, $config, $app, $realm ) = @_;
    return $config;
}

sub BUILD {
    my ($self) = @_;

    #ensure oauth store is loaded
    $self->store;
}

sub authenticate {
    my ( $self, $c, $realm, $authinfo ) = @_;

    my $token_string = $c->req->parameters->{oauth_token};
    my $consumer_key = $c->req->parameters->{oauth_consumer_key};
    my $sig          = $c->req->parameters->{oauth_signature};

    # fail fast if essential params missing
    if ( !( $token_string && $consumer_key && $sig ) ) {
        $c->log->debug("OAuth authentication failed due to missing params");
        return undef;
    }
    my $access_token = $self->store->find_access_token($token_string);

    if ( !ref($access_token) ) {
        $c->log->debug("OAuth authentication failed due to invalid access token");
        return undef;
    }

    my $consumer_secret = $self->store->find_consumer_secret($consumer_key);

    if ( !$consumer_secret ) {
        $c->log->debug("OAuth authentication failed due to invalid consumer_key");
        return undef;
    }

    my $access_request = $self->_access_request( $c, $access_token, $consumer_secret );

    $c->log->debug( "Verifying request using token: " . $token_string );
    my $valid = $access_request->verify;
    if ($valid) {
        $c->log->debug("OAuth authentication validated, finding user in realm");
        return $realm->find_user( $access_token->authinfo, $c );
    }
    else {
        $c->log->warn( "Invalid OAuth request token/signature: " . $token_string );
        if ( $c->log->is_debug ) {
            $access_request->sign;
            $c->log->debug("Calculated base string: " . $access_request->signature_base_string);
            $c->log->debug(
                "Calculated OAuth sig: " . $access_request->signature . " Given: $sig" );
        }
        return undef;
    }
}

# construct the Access Request OAuth object
sub _access_request {
    my ( $self, $c, $access_token, $consumer_secret ) = @_;
    my $uri = $c->req->uri->clone;
    $uri->query_form( {} );    # blank params
    $c->log->debug("Generating request for uri: $uri");
    return Net::OAuth->request('access token')->from_hash(
        $c->req->parameters,
        request_url     => $uri,
        request_method  => $c->req->method,
        token_secret    => $access_token->token_secret,
        consumer_secret => $consumer_secret
    );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Catalyst::Authentication::Credential::OAuth::ServiceProvider - The great new Catalyst::Authentication::Credential::OAuth::ServiceProvider!

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Catalyst::Authentication::Credential::OAuth::ServiceProvider;

    my $foo = Catalyst::Authentication::Credential::OAuth::ServiceProvider->new();
    ...

=head1 SUBROUTINES/METHODS

=head2 authenticate

=head1 AUTHOR

Ron White, C<< <ronco at costite.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-catalyst-authentication-oauth-serviceprovider at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Catalyst-Authentication-OAuth-ServiceProvider>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Catalyst::Authentication::Credential::OAuth::ServiceProvider


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Catalyst-Authentication-OAuth-ServiceProvider>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Catalyst-Authentication-OAuth-ServiceProvider>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Catalyst-Authentication-OAuth-ServiceProvider>

=item * Search CPAN

L<http://search.cpan.org/dist/Catalyst-Authentication-OAuth-ServiceProvider/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 Ron White.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


