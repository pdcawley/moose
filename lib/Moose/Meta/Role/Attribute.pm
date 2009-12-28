package Moose::Meta::Role::Attribute;

use strict;
use warnings;

use Carp 'confess';
use List::MoreUtils 'all';
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

sub is_same_as {
    my $self = shift;
    my $attr = shift;

    my $self_options = $self->original_options;
    my $other_options = $attr->original_options;

    return 0
        unless ( join q{|}, sort keys %{$self_options} ) eq ( join q{|}, sort keys %{$other_options} );

    for my $key ( keys %{$self_options} ) {
        return 0 if defined $self_options->{$key} && ! defined $other_options->{$key};
        return 0 if ! defined $self_options->{$key} && defined $other_options->{$key};

        next if all { ! defined } $self_options->{$key}, $other_options->{$key};

        return 0 unless $self_options->{$key} eq $other_options->{$key};
    }

    return 1;
}

1;
