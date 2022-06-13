# INIsort - sorts INI files and checks for multiple entries
# 2003-01-13 Oliver Betz www.oliverbetz.de
# Based on code from Brad Baxter
# (see Usenet posting <Pine.A41.3.96.980417103111.63622N-100000@ginger.libs.uga.edu>)

# you don't need a full perl installation to run this script, since it
# doesn't need any modules. Activstate's Perl.exe and perl58.dll
# are sufficient, together <400KB compressed

use strict; # don't use "strict" when running with minimum perl

my %inihash = ();
my( $value, $key, $section, $lastsection) = ( '' );
my $stdouterr = 1;
my $outfilerr = 0; # set as you like

if($ARGV[0] eq ''){
  print STDERR "Script to sort .INI or .CONF files\n";
  print STDERR "Usage: $0 infile [outfile]\n";
  exit;
}

if((-f($ARGV[0])) == 0){
  print STDERR "couldn\'t open $ARGV[0]\n";
  exit;
}

### load the .ini file data
ini($ARGV[0], \%inihash );

if($ARGV[1] ne ''){
  open(OUTFILE, ">$ARGV[1]") or die "couldn\'t open $ARGV[1]";
}
else{
  open(OUTFILE, ">-") or die "couldn\'t write to STDOUT";
  $stdouterr = 0; # clean output
};

### print sections in alpha order, without subroutines
foreach $section ( sort keys %inihash ) {

  print OUTFILE "\n[$section]\n" if($section ne ''); # keys before section
      foreach $value ( @{$inihash{$section}{$section}}) {
      print OUTFILE "$value";
    }  # foreach value

}  # foreach section
close OUTFILE;

exit;

#######################################################################
### ini: read a .ini file and load into a hash of hashes of arrays
sub ini {
  my( $file, $hash_ref) = @_;
  my( $linein, $section ) = ( '');

  open( FILE, $file ) or die "Can't open $file";
  while(<FILE>) {
    chomp;
    if( $_ =~ /^\s*\[([^\]]+)\]/ ) {
	    
	    
      $section = $1;
      
      #print "my section $section\n";
      
      
      
      push( @{$$hash_ref{$section}{$1}}, () );
      # "add" empty table to create hash if it didn't exist
    }  # if section name
    my @array;
    while ( my $line = <FILE> ) {
        last if $line =~ /^\s*$/;
        push @array, $line;
    }
      push( @{$$hash_ref{$section}{$section}}, @array  );
      
      #print "my stuff [$1] \n @array\n\n=============\n";
  }  # while
  close( FILE );
  #exit;
}  # end sub ini

__END__

