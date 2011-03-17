use strict;
use warnings;

# Testing compatability with SmartURI if present

use Test::More;
use Try::Tiny;

use lib 't/lib';

my $smart_installed = try { require Catalyst::Plugin::SmartURI; 1 };

my @checks = qw/relative hostless host-header/;

if ($smart_installed) {
    plan tests => scalar(@checks);
}
else {
    plan skip_all => 'Catalyst::Plugin::SmartURI not installed';
}

require Catalyst::Test;
import Catalyst::Test qw/AccessAppSmart/;

foreach my $check (@checks) {

    my $request = Net::OAuth->request("access token")->new(
        consumer_key     => 'qwerty',
        consumer_secret  => '098765',
        token            => 'abcdef',
        token_secret     => '123456',
        request_url      => 'http://virtualhost.com/oauthed_ok/' . $check,
        request_method   => 'GET',
        signature_method => 'HMAC-SHA1',
        timestamp        => time,
        nonce            => time . 'abcd',
    );

    my $response;
    $response = request( $request->to_url );

    #signed should succeed
    $request->sign;
    $response = request( $request->to_url );
    cmp_ok( $response->content, 'eq', 'authed Bob Smith', 'signed request' );

}

done_testing();
