#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 6;

{
    package My::Attribute::Trait;
    use Moose::Role;

    sub reversed_name {
        my $self = shift;
        scalar reverse $self->name;
    }
}

{
    package My::Class;
    use Moose;

    has foo => (
        traits => [
            'My::Attribute::Trait' => {
                alias => {
                    reversed_name => 'eman',
                },
            },
        ],
    );
}

{
    package My::Other::Class;
    use Moose;

    has foo => (
        traits => [
            'My::Attribute::Trait' => {
                alias => {
                    reversed_name => 'reversed',
                },
            },
        ],
    );
}

my $attr = My::Class->meta->get_attribute('foo');
is($attr->eman, 'oof', 'the aliased method is in the attribute');
ok(!$attr->can('reversed_name'), 'the method was not installed under its original name');
ok(!$attr->can('reversed'), "the method was not installed under the other class' alias");

my $other_attr = My::Other::Class->meta->get_attribute('foo');
is($other_attr->reversed, 'oof', 'the aliased method is in the attribute');
ok(!$other_attr->can('reversed_name'), 'the method was not installed under its original name');
ok(!$other_attr->can('enam'), "the method was not installed under the other class' alias");

