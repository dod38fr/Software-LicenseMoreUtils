use strict;
use warnings;

use Test::More;
use Test::Exception;

my $class = 'Software::LicenseMoreUtils';
require_ok($class);

# test short_name retrieved by Software::LicenseUtils
my $gpl_lic = $class->new_license_with_summary({
    short_name => 'GPL-1',
    holder => 'X. Ample'
});
isa_ok($gpl_lic,'Software::LicenseMoreUtils::LicenseWithSummary',"license class");

like(
    $gpl_lic->summary,
    qr!can be found in '/usr/share/common-licenses/GPL-1'!,
    "GPL-1 summary"
);

my $gpl2_lic = $class->new_license_with_summary({
    short_name => 'GPL-2',
    holder => 'X. Ample'
});
isa_ok($gpl2_lic,'Software::LicenseMoreUtils::LicenseWithSummary',"license class");

like(
    $gpl2_lic->summary,
    qr!can be found in '/usr/share/common-licenses/GPL-2!,
    "GPL-2 summary"
);

#test missing summary
my $mit_lic = $class->new_license_with_summary({
    short_name => 'MIT',
    holder => 'X. Ample'
});

is($mit_lic->summary, '', "Empty summary for MIT license");

is($mit_lic->meta_name, 'mit', 'method forwarded to Software::License object');

my $gpl_p_lic = $class->new_license_with_summary({
    short_name => 'GPL-1+',
    holder => 'X. Ample'
});

like(
    $gpl_p_lic->summary,
    qr!any later version!,
    "GPL-1 or later summary"
);

done_testing;
