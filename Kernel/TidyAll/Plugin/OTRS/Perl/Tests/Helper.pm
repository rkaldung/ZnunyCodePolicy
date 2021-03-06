# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Perl::Tests::Helper;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Perl);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 6, 0 );

    my %MatchRegexes = (
        HelperObjectParams               => qr{->ObjectParamAdd\(\s*'Kernel::System::UnitTest::Helper'}xms,
        HelperObjectFlagRestoreDatabase  => qr{RestoreDatabase\s*=>\s*1}xms,
        HelperObjectFlagPGPEnvironment   => qr{ProvideTestPGPEnvironment\s*=>\s*1}xms,
        HelperObjectFlagSMIMEEnvironment => qr{ProvideTestSMIMEEnvironment\s*=>\s*1}xms,
        HelperInstantiation              => qr{->Get\('Kernel::System::UnitTest::Helper'}xms,
        SeleniumInstantiation            => qr{->Get\('Kernel::System::UnitTest::Selenium'}xms,
        PGPInstantiation                 => qr{->Get\('Kernel::System::Crypt::PGP'}xms,
        SMIMEInstantiation               => qr{->Get\('Kernel::System::Crypt::SMIME'}xms,
    );

    my %MatchPositions;

    for my $Key ( sort keys %MatchRegexes ) {
        if ( $Code =~ $MatchRegexes{$Key} ) {

            # Store the position of the first match.
            $MatchPositions{$Key} = $-[0];
        }
    }

    return if !$MatchPositions{HelperInstantiation};

    if ( $MatchPositions{SeleniumInstantiation} && $MatchPositions{HelperObjectParams} ) {
        if ( $MatchPositions{SeleniumInstantiation} < $MatchPositions{HelperObjectParams} ) {
            return $Self->DieWithError(<<"EOF");
Please always set the Helper object params before creating the Selenium object to make sure any constructor flags are properly set and processed. This needs to be done because Selenium::new() already may create the Helper.
EOF
        }
    }

    if ( $MatchPositions{SeleniumInstantiation} && $MatchPositions{HelperObjectFlagRestoreDatabase} ) {
        return $Self->DieWithError(<<"EOF");
Don't use the Helper flag 'RestoreDatabase' in  Selenium tests, as the web server cannot access the test transaction.
EOF
    }

    return if $Self->IsFrameworkVersionLessThan( 8, 0 );

    if ( $MatchPositions{PGPInstantiation} && !$MatchPositions{HelperObjectFlagPGPEnvironment} ) {
        return $Self->DieWithError(<<"EOF");
PGP tests should always use the 'ProvideTestPGPEnvironment' flag of the unit test Helper.
EOF
    }

    if ( $MatchPositions{SMIMEInstantiation} && !$MatchPositions{HelperObjectFlagSMIMEEnvironment} ) {
        return $Self->DieWithError(<<"EOF");
SMIME tests should always use the 'ProvideTestSMIMEEnvironment' flag of the unit test Helper.
EOF
    }

    return;
}

1;
