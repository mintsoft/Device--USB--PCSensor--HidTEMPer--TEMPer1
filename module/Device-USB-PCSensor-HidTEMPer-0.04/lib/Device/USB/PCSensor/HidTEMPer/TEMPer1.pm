package Device::USB::PCSensor::HidTEMPer::TEMPer1;

use strict;
use warnings;

use Device::USB::PCSensor::HidTEMPer::Device;
use Device::USB::PCSensor::HidTEMPer::TEMPer1::Internal;
our @ISA = 'Device::USB::PCSensor::HidTEMPer::Device';

use Carp;

=head1

Device::USB::PCSensor::HidTEMPer::TEMPer1 - The HidTEMPer1 thermometer

=head1 VERSION

Version 0.01

=cut

our $VERSION = 0.01;

=head1 SYNOPSIS

None

=head1 DESCRIPTION

This is the implementation of the HidTEMPer1 thermometer that has one 
internal sensor measuring the temperature.

=head2 CONSTANTS
Used for initialising the thermometer device into read mode
=cut
my @uTemperature = ( 0x01, 0x80, 0x33, 0x01, 0x00, 0x00, 0x00, 0x00 );
my @uIni1 = ( 0x01, 0x82, 0x77, 0x01, 0x00, 0x00, 0x00, 0x00 );
my @uIni2 = ( 0x01, 0x86, 0xff, 0x01, 0x00, 0x00, 0x00, 0x00 );

=head2 METHODS

=over 3

=item * init()

Initialize the device, connects the sensors and makes the object ready 
for use.

=cut

sub init
{
	my $self = shift;
	# Add sensor references to this instance
	$self->{sensor}->{internal} = Device::USB::PCSensor::HidTEMPer::TEMPer1::Internal->new( $self );
	# Set configuration

	#ini_control_transfer
	my $bytestring = "\x01\x01";
	my $r = $self->{device}->control_msg(0x21, 0x09, 0x0201, 0x00, $bytestring, 2, 5000 );
	croak "Catastrophe writing the control message: \$r = $r" if $r < 0;
	#end ini_control_transfer

	#Initial Setup:
	$self->control_transfer(@uTemperature);	
	$self->interrupt_read();
	
	$self->control_transfer(@uIni1);
	$self->interrupt_read();

	$self->control_transfer(@uIni2);
	$self->interrupt_read();
	$self->interrupt_read();

	# Rebless
	bless $self, 'Device::USB::PCSensor::HidTEMPer::TEMPer1';
}

sub DESTROY
{
    $_[0]->SUPER::DESTROY();
}

=back

=head1 INHERIT METHODS FROM

Device::USB::PCSensor::HidTEMPer::Device

=head1 DEPENDENCIES

This module internally includes and takes use of the following packages:

  use Device::USB::PCSensor::HidTEMPer::Device;
  use Device::USB::PCSensor::HidTEMPer::TEMPer1::Internal;

This module uses the strict and warning pragmas. 

=head1 BUGS

Please report any bugs or missing features using the CPAN RT tool.

=head1 FOR MORE INFORMATION

None

=head1 AUTHOR

Daniel Fahlgren

(Based on code by Magnus Sulland < msulland@cpan.org >)

=head1 ACKNOWLEDGEMENTS

Thanks to Jeremy G for the fix on initializing the device configuration.

=head1 COPYRIGHT & LICENSE

Copyright (c) 2010-2011 Magnus Sulland

This program is free software; you can redistribute it and/or modify it 
under the same terms as Perl itself.

=cut

=head1 specific methods to TEMPer1
=cut

sub control_transfer
{
	my $self = shift;
	my (@controlQuestion)= @_;
	my $byte_string = $self->array_to_byte_string(@controlQuestion, 8);
	my $r = $self->{device}->control_msg(0x21, 0x09, 0x0200, 0x01, $byte_string, 8, 5000);
	croak ("a USB error occurred (\$r = $r) when communicating the following message" + @controlQuestion) if $r < 0;
	return split qr{}, $byte_string;
}

sub interrupt_read
{
	my $self  = shift;
	my $response = "\0" x 8;
	my $r = $self->{device}->interrupt_read(0x82, $response, 8, 5000);
	croak "a catastrophic USB error occured (\$r = $r) when reading from 0x82".($r==-110?", a timeout occurred":"") if $r < 0;
	my @response_bytes = split qr//, $response;
	@response_bytes = map(ord, @response_bytes);
	return @response_bytes;
}

sub interpret_signed_char
{
	my $self = shift;
	my ($char) = @_;
	$char -= 256 if ($char >= 128);
	$char &= 0xFF;
	return $char;
}

sub parse_bytes_to_temps
{
	my $self = shift;
	my ($byte1, $byte2) = @_;
	my $temperature = ($byte2) + ($self->interpret_signed_char($byte1) << 8);
	$temperature = (125.0/32000.0) * $temperature;
	$temperature -= 255 if ($temperature > 140);
	return $temperature;
}

sub array_to_byte_string
{
	my $self = shift;
	my (@array, $maxlength) = @_;
	my $bytestring  = join '', map{ chr $_ } @array;
	$bytestring    .= join '', map{ chr $_ } ( (0)x( $maxlength - $#array ) ) if($maxlength && $maxlength > $#array);
	return $bytestring;
}

sub read_temperatures
{
	my $self = shift;
	$self->control_transfer(@uTemperature);
	my @response = $self->interrupt_read();
	return (
		$self->parse_bytes_to_temps($response[2], $response[3]),
		$self->parse_bytes_to_temps($response[4], $response[5])
	);
}

1;