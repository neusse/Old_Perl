#!/usr/bin/perl
#-------------------------------------------------------------------------
#   George Neusse 2/9/16
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# splunk SPL formatter.   Not a pretty print, but better than nothing
# looks through a savedsearch file and finds the SPL, then formats it for easyer reading.
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Libs and setup
#-------------------------------------------------------------------------
use strict;

#-------------------------------------------------------------------------
# I dont like to use global vars other than for configuration,
# not to pass data between functions. But this made it quicker to code.
# maybe someday I will fix it.... ya!
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Global Vars
#-------------------------------------------------------------------------
my $buffer="";
my $i = -1;
my @file;
my $c;
my $fh;

#-------------------------------------------------------------------------
# Main.   More like C feels better than just dropping into it and not knowing how to find the start.
#-------------------------------------------------------------------------
main:{


	my $find = "Flash_Report_UEMM_Filtered_Breach_Alert"; #$ARGV[1];
	my $found = 0;

	#print "Finding [$find] ... \n";


	open($fh, "<", "savedsearch.conf") 	or die "cannot open < mysavedsearch.txt: $!";
	@file = <$fh>;					# slurp in the entire file. Well we did not use slurp but you know what I mean.
	close($fh) || warn "close failed: $!";
	
	$c = next_line(); 				# prime the pump
	do {
		$buffer = ""; 				# clear the buffer since we have new data to manipulate
		
		if( $c =~ m/^search \=/ && $found == 1) { 		# did we find the search SPL?
			#print "looking for end of search $i $find\n" ;
			while($c =~ m/\\$/) { 		# is this a line to collect?
				cb(); 			# concatonate to buffer	.
				$c = next_line(); 	# get next line
			};
			cb(); 				# concatonate the last line collected
			print_buffer($buffer); 			# format the output .
			exit(0);
		} elsif( $c =~ m/^\[$find/) { #|| $c =~ m/dispatch/)  { 		# did we find the start of a section?
			chomp($c);
			#print "Found $c\n"; 			# print it so we know what the SPL belongs to.
			$found = 1;
		} 
		
	} while ( $c = next_line() ); 			# keep scanning while we have lines to look at.

	exit(0); 					# exit without an error code.  ya I know.	
}

#-------------------------------------------------------------------------
# print_buffer - format, munge and print our SPL working buffer
#-------------------------------------------------------------------------
sub print_buffer {
	my $b = shift;

	my $fl = "NotYet";;				# First line flag

	$b =~ s/^ search \= //;
	$b =~ s/^\|//;
	$b =~ s/\s+/ /g;
	my @s = split /\|/,$b;
	foreach my $str (@s ) {

		$str =~ s/^\s+|\s+$//g;

		if( $fl =~  m/NotYet/ ) {
			print "$str\n";
			$fl = "Printed";
		} else {
			print "| $str\n";
		}
	
	}
	
	print "\n++++++\n";
}



#-------------------------------------------------------------------------
# cb - Concatonate what we found to our working SPL buffer
#-------------------------------------------------------------------------
sub cb {
	chomp($c);
	$c =~ s/\\$// ;
	$buffer = $buffer." ".$c;
}
	
	
#-------------------------------------------------------------------------
# next_line - Get the next line from our file buffer
#-------------------------------------------------------------------------
sub next_line {
	$i = $i +1;
	print "[$i]\n";
	$c=$file[$i];
	return $c;
}


__END__


dispatch.earliest_time = -1d
dispatch.latest_time = now
request.ui_dispatch_app = search
request.ui_dispatch_view = search





