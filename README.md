# collar-dl

This is a collection of software tools to scrape, process, and manage gps collar data. 
The current version 1 supports downloading from tellus and vectronic collars. I hope to add Lotek, ats, etc.
It would also be nice to add a GUI. Note this repository also includes tools to convert GDF files into CSVs, and tools to convert
ECEF XYZ coordinates into lat lon. These are used in the vecgdf.rb script, and the modules that do this are in the /lib directory. 

## Requirements:

- Ruby (tested on version 2.3.1)    https://www.ruby-lang.org/en/
- bundler   http://bundler.io/

## Install:

1. Download this repository using git or as a zip:
https://github.com/rgzn/collar-dl/archive/realdeal.zip
(And if downloading as a zip, unzip it).

2. Open a shell (on windows use Powershell (x86) ) and go to the path where you downloaded collar-dl:
eg. 
    > cd c:/users/myusername/collar-dl

3. Install the project dependencies with bundler:
    > bundle install

4. Test installation by running the two main commands in the bin directory:
    > cd bin    
    > ruby tellus.rb    
    > ruby vecgdf.rb    

5. If you would like to run these commands from any directory, add the collar-dl/bin directory to your PATH variable.

## Windows Requirements help: 

Install ruby from : http://rubyinstaller.org/
Use version 2.3.1 (x64)

Install bundler from command prompt (Use Git Bash or Powershell (x86) )
> gem install bundler

## Usage

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
    
    > ruby tellus.rb -u Clinton@osu -p ****** -d tellusTest -b 20160720 -e 20160801 -v -x
    > ./vecgdf.rb -u cadfw1 -p ****** -D desertbighorn --dir ~/Desktop/myAutoDL -x vectronic_combined.csv 


