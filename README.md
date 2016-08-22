# collar-dl

This is a collection of software tools to scrape, process, and manage gps collar data. 
The current version 1 supports downloading from tellus and vectronic collars. 

## Requirements:

- Ruby (tested on version 2.3.1) 
- bundler

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
    > ./tellus.rb
    > ./vecgdf.rb

5. If you would like to run these commands from any directory, add the collar-dl/bin directory to your PATH variable.

## Windows Requirements help: 

Install ruby from : http://rubyinstaller.org/
Use version 2.3.1 (x64)

Install bundler from command prompt (Use Git Bash or Powershell (x86) )
> gem install bundler




