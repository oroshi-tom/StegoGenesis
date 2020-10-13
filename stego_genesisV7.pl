#!/usr/bin/perl
#Author: Thomas_Llewellyn_811942
#Source: 
#Date: Mon Jul 22 12:54:33 MDT 2019
#Filename: stego_genesisV7.pl

#---VERSION HISTORY------------------------------------------------------------#
#Current: 7.0
# 1.0 - Combining multiple functions into one script, convert temp file outputs to arrays
# 2.0 - Converting file to binary dump
# 3.0 - Revert file to original format
# 4.0 - Change to using hexadecimal values instead of bianry. Use .bmp file format only
# 5.0 - Move editing of LSBs into single while loop
# 6.0 - Create subroutines to perform script functions
# 7.0 - Add decoding sctipt, add switch to choose function
################################################################################

#---FUNCTIONS OUTLINE----------------------------------------------------------#
# 
# 1. MESSAGE PROCESSING	
#	get_message
#	convert_message
	
# 2. IMAGE PROCESSING
#	get_image
#	dump_image
#	embed_message
#	make_stego_image

# 3. DECODE MESSAGE
#	get stego_image
#	create hexdump
#	get message
#	decode message from hex to text, display to screen

# 4.	Clean up temp files
################################################################################

use strict;
use warnings;
use Cwd;
system ("clear");

#---VARIABLES------------------------------------------------------------------#
# 0. MAIN
	my ($option);
# 1. MESSAGE PROCESSING		
	my ($flag,
		$plain_message,		#plaintext message from user
		$start_flag,		#special flag to find the start of the message
		$end_flag,			#special flag to find the end of the message
		@plain_chars,		#array of plaintext characters
		$plain_char,		#scalar of plaintext array
		$ans,
		@hex_chars,		#hex numbers of ascii values (from @plain_cahrs)
		$hex_char,			#scalar of binary array
		@nibbles,			#2-bit chunks of 8-bit ascii values
		$nibble,
		$index,				#index for counting
		$count);	

# 2. IMAGE PROCESSING
	my ($source_image,
		$hexdump,
		$ext,
		$line,
		@elems,
		@hexvalues,
		@newhexvalues,
		$newhexvalue,
		$offset,
		$num,
		$i);

# 3. DECODE MESSAGE
	my ($stego_image,		#stego image with embedded message
		@lines, 			#each line in the hex dump
		$hexvalue,			#lsb hex value of each line in hex dump
		@hexary,			#array to temporarily hold hex values
		$hexstring,			#one large string of all lsb hex values
		$startflag,			#'<<<' start of message flag
		$index1,			#index (position) of start flag
		$endflag,			#'>>>' end of message flag
		$index2,			#index of end flag
		$length,			#length of message
		$hexmessage,		#message in hexadecimal format
		$plainmessage);		#message in plaintext		
################################################################################


#---MAIN FUNCTION--------------------------------------------------------------#
#Source: Thomas Llewellyn, Perl In-Class Assingment #1, 2019
while()
	{#step into infinite while loop
		print "Welcome to stego_genesis\n";
		print "Please choose an option from the menu: \n";
		print "="x45;
		print "\n(1)\t-\tCreate a Secret Message File\n(2)\t-\tDecode a Secret Message File\n(3)\t-\tExit Program\n";
		print "="x45;
		print "\n";
		chomp ($option = <STDIN>);
	
		if ($option =~ /3/)					#if the user enters "exit" (ignore case)
			{
				print "Exiting Program...\n";	#display exit message
				sleep 1;							#wait 2 seconds before exiting
				last;								#exit the while loop
			};
		SWITCH:
			{#step into switch
				($option =~ /1/) and do
				{#step into case (1)
					system ("clear");
					$plain_message = &get_message();
					@nibbles = &convert_message();
					&get_image();
					&dump_image();
					&embed_message();
					&make_stego_image();
					&cleanup();
					print "\n(Press 'Enter' to return to the menu)";
					chomp ($option = <STDIN>);
					system ("clear");
					last;
				};#end case 1.
		
				($option =~ /2/) and do
				{#step into case (2)
					system ("clear");
					&get_stego_image();
					&dump_stego_image();
					$plain_message = &decode_message(@lines);
					&print_message();
					&cleanup();
					print "\n(Press 'Enter' to return to the menu)";
					chomp ($option = <STDIN>);
					system ("clear");
					last;
				};#end case (2)
				
				{#step into error trap								
					print "Error, invalid option\n";	#display error trap message
					print "Press 'Enter' to continue...";
					chomp ($option = <STDIN>);
					system ("clear");
					last;
				};#end error trap
			};#end switch				
	}#end while loop


################################################################################
#----------1. MESSAGE PROCESSING----------#
#1a.Get plaintext message from user, and store to array
#1b.Convert each character in array to ascii hexadecimal values, store into array
################################################################################


