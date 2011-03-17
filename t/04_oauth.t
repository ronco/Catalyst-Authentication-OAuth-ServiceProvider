use Test::More;

my $m;
BEGIN { use_ok( $m = "Catalyst::Authentication::OAuth::ServiceProvider::AccessToken" ) }

new_ok(
    $m => [
        token        => 'abcdef',
        token_secret => '123456',
        authinfo     => { username => 'ronco' }
    ]
);

use_ok( "Catalyst::Authentication::OAuth::ServiceProvider::Store::Minimal",
        'use minimal store' );

new_ok( "Catalyst::Authentication::OAuth::ServiceProvider::Store::Minimal");

done_testing();
