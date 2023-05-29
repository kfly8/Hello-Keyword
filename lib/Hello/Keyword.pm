package Hello::Keyword;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";

use Carp qw(croak);

use XSLoader;
XSLoader::load(__PACKAGE__, $VERSION);

sub import {
   my $class = shift;
   my $caller = caller;

   $class->import_into( $caller, @_ );
}

sub import_into {
   my $class = shift;
   my $caller = shift;

   my @syms = qw( Hello );

   my %syms = map { $_ => 1 } @syms;
   delete $syms{$_} and $^H{"Hello::Keyword/$_"}++ for @syms;

   croak "Unrecognised import symbols @{[ keys %syms ]}" if keys %syms;
}

1;
__END__

=encoding utf-8

=head1 NAME

Hello::Keyword - Hello World of keyword_plugin

=head1 SYNOPSIS

    use Hello::Keyword;

    Hello World {
        print "It's made with keyword plugin\n";
    };

    # is equivalent to:
    #{
    #    print sprintf("Hello, %s!\n", 'World');
    #    do {
    #        print "It's made with keyword plugin\n"
    #    };
    #}

=head1 DESCRIPTION

Hello::Keyword is ...

=head1 LICENSE

Copyright (C) kobaken.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

kobaken E<lt>kentafly88@gmail.comE<gt>

=cut

