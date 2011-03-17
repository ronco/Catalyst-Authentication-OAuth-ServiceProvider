package AccessApp::Controller::Root;

use Moose;
BEGIN { extends 'Catalyst::Controller' }

__PACKAGE__->config( namespace => '' );

sub oauthed_ok : Local {
    my ( $self, $c ) = @_;

    my $authd = $c->authenticate();

    if ($authd) {
        $c->response->body( "authed " . $c->user->get('name') );
    }
    else {
        $c->response->body("not authed");
    }

    $c->logout;
}

1;
