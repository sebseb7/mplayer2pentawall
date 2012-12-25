#!/usr/bin/perl

use strict;
use pwhd;
use GD;
use Time::HiRes qw(usleep time);


my $scale = 3;
pwhd::init();
	warn pwhd::readline();
#pwhd::setLevel(4);
#	warn pwhd::readline();

my $start = time;

my $frame =0;

while(1)
{

opendir(in,'./') || die $!;
my @dir=readdir(in);
close in;

my @frame;

foreach my $x (0..575)
{
	$frame[$x] = '000000';
}


my $files=0;
foreach my $file (@dir)
{	
	next unless $file =~ /\.png$/;
	$files++;
	
	my $image;
	do
	{
		$image = GD::Image->newFromPng($file);
		if(! $image)
		{
			warn 'Retry';
			usleep(1000);
		}
	}until($image);

	(my $width,my $height) = $image->getBounds();

	my $offsetX= int(($width-(24*$scale))/2);
	my $offsetY= int(($height-(24*$scale))/2);

	foreach my $x (0..23)
	{
		foreach my $y (0..23)
		{
			my $red=0;
			my $green=0;
			my $blue=0;
			foreach my $x1 (0..($scale-1))
			{
				foreach my $y1 (0..($scale-1))
				{
					(my $r,my $g, my $b) = $image->rgb($image->getPixel($y*$scale+$y1+$offsetX,$x*$scale+$x1+$offsetY));
					$blue+=$b;
					$green+=$g;
					$red+=$r;

				}
			}

				$frame[$y+$x*24] = 
				sprintf("%02x",$red/($scale*$scale)).
				sprintf("%02x",$green/($scale*$scale)).
				sprintf("%02x",$blue/($scale*$scale));
		}
	}


	pwhd::binFrame('03'.join('', @frame));
	unlink $file;
	if($frame > 15)
	{
		pwhd::readline();
	}
		$frame++;

	if($frame % 10 == 0)
	{
		warn (1/ (time-$start) );
	}
	$start = time;

}

usleep(5000) unless $files;
}
