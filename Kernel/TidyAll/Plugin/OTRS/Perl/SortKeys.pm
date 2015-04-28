# --
# Copyright (C) 2001-2015 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Perl::SortKeys;

use strict;
use warnings;

use File::Basename;

use base qw(TidyAll::Plugin::OTRS::Perl);

=head1 SYNOPSIS

This module inserts a sort statements to lines like

    for my $Module (sort keys %Modules) ...

because the keys randomness can be a source of problems
that is hard to debug.

=cut

sub transform_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 3, 2 );

    $Code =~ s{ ^ (\s* for \s+ my \s+ \$ \w+ \s+ \( \s*) keys \s+ }{$1sort keys }xmsg;
    $Code =~ s{ ^ (\s* for \s+ \( \s*) keys \s+ }{$1sort keys }xmsg;

    return $Code;
}

1;
