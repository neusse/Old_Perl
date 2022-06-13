#!/usr/bin/perl

# This findes all the MRC files in the current director all the way down the dir tree
# and reads the date from the file name and touches the file to set the modified time to match.
# this allows splunk to pickup that time and use it as all event timestamps.
# this is specific to MRC files.

# created by George Neusse 8/18/17
# contact neusse@gmail.com

use strict;

use File::Find;
use Time::Local;

my $verbose = 0;    # 1 = print 0 = silent

my $argc = @ARGV;

if ( $argc < 3 ) {
    print "USAGE:: $0 'search path' 'string to match in file name'  'MDY'|'YMD'\n";
    print "MDY or YMD is a flag for how the date is formatted in the file name.\n";
    exit(1);
}

my ( $search_path, $search_pattern, $Yflag ) = @ARGV;

print "fixing     search_path => ($search_path) search pattern => ($search_pattern) YMD => ($Yflag) \n"
  if $verbose;

find( \&modify_them, $search_path );

sub modify_them {

    my ( $year, $mon, $day );

    return       if !-f;
    return       if ( index( $_, $search_pattern ) == -1 );

    print "\n$_" if $verbose;
    
    if ( $_ =~ /(\d+)/ ) {
        if ( $Yflag == "YMD" ) {
            $year = substr $1, 0, 4;
            $mon  = substr $1, 4, 2;
            $day  = substr $1, 6, 2;
        }
        else {
            $mon  = substr $1, 0, 2;
            $day  = substr $1, 2, 2;
            $year = substr $1, 4, 4;
        }

        print "\n ====> changed $1 $_ $year-$mon-$day\n" if $verbose;

        my $mytime = timelocal( 0, 0, 0, $day, $mon - 1, $year );

        my $atime = $mytime;
        my $mtime = $mytime;

        utime $atime, $mtime, $_;
    }

}
