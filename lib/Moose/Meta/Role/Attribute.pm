package Moose::Meta::Role::Attribute;

use strict;
use warnings;

use Carp 'confess';
use Scalar::Util 'blessed', 'weaken';

our $VERSION   = '0.93';
our $AUTHORITY = 'cpan:STEVAN';

use base 'Moose::Meta::Mixin::AttributeCore';

__PACKAGE__->meta->add_attribute(
    'metaclass' => (
        reader => 'metaclass',
    )
);

__PACKAGE__->meta->add_attribute(
    'associated_role' => (
        reader => 'associated_role',
    )
);

__PACKAGE__->meta->add_attribute(
    'is' => (
        reader => 'is',
    )
);

__PACKAGE__->meta->add_attribute(
    'original_options' => (
        reader => 'original_options',
    )
);

sub new {
    my ( $class, $name, %options ) = @_;

    (defined $name)
        || confess "You must provide a name for the attribute";

    return bless {
        name             => $name,
        original_options => \%options,
        %options,
    }, $class;
}

sub attach_to_role {
    my ( $self, $role ) = @_;

    ( blessed($role) && $role->isa('Moose::Meta::Role') )
        || confess
        "You must pass a Moose::Meta::Role instance (or a subclass)";

    weaken( $self->{'associated_role'} = $role );
}

sub attribute_for_class {
    my $self      = shift;
    my $metaclass = shift;

    return $metaclass->interpolate_class_and_new(
        $self->name => %{ $self->original_options } );
}

sub clone {
    my $self = shift;

    return ( ref $self )->new( $self->name, %{ $self->original_options } );
}

1;
