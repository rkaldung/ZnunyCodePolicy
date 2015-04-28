# --
# Copyright (C) 2001-2015 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Migrations::OTRS5::HeaderlineFilename;

use strict;
use warnings;

use File::Basename;

use base qw(TidyAll::Plugin::OTRS::Base);

=head1 SYNOPSIS

OTRS used to have the filename in the second line of every file;
drop this with OTRS 5.

=cut

sub transform_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 5, 0 );

    # Catch Perl and JS coments
    my $CommentStart = "(?:\\#|//)";

    $Code =~ s{
        (
            \A
            (?: $CommentStart![^\n]+\n )? # shebang line
            $CommentStart[ ]--\n          # separator
        )
            $CommentStart[^\n]+\n         # Old documentation header line to be removed
        (
            $CommentStart[^\n]+\n         # copyright
            $CommentStart[ ]--\n          # separator
        )
    }
    {$1$2}smx;

    return $Code;
}

1;
