# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2021 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::Legal::ReplaceOTRSCopyright;
## nofilter(TidyAll::Plugin::OTRS::Perl::Time)

use strict;
use warnings;

use File::Basename;
use File::Copy qw(copy);
use parent qw(TidyAll::Plugin::Znuny::Base);

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # Don't replace copyright in thirdparty code.
    return $Code if $Self->IsThirdpartyModule();
# ---
# ZnunyCodePolicy
# ---
    # Only changed files will be updated.
    # This allows to run the code policy for unchanged files without updating
    # the copyright.
    my $FilePath = $Self->FilePath($Code);
    return $Code if !defined $FilePath;

    my $FileIsChanged = $Self->IsFileChanged($FilePath);
    return $Code if !$FileIsChanged;
# ---

    # Replace <URL>http://otrs.org/</URL> with <URL>https://otrs.com/</URL>
    $Code =~ s{ ^ ( \s* ) \< URL \> .+? \< \/ URL \> }{$1<URL>https://otrs.com/</URL>}xmsg;

    my $Copy = 'OTRS AG, https://otrs.com/';

    my ( $Sec, $Min, $Hour, $Day, $Month, $Year ) = localtime( time() );    ## no critic
    $Year += 1900;

    my $YearString = "2001-$Year";

    my $Output = '';

    LINE:
    for my $Line ( split( /\n/, $Code ) ) {

        # next line if Copyright string is not found
# ---
# ZnunyCodePolicy
# ---
#         if ( $Line !~ m{Copyright}smx ) {
        if ( $Line !~ m{Copyright.*?OTRS}smx ) {
# ---

            $Output .= $Line . "\n";
            next LINE;
        }

        # special settings for the language directory
        if ( $Line !~ m{OTRS}smx && $Code =~ m{ package \s+ Kernel::Language:: }smx ) {
            $Output .= $Line . "\n";
            next LINE;
        }

        # POD copyright statements.
        if ( $Line =~ m{ ^\# \s Copyright }smx ) {
            $Line = "# Copyright (C) $YearString $Copy";
        }

        # Check string in documentation.yml files
        elsif ( $Line =~ m{^Copyright: \s+ .* OTRS[ ]AG}smx ) {
            $Line = "Copyright: $YearString $Copy";
        }

        # Any other generic copyright statements, e.g :
        #   print "Copyright (c) 2003-2008 OTRS AG, http://www.otrs.com/\n";
        elsif (
            $Line
            =~ m{ ^ ( [^\n]* ) Copyright [ ]+ \( [Cc] \) .+? OTRS [ ]+ (?: AG | GmbH ), [ ]+ http (?: s |  ) :\/\/otrs\. (?: org | com ) \/? }smx
            )
        {
            $Line =~ s{
                    ^ ( [^\n]* ) Copyright [ ]+ \( [Cc] \) .+? OTRS [ ]+ (?: AG | GmbH ), [ ]+ http (?: s |  ) :\/\/otrs\. (?: org | com ) \/?
                }
                {$1Copyright (C) $YearString $Copy}smx;
        }

        $Output .= $Line . "\n";
    }

    return $Output;
}

1;
