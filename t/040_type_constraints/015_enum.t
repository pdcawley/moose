#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use Scalar::Util ();

use Moose::Util::TypeConstraints;

enum Letter => 'a'..'z', 'A'..'Z';
enum Language => 'Perl 5', 'Perl 6', 'PASM', 'PIR'; # any others? ;)
enum Metacharacter => '*', '+', '?', '.', '|', '(', ')', '[', ']', '\\';

my @valid_letters = ('a'..'z', 'A'..'Z');

my @invalid_letters = qw/ab abc abcd/;
push @invalid_letters, qw/0 4 9 ~ @ $ %/;
push @invalid_letters, qw/l33t st3v4n 3num/;

my @valid_languages = ('Perl 5', 'Perl 6', 'PASM', 'PIR');
my @invalid_languages = ('perl 5', 'Python', 'Ruby', 'Perl 666', 'PASM++');
# note that "perl 5" is invalid because case now matters

my @valid_metacharacters = (qw/* + ? . | ( ) [ ] /, '\\');
my @invalid_metacharacters = qw/< > & % $ @ ! ~ `/;
push @invalid_metacharacters, qw/.* fish(sticks)? atreides/;
push @invalid_metacharacters, '^1?$|^(11+?)\1+$';

plan tests => @valid_letters        + @invalid_letters
            + @valid_languages      + @invalid_languages
            + @valid_metacharacters + @invalid_metacharacters;

Moose::Util::TypeConstraints->export_type_constraints_as_functions();

ok(Letter($_), "'$_' is a letter") for @valid_letters;
ok(!Letter($_), "'$_' is not a letter") for @invalid_letters;

ok(Language($_), "'$_' is a language") for @valid_languages;
ok(!Language($_), "'$_' is not a language") for @invalid_languages;

ok(Metacharacter($_), "'$_' is a metacharacter") for @valid_metacharacters;
ok(!Metacharacter($_), "'$_' is not a metacharacter")
    for @invalid_metacharacters;