################################################################################
# 1a.Get plaintext message from user, and store to array
################################################################################
sub get_message()
{
	$flag = 'f';
	while ($flag eq 'f')#set flag to loop until user confirms message
	{
		print "Enter the secret message you want to send: \n";
		chomp ($plain_message = <STDIN>);	#get the message from STDIN
		$start_flag="<<<";	#text to signal where the message starts
		$end_flag=">>>";#text to signal where the message ends
		$plain_message = join(" ",$start_flag, $plain_message, $end_flag);
		#combine flags with message

		print "The message you are sending is: $plain_message\n\n"; #print to verify message
		print "Is this correct?(y/n): ";
		chomp ($ans=<STDIN>);
		until ($ans =~ /[yn]/i)#error trapping for answer
		{
			print "Please answer 'y' for yes, or 'n' for no\n";
			chomp ($ans=<STDIN>);
			system ("clear");
		}
		if ($ans =~ /y/i)
		{
			$flag = 't';
			system ("clear");
		}
		else
		{
			system ("clear");
		}
	}#end while 
		foreach $_($plain_message)	#for each line in the infile handle
		{	
			push (@plain_chars,(split (//,$_)));
			#put each word, separated by whitespace, into an array
		}#end foreach
		return $plain_message;
}#end sub get_message

################################################################################
# 1b.Convert each character in array to ascii hexadecimal values, store into array
################################################################################
sub convert_message()
{
	print "Converting message to hexadecimal...\n\n";
	sleep(1);
	@nibbles = ();	#create array to store hex nibbles (

		foreach $plain_char(@plain_chars)	#foreach char in the array
		{									#step into foreach
			$hex_char = unpack ("H*", pack ("A*",$plain_char));
			#convert each ascii character to 8-bit  hexadecimal equivalent
		
			push (@hex_chars, $hex_char);
			#add the 8-bit binary chunks to array @binary_chars
		
			while ($hex_char =~ /(\w{1})/g)
			#https://www.perlmonks.org/?node_id=115547
			{
				push (@nibbles,$1);
				#add the last match to the array @nibbles
				#this is the array of values to embed into the image
			}
		}	#end foreach	

	#get the length of the message from @nibbles array
	$count = @nibbles;
	print "The message in hexadecimal is: \n";
	print "@nibbles\n\n";
	return @nibbles;
}	
################################################################################
#----------2. IMAGE PROCESSING----------
# 2a. Get source image	
# 2b. Create a Hex Dump Copy
# 2c. Embed Hex Message in Binary Values
#	2c-i. 	- get data offset of image
#	2c-ii.	- replace LSBs of rgb bytes with hex message nibbles
# 2d. Revert image dump, with embedded message, to BMP format
################################################################################


################################################################################
# 2a. Get source image
################################################################################
sub get_image()
{
	$flag = 'f';
	while ($flag eq 'f')#set flag to loop until image file is verified
	{
		print "Enter the name of the image file: \n";
		#get the source image filename from the user
		chomp ($source_image=<STDIN>);
		#read image_file name from STDIN
		#https://stackoverflow.com/questions/3667280/how-do-i-search-for-a-particular-file-in-a-directory-using-perl
		if (-f $source_image)
		#check if file exists in current directory
		{
			$flag = 't';
			print "$source_image found, thank you\n";
		}
		else
		{
			print "File not found in current directory\n";
			sleep (1);
			system ("clear");			
		}
		
	}#end while
	
		($stego_image, $ext) = split (/\./,$source_image);
		#split the filename into name and file extension

		#check file extension
		unless ($ext eq "bmp")
		{
			print "That filetype is not compatible, please choose a .BMP filetype\n";
			
		}

		$stego_image = "stego".$stego_image."\.".$ext;
		#prefix "stego" to the beginning of the filename
		#this will make it easy to identify
		return $stego_image;
}#end sub get_image
################################################################################
# 2b. Create a Hex Dump Copy
################################################################################
#use xxd to create a hex dump of file, will be used to embed the message
sub dump_image()
{
	$hexdump = "hexdump";
	system ("xxd -p -c2 $source_image $hexdump");
}#end sub dump_image
################################################################################
# 2c. Embed Hex Message in Binary Values
#################################################################################
sub embed_message()
{
	open (HEXDUMP, "+<$hexdump") or die "$!, $.\n";
	#open the hexdump file
	while ($line = <HEXDUMP>) 
	{
		#https://stackoverflow.com/questions/28181797/read-specific-column-in-perls
		@elems = $line =~ /(\w{4})/g;
		#each element in the file is a 4-char hexidecimal octet, including a space
		push (@hexvalues, @elems);
		#push the hex values from each line into one large array
	
	}#end while	
			
	#get offset, to find 'editable' part of file	
	$offset = $hexvalues[5]; 
	#the fifth chunk of data contains the pixel offset in the image
	#https://en.wikipedia.org/wiki/BMP_file_format

	#print "Element 5 contains: $offset\n";
	#print check element 5

	$num = unpack ("U*", pack ("H*",$offset));
	#convert the hex value to decimal
	#the offset is the starting byte for BMP pixel data.
	#to get the element, divide element / 2
	#print "The offset in decimal: $num\n";#print check
	$offset = $num/2;
	#this is the actual array element that the embedded message can start

	#replace LSBs of rgb bytes with hex message nibbles
	for ($i=0; $i < $count; $i++)	#for the length of the @nibbles array
	{	
#https://stackoverflow.com/questions/4375820/modify-the-last-two-characters-of-a-string-in-perl
		substr ($hexvalues[$offset + $i], -1) = $nibbles[$i];
		#starting at the offset, replace the last bit with nibbles
				
	}#end for

	open (OUTFILE, ">$hexdump") or die "$!, $.\n";
	#open the hexdump file, and overwrite with modified hex values

	foreach $_ (@hexvalues)
	{
		print OUTFILE "$_\n";
	}
	close OUTFILE;
}#end sub embed_message
#################################################################################
# 2d. Revert image dump, with embedded message, to BMP format
#################################################################################
sub make_stego_image()
{
	print "Processing image, please wait..\n";
	sleep (1);
	system ("xxd -r -p $hexdump $stego_image");
	print "Stego image: '$stego_image' created succesfully!\n";
	#revert hexdump file to .bmp format, using xxd command
}#end sub make_stego_image

################################################################################
#----------3. DECODE MESSAGE----------
# 3a.	Get stego_image
# 3b.	Create hexdump
# 3c. 	Get message
# 3d.	Convert message from hex to text 
# 3e.	Print message to screen
################################################################################	

#################################################################################
# 3a.	Get stego_image
#################################################################################

sub get_stego_image() 
{
	$flag = 'f';
		while ($flag eq 'f')
		#set flag to loop until image file is verified
		{#step into while
			print "Enter the name of the stego image file: \n";
			#get the source image filename from the user
			chomp ($stego_image=<STDIN>);
			#read image_file name from STDIN
			#https://stackoverflow.com/questions/3667280/how-do-i-search-for-a-particular-file-in-a-directory-using-perl
			if (-f $stego_image)
			#check if file exists in current directory
			{
				$flag = 't';
				print "$stego_image found, thank you\n";
			}
			else
			{
				print "File not found in current directory\n";
				sleep (1);
				system ("clear");			
			}
		
		}#end while
}#end sub get_stego_image()	
#################################################################################
# 3b.	Create hexdump
#################################################################################
sub dump_stego_image()
{
	$hexdump = "hexdump";
	system ("xxd -p -c2 $stego_image $hexdump"); 
	#create plain hexdump of stego image
	print "Processing...\n";
	sleep (1);
}#end sub dump_stego_image
	
#################################################################################
# 3c. 	Get message
#################################################################################
sub decode_message()
{
	open (INFILE, $hexdump) or die "$!, $.\n";
	chomp (@lines = <INFILE>);
	#read the hexdump into an array
	close INFILE;
	foreach $_(@lines)
	{#step into foreach
	#https://stackoverflow.com/questions/8963400/the-correct-way-to-read-a-data-file-into-an-array
		$hexvalue = substr ($_, -1);
		#the message values are in the last hex value on each row
		push (@hexary, $hexvalue);
		#store the array into large string
		$hexstring = join '', @hexary;
		#join the @hexary into one large string
	}#end foreach
	
#################################################################################
# 3d.	Convert message from hex to text
#################################################################################

	$startflag = "3c3c3c";
	#message start flag
	$index1 = index($hexstring, $startflag);
	#get the index of the starting flag
	$endflag = "3e3e3e";
	#message end flag
	$index2 = index($hexstring, $endflag);
	#get the index of the ending flag
	$length = $index2 - ($index1 + 6);
	#the message length, adjust to discard flag in output

	$hexmessage  = substr $hexstring, ($index1 + 6), $length;
	#message in hexadecimal is the substring of $hexstring, from $index1 to $length
	#adjust to remove flag at beginning and end

	$plain_message = pack ("H*",$hexmessage);
	#convert hexadecimal values to text, based on ASCII values
	#print "\n\nThe secret message is: \n\n'$plain_message'\n";
	return $plain_message;
	#print the secret message to screen in plaintext
}#end sub decode_message

#################################################################################
# 3e.	Print message to screen
#################################################################################


sub print_message()
{
	system ("clear");
	print "\nThe secret message is: \n";
	print "#"x45;
	print "\n\n'$plain_message'\n\n";
	print "#"x45;
}

#################################################################################
# 4.	Clean up temp files
#################################################################################

sub cleanup
{
	#cleanup; remove hexdump files
	system ("rm hexdump");
}





