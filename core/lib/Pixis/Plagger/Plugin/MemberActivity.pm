
package Pixis::Plagger::Plugin::MemberActivity;
use strict;
use base qw( Plagger::Plugin );
use DBI;

sub register {
    my($self, $context) = @_;

    $context->register_hook(
        $self,
        'subscription.load' => $self->can('load'),
        'publish.feed'      => $self->can('publish_feed'),
    );
}

sub load {
    my($self, $context) = @_;

    my $dbh = DBI->connect(@{$self->conf->{connect_info} || $context->conf->{pixis}->{connect_info}});
    my $sth = $dbh->prepare("SELECT id, github_id FROM pixis_member ");

    my ($member_id, $github_id);
    $sth->execute();
    $sth->bind_columns(\($member_id, $github_id));

    my $feed_hash = {};
    $context->{pixis}->{feeds} = $feed_hash;
    my $add_feed = sub {
        my ($url, $member_id) = @_;
        $feed_hash->{$url} ||= [];

        push @{$feed_hash->{ $url }},{
            type => 'github',
            member_id => $member_id
        };
        my $feed = Plagger::Feed->new();
        $feed->url( $url);
        $context->subscription->add($feed);
    };
    while ($sth->fetchrow_arrayref) {
        if ($github_id) {
            $add_feed->("http://github.com/$github_id.atom");
        }
    }
}

sub publish_feed {
    my($self, $context, $args) = @_;

    my $conf = $self->conf;
    my $f = $args->{feed};
    my $feed_format = $conf->{format} || 'Atom';

    # add entry

    my $dbh = DBI->connect(@{$self->conf->{connect_info} || $context->{conf}->{pixis}->{connect_info}});
    my $sth = $dbh->prepare("REPLACE INTO pixis_activity_github (entry_id, link, title, content, activity_on, created_on) VALUES (?, ?, ?, ?, ?, NOW())");

    $dbh->begin_work();
    for my $e ($f->entries) {
        $sth->execute($e->id, $e->permalink, $e->title, $e->body, $e->date);
    }
    $dbh->commit();
}

1;