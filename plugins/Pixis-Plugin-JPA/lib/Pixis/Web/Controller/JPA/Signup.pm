# $Id$

package Pixis::Web::Controller::JPA::Signup;
use strict;
use base qw(Catalyst::Controller::HTML::FormFu);

# Signup overview
#   1 - you're already a pixis user. good.
#   2 - verify addresses and such. these are not required for pixis
#       itself, but is required for JPA
#   3 - do a pre-registration. Insert into database, but
#       the payment status is "unpaid"
#
#   Path 1: paypal (or some other online, synchronous payment)
#   4A  - upon verfication form paypal, set the status.
#         you're done. (XXX - admin may want notification)
#
#   Path 2: bank transfer, convenience stores, etc.
#   4B - verify payment by hand (how unfortunate).
#        We need an admin view for this

1;