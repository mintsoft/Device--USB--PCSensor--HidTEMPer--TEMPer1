package Device::USB::PCSensor::HidTEMPer::TEMPer1::Internal;

use strict;
use warnings;

use Device::USB::PCSensor::HidTEMPer::Sensor;
our @ISA = 'Device::USB::PCSensor::HidTEMPer::Sensor';

use Carp;

=head1

Device::USB::PCSensor::HidTEMPer::TEMPer1::Internal - The HidTEMPer1 internal sensor

=head1 VERSION

Version 0.01

=cut

our $VERSION = 0.01;

=head1 SYNOPSIS

None

=head1 DESCRIPTION

This is the implementation of the HidTEMPer1 internal sensor.

=head2 CONSTANTS

=over 3

=item * MAX_TEMPERATURE

The highest temperature(120 degrees celsius) this sensor can detect.

=cut

use constant MAX_TEMPERATURE    => 120;

=item * MIN_TEMPERATURE

The lowest temperature(-40 degrees celsius) this sensor can detect.

=back

=cut

use constant MIN_TEMPERATURE    => -40;

=head2 METHODS

=over 3

=item * celsius()

Returns the current temperature from the device in celsius degrees.

=cut

sub celsius
{
    my $self    = shift;
    my @data    = ();
use Data::Dump qw(dump);
print "debug Internal: $self \n";
	@data = $self->{unit}->read_temperatures();
	return $data[0];
}

=back

=head1 INHERIT METHODS FROM

Device::USB::PCSensor::HidTEMPer::Sensor

=head1 DEPENDENCIES

This module internally includes and takes use of the following packages:

  use Device::USB::PCSensor::HidTEMPer::Sensor;

This module uses the strict and warning pragmas. 

=head1 BUGS

Please report any bugs or missing features using the CPAN RT tool.

=head1 FOR MORE INFORMATION

None

=head1 AUTHOR

Daniel Fahlgren

(Based on code by Magnus Sulland < msulland@cpan.org >)

=head1 ACKNOWLEDGEMENTS

Thanks to Jean F. Delpech for the temperature fix that solves the problem
with temperatures below 0 Celsius.


This code is inspired by Relavak's source code and the comments found 
at: http://relavak.wordpress.com/2009/10/17/
temper-temperature-sensor-linux-driver/

=head1 COPYRIGHT & LICENSE

Copyright (c) 2010-2011 Magnus Sulland

This program is free software; you can redistribute it and/or modify it 
under the same terms as Perl itself.

=cut

1;
