#!/usr/bin/env perl
use feature 'say';
use Device::USB::PCSensor::HidTEMPer;
#use Data::dump qw(dump);

my $pcsensor = Device::USB::PCSensor::HidTEMPer->new();
#say "yo homie";
my @devices = $pcsensor->list_devices();

say "Found the following devices: ";
say "$_ "for(@devices);

foreach my $device ( @devices ){
	print $device->internal()->celsius() if defined $device->internal();
	print $device->external()->celsius() if defined $device->external();
}