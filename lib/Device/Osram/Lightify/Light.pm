
=head1 NAME

Device::Osram::Lightify::Light - The interface to a single light

=head1 DESCRIPTION

This module allows basic operation of an Osram lightify bulb.

The objects are not expected to be constructed manually, instead
they are discovered dynmically via communication with the hub.

=cut

=head1 SYNOPSIS

   use Device::Osram::Lightify;

   my $tmp = Device::Osram::Lightify::Hub->new( host => "1.2.3.4" );

   # Show all nodes we found
   foreach my $light ( $tmp->lights() ) {
      print "Found light " . $light->name() . "\n";
   }

=cut

=head1 DESCRIPTION

This module allows basic control of an Osram Lightify bulb.

=cut

=head1 METHODS

=cut

use strict;
use warnings;

package Device::Osram::Lightify::Light;

#
#  Allow our object to treated as a string.
#
use overload '""' => 'stringify';


=head2 new

Create a new light-object.

This is invoked by C<Hub:lights()> method, which will read a binary
string containing all the details of the light - we must then parse
it according to L<Device::Osram::Lightify::API>.

=cut

sub new
{
    my ( $proto, %supplied ) = (@_);
    my $class = ref($proto) || $proto;

    my $self = {};
    bless( $self, $class );


    $self->{ 'hub' } = $supplied{ 'hub' } || die "Missing 'hub' parameter";
    $self->{ 'binary' } = $supplied{ 'binary' } ||
      die "Missing 'binary' parameter";

    $self->_decode_binary();
    return $self;
}


=begin doc

Internal method, parse the status of a lamp.

=cut

sub _decode_binary
{
    my ($self) = (@_);

    my $buffer = $self->{ 'binary' };

    #
    # my $str    = $buffer;
    # $str =~ s/(.)/sprintf("0x%x ",ord($1))/megs;
    # print "HEX:" . $str . "\n";
    #

    # Get the MAC
    my $mac = substr( $buffer, 2, 8 );
    foreach my $c ( reverse( split( //, $mac ) ) )
    {
        $self->{ 'mac' } .= sprintf( "%02x", ord($c) );
    }

    # Get the firmware-version
    my $ver = substr( $buffer, 11, 4 );
    foreach my $c ( split( //, $ver ) )
    {
        $self->{ 'version' } .= "." if ( $self->{ 'version' } );
        $self->{ 'version' } .= sprintf( "%x", ord($c) );
    }

    if ( ord( substr( $buffer, 18, 1 ) ) eq 1 )
    {
        $self->{ 'status' } = "on";
    }
    else
    {
        $self->{ 'status' } = "off";
    }

    # Brightness
    $self->{ 'brightness' } = ord( substr( $buffer, 19, 1 ) );

    # Temperature in kelvins
    my $k1 = ord( substr( $buffer, 20, 1 ) );
    my $k2 = ord( substr( $buffer, 21, 1 ) );
    $self->{ 'temperature' } = ( $k1 + ( 256 * $k2 ) );

    # R,G,B,W
    $self->{ 'r' } = ord( substr( $buffer, 22, 1 ) );
    $self->{ 'g' } = ord( substr( $buffer, 23, 1 ) );
    $self->{ 'b' } = ord( substr( $buffer, 24, 1 ) );
    $self->{ 'w' } = ord( substr( $buffer, 25, 1 ) );

    # The name of the bulb.
    $self->{ 'name' } = substr( $buffer, 26, 15 );
    $self->{ 'name' } =~ s/\0//g;
}


=head2 brightness

Get the brightness value of this light (0-100).

=cut

sub brightness
{
    my ($self) = (@_);

    return ( $self->{ 'brightness' } );
}


=head2 mac

Get the MAC address of this light.

=cut

sub mac
{
    my ($self) = (@_);

    return ( $self->{ 'mac' } );
}

=head2 name

Return the name of this light.

=cut

sub name
{
    my ($self) = (@_);

    return ( $self->{ 'name' } );
}



=head2 rgbw

Return the current RGBW value of this light.

=cut

sub rgbw
{
    my ($self) = (@_);

    my $x = "";
    $x .= $self->{ 'r' };
    $x .= ",";
    $x .= $self->{ 'g' };
    $x .= ",";
    $x .= $self->{ 'b' };
    $x .= ",";
    $x .= $self->{ 'w' };

    return ( $x );
}


=head2 status

Is the lamp C<on> or C<off> ?

=cut

sub status
{
    my ($self) = (@_);

    return ( $self->{ 'status' } );
}


=head2 temperature

Get the temperature value of this light (2200-6500).

=cut

sub temperature
{
    my ($self) = (@_);

    return ( $self->{ 'temperature' } );
}


=head2 version

Get the firmware version of this lamp.

=cut

sub version
{
    my ($self) = (@_);

    return ( $self->{ 'version' } );
}



=head2 on

Set this light to be "on".

=cut

sub on
{
    my ($self) = (@_);

    print "Device::Osram::Lightify::Light::on() -> NOP\n";
}


=head2 on

Set this light to be "off".

=cut

sub off
{
    my ($self) = (@_);

    print "Device::Osram::Lightify::Light::off() -> NOP\n";
}


=head2 rgb

Set the specified RGB values of this light.

=cut

sub set_rgb
{
    my ( $self, $r, $g, $b, $w ) = (@_);

    print "Device::Osram::Lightify::Light::set_rgb() -> NOP\n";

}

=head2 set_brightness

Set the brightness value of this light - valid values are 0-100.

=cut

sub set_brightness
{
    my ( $self, $brightness ) = (@_);
    print "Device::Osram::Lightify::Light::set_brightness() -> NOP\n";
}



=head2 stringify

Convert the record to a string, suitable for printing.

=cut

sub stringify
{
    my ($self) = (@_);
    my $txt = "";

    $txt .= "Name: " . $self->name() . "\n";
    $txt .= "\tMAC:" . $self->mac() . "\n";
    $txt .= "\tversion:" . $self->version() . "\n";
    $txt .= "\tBrightness:" . $self->brightness() . "\n";
    $txt .= "\tRGBW:" . $self->rgbw() . "\n";
    $txt .=  "\tTemperature:" . $self->temperature() . "\n";
    $txt .=  "\tStatus:" . $self->{'status'} . "\n";

    $txt;
}

1;



=head1 AUTHOR

Steve Kemp <steve@steve.org.uk>

=cut

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 Steve Kemp <steve@steve.org.uk>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut