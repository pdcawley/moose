package Moose::Meta::Role::Application::ToInstance;

use strict;
use warnings;
use metaclass;

use Scalar::Util 'blessed';

our $VERSION   = '0.93_03';
$VERSION = eval $VERSION;
our $AUTHORITY = 'cpan:STEVAN';

use base 'Moose::Meta::Role::Application::ToClass';

__PACKAGE__->meta->add_attribute('rebless_params' => (
    reader  => 'rebless_params',
    default => sub { {} }
));

my %ANON_CLASSES;

sub apply {
    my ($self, $role, $object) = @_;

    my $anon_role_key = (blessed($object) . $role->name);

    my $class;
    if (exists $ANON_CLASSES{$anon_role_key} && defined $ANON_CLASSES{$anon_role_key}) {
        $class = $ANON_CLASSES{$anon_role_key};
    }
    else {
        my $obj_meta = Class::MOP::class_of($object) || 'Moose::Meta::Class';

        # This is a special case to handle the case where the object's
        # metaclass is a Class::MOP::Class, but _not_ a Moose::Meta::Class
        # (for example, when applying a role to a Moose::Meta::Attribute
        # object).
        $obj_meta = 'Moose::Meta::Class'
            unless $obj_meta->isa('Moose::Meta::Class');

        $class = $obj_meta->create_anon_class(
            superclasses => [ blessed($object) ]
        );
        $ANON_CLASSES{$anon_role_key} = $class;
        $self->SUPER::apply($role, $class);
    }

    $class->rebless_instance($object, %{$self->rebless_params});
}

1;

__END__

=pod

=head1 NAME

Moose::Meta::Role::Application::ToInstance - Compose a role into an instance

=head1 DESCRIPTION

=head2 METHODS

=over 4

=item B<new>

=item B<meta>

=item B<apply>

=item B<rebless_params>

=back

=head1 BUGS

See L<Moose/BUGS> for details on reporting bugs.

=head1 AUTHOR

Stevan Little E<lt>stevan@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2006-2010 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

