# collar-dl

This is a collection of software tools to scrape, process, and manage gps collar data. 
The current version 1 supports downloading from tellus, vectronic, and sirtrack collars. I hope to add Lotek, ats, etc. 
It would also be nice to add a GUI. Note this repository also includes tools to convert GDF files into CSVs, and tools to convert
ECEF XYZ coordinates into lat lon. These are used in the vecgdf.rb script, and the modules that do this are in the /lib directory. 
This project is continually updated. If there is a problem, please check this repo for updates and/or contact me. 

## Summary of Contents:
collar-dl is a repository containing the ruby scripts and libraries to run automated downloads from gps collar manufacturers. 
The project directory structure is as follows: 

- collar-dl : root directory of the project
  - bin : contains main user-executable scripts
  - etc : accessory scripts for hacking
  - lib : libraries and modules used by the scripts in bin and etc
  - notes : text notes on file formats and methods

## Requirements:

This project is written entirely in [Ruby](https://www.ruby-lang.org/). It is cross platform and open source. 
I've tested it on OS X, Debian, and Windows 7 using ruby 2.3.1

You will need to have the Ruby interpreter installed to run the scripts. If you are using windows, 
see the section at the bottom for more help installing Ruby. In addition to plain ruby, these scripts use a 
variety of gems (Pre-packaged ruby modules). I've built this project with bundler, so the only additional 
Gem you need to actively install is that. 

- Ruby (tested on version 2.3.1)    https://www.ruby-lang.org/en/
- bundler   http://bundler.io/

## Install:

Assuming you have the requirement, these are the steps to set up the project:

1. Download this repository using git or as a zip:
https://github.com/rgzn/collar-dl/archive/realdeal.zip
(And if downloading as a zip, unzip it). You will want to place the collar-dl folder somewhere 
useful for permanent easy access. 

2. Open a shell (on Windows use Powershell (x86) ) and go to the path where you downloaded collar-dl:
eg. 
    > cd c:/users/myusername/collar-dl     
(cd is the 'change directory' command) 

3. Install the project dependencies with bundler. This might take some time to download the required gems. Use the following command: 
    > bundle install

4. Test installation by running the two main commands in the bin directory:
    > cd bin    
    > ruby tellus.rb    
    > ruby vecgdf.rb    
You can also run commands in your current directory with the following syntax:
    > ./tellus.rb
This tells the shell to look in the current directory for 'tellus.rb' and attempt to run it. Running a .rb will call the Ruby interpreter. 

    
5. If you would like to run these commands from any directory without specifying the location of the script, add the collar-dl/bin directory to your PATH variable. Then you will be able to open a shell in any directory and run:
    > tellus.rb

## Windows Requirements help: 
I have tested everything on Windows 7 using the 64 bit versions of all involved software. This means 64 bit ruby, powershell x86, etc. Mixing the 64bit and 32bit versions of software will make things very slow. 32bit versions of everything should also work, but I have not tried. 

Install ruby from : http://rubyinstaller.org/
  - Use version 2.3.1 (x64)
  - Make sure to check the "add to PATH" option during the installation


Install bundler from command prompt (Use Git Bash or Powershell (x86) ) using the following command:
    > gem install bundler

## Usage

All commands in the bin directory follow standard unix command line interface syntax. Options are passed to the command on invocation using dash-denoted flags. 
Each option flag has two equivalent possibilities: a single dash and single letter (such as -h ), or a double dash and a word (such as --help). Running a command with the help option will display all possible options for that command. 

Usage:     

    tellus.rb [options]        
    -u, --username user              Username       
    -p, --password password          Password      
    -d, --dir dir                    Directory
    -h, --help                       Displays Help      
    -b, --begin [date]               Beginning date to retrieve data      
    -e, --end [date]                 Ending date to retrieve data      
    -v, --[no-]verbose               Run verbosely      
    -x, --csv [CSV_FILENAME]         Translate to single CSV/TXT (using filename if supplied)
    -z, --debug                      Run in debug mode           

    Usage: vectgdf.rb [options]      
    -u, --username user              Username     
    -D, --database [database]        db name     
    -p, --password password          Password     
    -d, --dir dir                    Directory     
    -h, --help                       Displays Help     
    -b, --begin [date]               Beginning date to retrieve data     
    -e, --end [date]                 Ending date to retrieve data     
    -v, --[no-]verbose               Run verbosely     
    -x, --csv [CSV_FILENAME]         Translate to CSV/TXT
                                      (using filename if supplied)     
                                      
## Examples:
A couple different ways to use these scripts:    

Display help for tellus.rb: 

    > ruby tellus.rb -h 
    
Download tellus data into a directory titled "tellusTest" and convert data into a single CSV file: 

    > ruby tellus.rb -u Clinton@osu -p ****** -d tellusTest -b 20160720 -e 20160801 -v -x

Download vectronic data insto a directory on the desktop titled "myAutoDL", and convert all data into a single csv with given title:

    > ./vecgdf.rb -u cadfw1 -p ****** -D desertbighorn --dir ~/Desktop/myAutoDL -x vectronic_combined.csv 


