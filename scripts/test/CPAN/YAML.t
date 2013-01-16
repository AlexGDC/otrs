# --
# YAML.t - tests for the YAML parser
# Copyright (C) 2001-2012 OTRS AG, http://otrs.org/
# --
# $Id: YAML.t,v 1.16 2013-01-16 20:47:01 mg Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

use strict;
use warnings;
use vars (qw($Self));
use utf8;

use Kernel::System::YAML;

my @Tests = (
    {
        Name => 'Simple string',
        Data => 'Teststring <tag> äß@ø " \\" \' \'\'',
    },
    {
        Name => 'Complex data',
        Data => {
            Key => 'Teststring <tag> äß@ø " \\" \' \'\'',
            Value => [
                {
                    Subkey => 'Value',
                    Subkey2 => undef,
                },
                1234,
                0,
                undef,
                'Teststring <tag> äß@ø " \\" \' \'\'',
            ],
        },
    },
    {
        Name => 'Special YAML chars',
        Data => ' a " a " a \'\' a \'\' a',
    },
    {
        Name => 'UTF8 string',
        Data => 'kéy',
    },
    {
        Name => 'UTF8 string, loader',
        Data => 'kéy',
        YAMLString => '--- kéy' . "\n",
    },
    {
        Name => 'UTF8 string without UTF8-Flag',
        Data => 'k\x{e9}y',
    },
    {
        Name => 'UTF8 string without UTF8-Flag, loader',
        Data => 'k\x{e9}y',
        YAMLString => '--- k\x{e9}y' . "\n",
    },
    {
        Name => 'Very long string', # see https://bugzilla.redhat.com/show_bug.cgi?id=192400
        Data => ' äø<>"\'' x 40_000,
        SkipEngine => 'YAML',       # This test does not run with plain YAML, see the bug above
    },
);

ENGINE:
for my $Engine (qw(YAML::XS YAML)) {
    
    # locally override the internal engine of YAML::Any to force testing
    local @YAML::Any::_TEST_ORDER = ($Engine);
    
    TEST:
    for my $Test (@Tests) {
        next TEST if $Engine eq $Test->{SkipEngine};
        
        my $YAMLString = $Test->{YAMLString} || Kernel::System::YAML::Dump( $Test->{Data} );
        my $YAMLData   = Kernel::System::YAML::Load( $YAMLString );
    
        $Self->IsDeeply(
            $YAMLData,
            $Test->{Data},
            "Engine $Engine - $Test->{Name}",
        );
    }
}

1;