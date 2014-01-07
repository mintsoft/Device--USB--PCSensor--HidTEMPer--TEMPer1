#!/usr/bin/env perl
use feature 'say';
use Device::USB::PCSensor::HidTEMPer;
#use Data::dump qw(dump);

my $pcsensor = Device::USB::PCSensor::HidTEMPer->new();
#say "yo homie";
my @devices = $pcsensor->list_devices();

say "Found the following devices: ";
say "\t $_ "for(@devices);

foreach my $device ( @devices ){
	print "$device : ".$device->internal()->celsius()."C\n" if defined $device->internal();
	print "$device : ".$device->external()->celsius()."C\n" if defined $device->external();
}