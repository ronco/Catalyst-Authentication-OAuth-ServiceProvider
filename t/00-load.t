#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Catalyst::Authentication::Credential::OAuth::ServiceProvider' ) || print "Bail out!
";
}

diag( "Testing Catalyst::Authentication::Credential::OAuth::ServiceProvider $Catalyst::Authentication::Credential::OAuth::ServiceProvider::VERSION, Perl $], $^X" );
