# StegoGenesis
StegoGenesis is Perl script that encodes/decodes a secret message to/from a BMP image.

## Setup
1. Install Perl https://www.perl.org/get.html
1. Download `stego_genesisV7.pl` file.
1. Download a **.BMP** image, and save to the same directory as the `stego_genesisV7.pl` file.
1. Open a command prompt shell in the file's directory

## Useage
### Create a Secret Message
1. Run the script with `perl ./stego_genesisV7.pl`
1. Choose '(1) -  Create a Secret Message File' from the menu
  1. Input the secret message
1. Enter the name of the image file
  * stego_genesis will create a new image file, as: **stego[filename.bmp]**
  * This image file can be opened with a viewer
 
 ### Decode a Secret Message
 1. Choose '(2) - Decode a Secret Message File' from the menu
 1. Enter the filename of the stego image created previously
  1. Wait for the script to process the image
 1. The secret message will be displayed on the screen
