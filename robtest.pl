#!/usr/bin/env perl
use feature 'say';

BEGIN {
        #$ENV{'LIBUSB_LIBDIR'} = "/lib/i386-linux-gnu";
        #$ENV{'LIBUSB_INCDIR'} = "/usr/include/libusb-1.0";
        $ENV{'CFLAGS'}="";
        $ENV{'CPPFLAGS'}="";
        $ENV{'LDFLAGS'}="";
}

use Device::USB::PCSensor::HidTEMPer;

my $pcsensor = Device::USB::PCSensor::HidTEMPer->new();
my @devices = $pcsensor->list_devices();

say "Found the following devices: ";
say "\t $_ "for(@devices);

foreach my $device ( @devices ){
	print "$device : ".$device->internal()->celsius()."C\n" if defined $device->internal();
	print "$device : ".$device->external()->celsius()."C\n" if defined $device->external();
}
