use Test::Simple tests => 1;

use Device::USB::PCSensor::HidTEMPer;

my $pcsensor = Device::USB::PCSensor::HidTEMPer->new();

ok( defined($pcsensor), 'new()');