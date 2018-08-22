# --
# Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Legal::GPLValidator;
## nofilter(TidyAll::Plugin::OTRS::Common::CustomizationMarkers)
## nofilter(TidyAll::Plugin::OTRS::Legal::GPLValidator)

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Base);

sub transform_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # Replace this license line...
    #
    # Original:
    #     AFFERO General Public License (AGPL)
    #
    # Replacement:
    #     GNU GENERAL PUBLIC LICENSE (GPL)
    #
    $Code =~ s{AFFERO \s+ General \s+ Public \s+ License \s+ \(AGPL\)}{GNU GENERAL PUBLIC LICENSE (GPL)}xmsg;

    # Replace this license line...
    #
    # Original:
    #     GNU AFFERO GENERAL PUBLIC LICENSE
    #
    # Replacement:
    #     GNU GENERAL PUBLIC LICENSE
    #
    $Code =~ s{GNU \s+ AFFERO \s+ GENERAL \s+ PUBLIC \s+ LICENSE}{GNU GENERAL PUBLIC LICENSE}xmsg;

    # Replace this license line in .pm .pl .tt and .js files.
    #
    # Original:
    #     the enclosed file COPYING for license information (AGPL). If you
    #
    # Replacement:
    #     the enclosed file COPYING for license information (GPL). If you
    #
    $Code =~ s{
        ^ ( (?: \# \s+ | \/\/ \s+ |  ) ) the [ \s \w ]+ COPYING [ \s \w ]+ \(AGPL\) \. [ \s \w ]+ you
    }{$1the enclosed file COPYING for license information (GPL). If you}xmsg;

    # Replace this license line in .pm .pl .tt and .js files.
    #
    # Original:
    #     did not receive this file, see http://www.gnu.org/licenses/gpl-2.0.txt.
    #     did not receive this file, see https://www.gnu.org/licenses/gpl.txt.
    #     did not receive this file, see L<http://www.gnu.org/licenses/gpl-2.0.txt>.
    #     did not receive this file, see L<https://www.gnu.org/licenses/agpl.txt>.
    #
    # Replacement:
    #     did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
    #
    $Code =~ s{
        ^ ( (?: \# \s+ | \/\/ \s+ |  ) ) did [ \s \w ]+ \, \s+ see \s+ (?: L< |  ) http (?: s |  ) :\/\/www\.gnu\.org\/licenses\/ (?: a |  ) gpl (?: -2\.0 |  ) \.txt (?: > |  ) \.
    }{$1did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.}xmsg;

    # Replace this license line in .pm .pl .tt and .js files.
    #
    # Original:
    #     This software is part of the OTRS project (L<http://otrs.org/>).
    #     This software is part of the OTRS project (L<http://otrs.com/>).
    #     This software is part of the OTRS project (<http://otrs.com/>).
    #
    # Replacement:
    #     This software is part of the OTRS project (https://otrs.org/).
    #
    $Code =~ s{
        ^ ( (?: \# \s+ | \/\/ \s+ |  ) ) This \s+ software \s+ is \s+ part \s+ of \s+ the \s+ OTRS \s+ project \s+ \( (?: L< | < ) http (?: s |  ) :\/\/otrs\. (?: org | com ) \/>\) \.
    }{$1This software is part of the OTRS project (https://otrs.org/).}xmsg;

    # We are using "use warnings;" as indicator for a .pm or .pl file because we have no access to filetype here.
    if ( $Code =~ m{ ^ \s* use \s+ warnings; \s* $ }smx ) {

        # Replace this license line in .pm .pl .t (perldoc) files.
        #
        # Original:
        #     did not receive this file, see http://www.gnu.org/licenses/gpl-2.0.txt.
        #     did not receive this file, see https://www.gnu.org/licenses/gpl.txt.
        #     did not receive this file, see L<http://www.gnu.org/licenses/gpl-2.0.txt>.
        #     did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
        #     did not receive this file, see <https://www.gnu.org/licenses/agpl.txt>.
        #
        # Replacement:
        #     did not receive this file, see L<https://www.gnu.org/licenses/gpl-3.0.txt>.
        #
        $Code =~ s{
            ^ did [ \s \w ]+ \, \s+ see \s+ (?: L< | < |  ) http (?: s |  ) :\/\/www\.gnu\.org\/licenses\/ (?: a |  ) gpl (?: -2\.0 |  ) \.txt (?: > | > |  ) \.
        }{did not receive this file, see L<https://www.gnu.org/licenses/gpl-3.0.txt>.}xmsg;

        # Replace this license line in .pm .pl .t (perldoc) files.
        #
        # Original:
        #     This software is part of the OTRS project (https://otrs.org/).
        #     This software is part of the OTRS project (http://otrs.com/).
        #     This software is part of the OTRS project (<http://otrs.org/>).
        #
        # Replacement:
        #     This software is part of the OTRS project (L<https://otrs.org/>).
        #
        $Code =~ s{
            ^ This \s+ software \s+ is \s+ part \s+ of \s+ the \s+ OTRS \s+ project \s+ \( (?: < |  ) http (?: s |  ) :\/\/otrs\. (?: org | com ) \/ (?: > |  ) \) \.
        }{This software is part of the OTRS project (L<https://otrs.org/>).}xmsg;
    }

    # Define old and new FSF FSF Mailing Addresses.
    my $OldFSFAddress = '59 \s+ Temple \s+ Place, \s+ Suite \s+ 330, \s+ Boston, \s+ MA \s+ 02111-1307 \s+ USA';
    my $NewFSFAddress = '51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA';

    # Replace FSF Mailing Address.
    if ( $Code =~ s{$OldFSFAddress}{$NewFSFAddress}xms ) {
        print "NOTICE: _GPL3LicenseCheck() updated the FSF Mailing Address\n";
    }

    my $GPLPerlScript = _GPLPerlScript();

    # Replace the license header in .pl files.
    $Code =~ s{
        \# \s+ -- \n
        \# \s+ This \s+ program \s+ is \s+ free \s+ software; \s+ [ \s \w \, \. \; \# \/ \( \) ]+
        51 \s+ Franklin \s+ St, \s+ Fifth \s+ Floor, \s+ Boston, \s+ MA \s+ 02110-1301 \s+ USA .*?
        \# \s+ -- \n
    }{$GPLPerlScript}xmsg;

    if ( !$Self->IsFrameworkVersionLessThan( 7, 0 ) ) {

        # Remove duplicated license information in Perldoc. The license comment at the start of files is enough.
        $Code =~ s{\n ^=head1 \s+ TERMS \s+ AND \s+ CONDITIONS .*? ^=cut\n?}{}smx;
    }

    return $Code;
}

sub validate_file {    ## no critic
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );

    my $Code = $Self->_GetFileContents($Filename);

    my ($Filetype) = $Filename =~ m{ .* \. ( .+ ) }xmsi;

    # Check a javascript license header.
    if ( lc $Filetype eq 'js' ) {

        my $GPLJavaScript = _GPLJavaScript();

        die __PACKAGE__ . "\nFound no valid javascript license header!" if $Code !~ m{\Q$GPLJavaScript\E};
    }

    # Check a perl script license header.
    elsif ( lc $Filetype eq 'pl' || lc $Filetype eq 'psgi' ) {

        my $GPLPerlScript = _GPLPerlScript();

        die __PACKAGE__ . "\nFound no valid perl script license header!" if $Code !~ m{\Q$GPLPerlScript\E};
    }

    # Check css license header.
    elsif ( lc $Filetype eq 'css' || lc $Filetype eq 'scss' ) {

        my $GPLCss = _GPLCss();

        die __PACKAGE__ . "\nFound no valid css license header!" if $Code !~ m{\Q$GPLCss\E};
    }

    # Check vue license header.
    elsif ( lc $Filetype eq 'vue' ) {

        my $GPLVue = _GPLVue();

        die __PACKAGE__ . "\nFound no valid vue license header!" if $Code !~ m{\Q$GPLVue\E};
    }

    # Check generic license header.
    else {

        my $GPLGeneric = _GPLGeneric();

        die __PACKAGE__ . "\nFound no valid license header!" if $Code !~ m{\Q$GPLGeneric\E};
    }

    # Check perldoc license header.
    if ( lc $Filetype eq 'pl' || lc $Filetype eq 'pm' ) {

        if ( $Code =~ m{ =head1 \s+ TERMS \s+ AND \s+ CONDITIONS \n+ This \s+ software \s+ is \s+ part }smx ) {

            my $GPLPerldoc = _GPLPerldoc();

            die __PACKAGE__ . "\nFound no valid perldoc license header!" if $Code !~ m{\Q$GPLPerldoc\E};
        }
    }

    # Check if there is aother strange AGPL license content.
    if ( $Code =~ m{(^ [^\n]* (?: \(AGPL\) | /agpl | AFFERO ) [^\n]* $)}smx ) {
        die __PACKAGE__ . "\nThere is strange license wording!\nLine: $1";
    }
}

sub _GPLPerlScript {
    return <<'END_GPLPERLSCRIPT';
# --
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --
END_GPLPERLSCRIPT

}

sub _GPLJavaScript {
    return <<'END_GPLJAVASCRIPT';
// --
// This software comes with ABSOLUTELY NO WARRANTY. For details, see
// the enclosed file COPYING for license information (GPL). If you
// did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
// --
END_GPLJAVASCRIPT
}

sub _GPLCss {
    return <<'END_GPLMINIMAL';
This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (GPL). If you
did not receive this file, see: https://www.gnu.org/licenses/gpl-3.0.txt.
END_GPLMINIMAL
}

sub _GPLVue {
    return <<'END_GPLMINIMAL';
This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (GPL). If you
did not receive this file, see: https://www.gnu.org/licenses/gpl-3.0.txt.
END_GPLMINIMAL
}

sub _GPLGeneric {
    return <<'END_GPLGENERIC';
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --
END_GPLGENERIC
}

sub _GPLPerldoc {
    return <<'END_GPLPERLDOC';
=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (GPL). If you
did not receive this file, see L<https://www.gnu.org/licenses/gpl-3.0.txt>.
END_GPLPERLDOC
}

1;
