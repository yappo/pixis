# And event is
#    time bound: it has a start time and an end time
#    possibly a container: for example a session for a conference 
#       is contained within an event
#    possibly multi: tracked

package Pixis::Schema::Master::Event;
use strict;
use warnings;
use base qw(Pixis::Schema::Base::MySQL);

__PACKAGE__->load_components("PK::Auto", "InflateColumn::DateTime", "UTF8Columns", "Core");
__PACKAGE__->table("pixis_event");
__PACKAGE__->add_columns(
    "id" => {
        data_type => "VARCHAR",
        is_nullable => 0,
        size => 8,
    },
    "title" => {
        data_type => "TEXT",
        is_nullable => 0
    },
    "description" => {
        data_type => "TEXT",
        is_nullable => 0
    },
    "event_type" => {
        # This flag changes the behavior of the underlying event
        # For example, if it's an event that contains only one content
        # (whatever that may be), then it's different from a conference
        data_type => "VARCHAR",
        is_nullable => 0,
        size => 16
    },
    "category1" => {
        data_type => "INTEGER",
        size => 32,
        is_nullable => 0,
    },
    "category2" => {
        data_type => "CHAR",
        size => 4,
        is_nullable => 1,
    },
    start_on => { 
        data_type => "DATETIME",
        is_nullable => 0,
    },
    end_on => {
        data_type => "DATETIME",
        is_nullable => 0,
    },
    modified_on => {
        data_type => "TIMESTAMP",
        is_nullable => 0,
        default_value => \'NOW()',
    },
    created_on => {
        data_type => "DATETIME",
        is_nullable => 0,
    },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->utf8_columns("title", "description");

1;
