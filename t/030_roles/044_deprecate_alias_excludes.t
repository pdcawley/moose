#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
BEGIN {
    eval "use Test::Output;";
    plan skip_all => "Test::Output is required for this test" if $@;
    plan tests => 22;
}

{
    package MyRole;
    use Moose::Role;
    sub foo { }
}

{
    package Foo;
    use Moose;
    ::stderr_is { with 'MyRole' } '', "no warning when no params given";
}

{
    package Foo2;
    use Moose;
    ::stderr_is {
        with 'MyRole' => {
            -alias => { foo => 'bar' },
            -excludes => 'foo',
        }
    } '', "no warning when -alias and -excludes are used";
    ::can_ok('Foo2', 'bar');
    ::ok(!Foo2->can('foo'), "foo was properly excluded");
}

{
    package Foo3;
    use Moose;
    ::stderr_like {
        with 'MyRole' => {
            alias => { foo => 'bar' },
        }
    } qr/The alias option for role application has been deprecated\. Use -alias instead\./, "warning for alias";
    ::can_ok('Foo3', 'foo');
    ::can_ok('Foo3', 'bar');
}

{
    package Foo4;
    use Moose;
    ::stderr_like {
        with 'MyRole' => {
            excludes => 'foo',
        }
    } qr/The excludes option for role application has been deprecated\. Use -excludes instead\./, "warning for excludes";
    ::ok(!Foo4->can('foo'), "foo was properly excluded");
}

{
    package Foo::Role;
    use Moose::Role;
    ::stderr_is { with 'MyRole' } '', "no warning when no params given";
}

{
    package Foo2::Role;
    use Moose::Role;
    ::stderr_is {
        with 'MyRole' => {
            -alias => { foo => 'bar' },
            -excludes => 'foo',
        }
    } '', "no warning when -alias and -excludes are used";
}

{
    package Foo3::Role;
    use Moose::Role;
    ::stderr_like {
        with 'MyRole' => {
            alias => { foo => 'bar' },
        }
    } qr/The alias option for role application has been deprecated\. Use -alias instead\./, "warning for alias";
}

{
    package Foo4::Role;
    use Moose::Role;
    ::stderr_like {
        with 'MyRole' => {
            excludes => 'foo',
        }
    } qr/The excludes option for role application has been deprecated\. Use -excludes instead\./, "warning for excludes";
}

{
    package Foo::Role::Test;
    use Moose;
    ::stderr_is { with 'Foo::Role' } '', "no warnings when consuming role";
}

{
    package Foo2::Role::Test;
    use Moose;
    ::stderr_is { with 'Foo2::Role' } '', "no warnings when consuming role";
    ::can_ok('Foo2::Role::Test', 'bar');
    ::ok(!Foo2::Role::Test->can('foo'), "foo was properly excluded");
}

{
    package Foo3::Role::Test;
    use Moose;
    with 'Foo3::Role';
    ::stderr_is { with 'Foo3::Role' } '', "no warnings when consuming role";
    ::can_ok('Foo3::Role::Test', 'foo');
    ::can_ok('Foo3::Role::Test', 'bar');
}

{
    package Foo4::Role::Test;
    use Moose;
    with 'Foo4::Role';
    ::stderr_is { with 'Foo4::Role' } '', "no warnings when consuming role";
    ::ok(!Foo4::Role::Test->can('foo'), "foo was properly excluded");
}
