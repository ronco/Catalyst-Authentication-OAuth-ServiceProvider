use strict;
use warnings;

use Test::More tests => 4;
use Net::OAuth;

use lib 't/lib';

use Catalyst::Test qw/AccessApp/;

cmp_ok( get("/oauthed_ok"), 'eq', 'not authed', "no credential failure check" );

my $request = Net::OAuth->request("access token")->new(
    consumer_key     => 'qwerty',
    consumer_secret  => '098765',
    token            => 'abcdef',
    token_secret     => '123456',
    request_url      => 'http://virtualhost.com/oauthed_ok',
    request_method   => 'GET',
    signature_method => 'HMAC-SHA1',
    timestamp        => time,
    nonce            => time . 'abcd',
);


my $response;
$response = request( $request->to_url );
# unsigned should fail:
cmp_ok( $response->content, 'eq', 'not authed', 'missing signature');

#signed should succeed
$request->sign;
$response = request( $request->to_url );
cmp_ok( $response->content, 'eq', 'authed Bob Smith', 'signed request');

#test extra params
$request = Net::OAuth->request("access token")->new(
    consumer_key     => 'qwerty',
    consumer_secret  => '098765',
    token            => 'fedcba',
    token_secret     => '654321',
    request_url      => 'http://virtualhost.com/oauthed_ok',
    request_method   => 'GET',
    signature_method => 'HMAC-SHA1',
    timestamp        => time,
    nonce            => time . 'abcd',
    extra_params => {foo=>'bar', bloo=>'blah'},
);

$request->sign;
$response = request( $request->to_url );
cmp_ok( $response->content, 'eq', 'authed John Smith', 'signed request, extra params');


done_testing();
