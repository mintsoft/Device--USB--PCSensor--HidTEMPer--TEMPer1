#!/usr/bin/env perl
use strict;
use warnings;

use Device::USB;
use Carp;

use Data::Dump qw(dump);
use feature 'say';

#Bus 004 Device 002: ID 0c45:7401 Microdia 
use constant VENDOR => 0x0c45;
use constant PRODUCT => 0x7401;
use constant TIMEOUT_IN_MS => 5000;

#hopefully this won't be needed, I should be able to use pack/unpack to convert to byte arrays then scalar for length instead
use constant REQ_INT_LEN => 8;
use constant REQ_BULK_LEN => 8;

my @uTemperature = ( 0x01, 0x80, 0x33, 0x01, 0x00, 0x00, 0x00, 0x00 );
my @uIni1 = ( 0x01, 0x82, 0x77, 0x01, 0x00, 0x00, 0x00, 0x00 );
my @uIni2 = ( 0x01, 0x86, 0xff, 0x01, 0x00, 0x00, 0x00, 0x00 );

our $usb;
our $dev;

sub control_transfer
{
	my (@controlQuestion)= @_;
	my $byte_string = array_to_byte_string(@controlQuestion, REQ_INT_LEN);
	my $r = $dev->control_msg(0x21, 0x09, 0x0200, 0x01, $byte_string, REQ_INT_LEN, TIMEOUT_IN_MS);
	croak ("a USB error occurred (\$r = $r) when communicating the following message" + dump(@controlQuestion)) if $r < 0;
	return split qr{}, $byte_string;
}

sub interrupt_read
{
	my $response = "\0" x REQ_INT_LEN;
	my $r = $dev->interrupt_read(0x82, $response, REQ_INT_LEN, TIMEOUT_IN_MS);
	croak "a catastrophic USB error occured (\$r = $r) when reading from 0x82".($r==-110?", a timeout occurred":"") if $r < 0;
	my @response_bytes = split qr//, $response;
	@response_bytes = map(ord, @response_bytes);
	return @response_bytes;
}

sub interrupt_read_temperature
{
	my @response = interrupt_read();
	my @temperatures = (
		parse_bytes_to_temps($response[2], $response[3]),
		parse_bytes_to_temps($response[4], $response[5])
	);
	return @temperatures;
}

sub interpret_signed_char
{
	my ($char) = @_;
	$char -= 256 if ($char >= 128);
	return $char;
}

sub parse_bytes_to_temps
{
	my ($byte1, $byte2) = @_;
	my $temperature = ($byte2 & 0xFF) + (interpret_signed_char($byte1) << 8);
	return (125.0/32000.0) * $temperature;
}

sub array_to_byte_string
{
	my (@array, $maxlength) = @_;
	my $bytestring	= join '', map{ chr $_ } @array;
	$bytestring	.= join '', map{ chr $_ } ( (0)x( $maxlength - $#array ) ) if($maxlength && $maxlength > $#array);
	return $bytestring;
}

$usb = Device::USB->new();
$usb->debug_mode(1);

#TODO: this may return multiple, check that all scalars are actually arrays later
$dev = $usb->find_device(VENDOR, PRODUCT);
croak "Device could not be found" unless $dev;
#printf "Found device: %04X:%04X\n", $dev->idVendor(), $dev->idProduct();

for(0..1) {
	$dev->detach_kernel_driver_np($_) if $dev->get_driver_np($_);	
}

my $r = $dev->set_configuration(0x01) ;
croak "ERROR: could not set configuration : $r" if $r < 0;


for(0..1) {
	my $r = $dev->claim_interface($_);
	croak "ERROR: could not claim interface $_ : $r" if $r < 0;
}

#ini_control_transfer
my $bytestring = "\x01\x01";
$r = $dev->control_msg(0x21, 0x09, 0x0201, 0x00, $bytestring, 2, TIMEOUT_IN_MS );
croak "Catastrophe writing the control message: \$r = $r". "  ".$usb->error_name($r) if $r < 0;
#end ini_control_transfer

#Initial Setup:
control_transfer(@uTemperature);
my $result = interrupt_read();

control_transfer(@uIni1);
$result = interrupt_read();

control_transfer(@uIni2);
$result = interrupt_read();
$result = interrupt_read();

#Read the actual temps:
control_transfer(@uTemperature);
my @temps = interrupt_read_temperature;

say "We have the following temps: " . dump(@temps);
$dev->release_interface($_) for (0..1);
