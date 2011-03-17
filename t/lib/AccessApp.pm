package AccessApp;

use Moose;
use namespace::autoclean;

use Catalyst qw/Authentication/;
extends qw/Catalyst/;

__PACKAGE__->config->{'Plugin::Authentication'} = {
    realms => {
        default => {
            store => {
                class => 'Minimal',
                users => {
                    bob  => { name => "Bob Smith" },
                    john => { name => "John Smith" }
                }
            },
            credential => {
                class       => 'OAuth::ServiceProvider',
                oauth_store => {
                    class         => 'Minimal',
                    access_tokens => {
                        'abcdef' =>
                          { token_secret => '123456', authinfo => { username => 'bob' } },
                        'fedcba' => {
                            token_secret => '654321',
                            authinfo     => { username => 'john' }
                        },
                    },
                    consumers => {
                        'qwerty' => '098765'
                    }
                },
            }
        }
    }
};

__PACKAGE__->setup();

1;
