package Pixis::Web::View::Email;

use strict;
use base 'Catalyst::View::Email';

__PACKAGE__->config(
    stash_key => 'email'
);

=head1 NAME

Pixis::Web::View::Email - Email View for Pixis::Web

=head1 DESCRIPTION

View for sending email from Pixis::Web. 

=head1 AUTHOR

牧 大輔

=head1 SEE ALSO

L<Pixis::Web>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
