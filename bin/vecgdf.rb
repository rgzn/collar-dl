#!/usr/bin/env ruby

# vecgdf.rb
# This script downloads all collar data from the 
# vectronic-wildlife website. 
# It ignores collars with no data for the 
# specified time period.

# Use bundled environment:
require 'bundler/setup'

# Windows has special needs:
require 'os' 
require 'certified' if OS.windows?

require 'nokogiri'  		# HTML parsing gem
require 'open-uri'  		# http access
require 'fileutils'		# File manipulation
require 'csv'			# CSV manipulation
require 'optparse'		# Cmd Line Input options
require 'optparse/date'			
require 'geoutm'		# UTM/LLA conversions
require 'mechanize'		# web browsing
require 'pry'

require_relative '../lib/gdf.rb' # custom GDF module

CSV_DELIM = "\t"

# login stuff
url = "https://www.vectronic-wildlife.com"


# Command Line Options
ARGV.push('-h') if ARGV.empty?		# show help if no arguments

options = {	   :user => "cadfw1",
		   :db => "desertbighorn",
		   :password => nil, 
		   :dir => "data/vectronic/",
		   :beginDate => Date.today,
		   :endDate => Date.today,
		   :verbose => nil,
		   :csv => true,
		   :csv_filename => nil
}
parser = OptionParser.new do |opts|
	opts.banner = "Usage: vectronic.rb [options]"
	opts.on('-u', '--username user', 'Username') do |user|
		options[:user] = user
	end
	opts.on('-D', '--database [database]', 'db name') do |db|
		options[:db] = db
	end
	opts.on('-p', '--password password', 'Password') do |password|
		options[:password] = password
	end
	opts.on('-d', '--dir dir', 'Directory') do |dir|
		options[:dir] = dir
	end
	opts.on('-h', '--help', 'Displays Help') do
		puts opts
		exit
	end
	opts.on('-b', '--begin [date]', Date, 
			'Beginning date to retrieve data') do |beginDate|
		options[:beginDate] = beginDate
	end
	opts.on('-e', '--end [date]', Date,
			'Ending date to retrieve data') do |endDate|
		options[:endDate] = endDate
	end
	opts.on("-v", "--[no-]verbose", "Run verbosely") do |v| 
		options[:verbose] = v
		puts "Verbose output ON ..."
	end
	
	opts.on("-x", "--csv [CSV_FILENAME]", 
			"Translate to CSV/TXT", 
			" (using filename if supplied)") do |csv_arg|
		options[:csv] = true
		options[:csv_filename] = csv_arg || nil
	end
end
parser.parse!

if options[:user] == nil
	print "Enter user name: "
	options[:user] = gets.chomp
end

if options[:password] == nil
	print "Enter password: "
	options[:password] = gets.chomp
end



# Set paramaters to user input: 
userID = options[:user]
dbName = options[:db]
password = options[:password]


# Build URL for http request to log in:
loginParams = { 'type' => 'full',
	'DB' => dbName, 
	'UID' =>  userID, 
	'PW' => password}
urlLogin = url + "/login.php?DB=" + 
	dbName + "&PW=" + password + "&UID=" + userID + "&type=full"


#Download info
downloadDir = options[:dir].gsub(/([^\/]$)/, '\1/') # append / if none
downloadDir += dbName + "/"
FileUtils::mkdir_p downloadDir unless File.exists?(downloadDir)

# Date Information
dateStart = options[:beginDate]
dateEnd = options[:endDate]
startDateStr = dateStart.strftime("%Y-%m-%d")
endDateStr = dateEnd.strftime("%Y-%m-%d")
periodString = dateStart.strftime("%Y-%m-%d") + "-" +
	dateEnd.strftime("%Y-%m-%d")
dateStr = "&startDate=" + startDateStr + "&endDate=" + endDateStr
# Initialize browsing agent

a = Mechanize::new
a.pluggable_parser.csv = Mechanize::Download
# a.pluggable_parser.gdf = Mechanize::Download


# Login:
if options[:verbose] 
	puts "Logging on to " + url
	puts "Using username: " + userID + 
		", database: " + dbName + 
		", password: " + password.gsub(/./, '*') +
		" ..."
end

a.post(urlLogin, loginParams)

if options[:verbose]
	if a.page.link_with(:text => /logout/i)
		puts "Successfully logged in"
	else
		puts "There seems to be a login problem, check error log."
	end
end

# Get list of collars

if options[:verbose] 
	puts "Generating list of available collars..."
end

collarList = Array::new
a.page.parser.css("div#animalSelection option").each do |n|
	collarList.push(n.text)
end

if options[:verbose] 
	puts "Available collars: "
	puts collarList
end

# Loop through collars, downloading data for each

if options[:verbose] 
	puts "Downloading collar data..."
end

downloadedGDFs = []
collarList.each do |collar|

	if options[:verbose] 
		puts "Collar: " + collar
	end
	
	dataUrl = url + "/getData.php?" + 
				"animal=" + collar +
				dateStr + 
				"&type=table&tz=-420&maxCount=9999999"
	a.get(dataUrl)
	
	linkToGdf = a.page.link_with(:text => /gdf/i)
	
	if options[:verbose] 
		if linkToGdf.nil? 
			puts "no data found"
		else 
			puts "Downloading data from " + url.gsub(/([^\/]$)/, '\1/') + linkToGdf.href
		end
	end
	# Save GDF
	if linkToGdf then 
		r = linkToGdf.click 
		
		if options[:verbose] 
			puts "Saving data as " + downloadDir + r.filename + "..."
		end
		gdfName = downloadDir + r.filename
		r.save(gdfName)
		downloadedGDFs.push(gdfName)
	end
	
end

if options[:verbose] 
	puts "Finished downloading data to " + downloadDir
end

if options[:csv]
	if options[:verbose] 
		puts "Converting GDF files to CSV..."
	end
	#binding.pry
	if options[:csv_filename]
		csvFileName = options[:csv_filename]
	elsif options[:csv]
		csvFileName = dbName + "_" + 
			dateStart.strftime("%Y%m%d") + "-" + 
			dateEnd.strftime("%Y%m%d") + ".txt"
	end
	GDF::gdfs2csv(downloadedGDFs, downloadDir + csvFileName, CSV_DELIM )
	if options[:verbose] 
		puts "The following GDF files were combined and saved as text in " + 
			downloadDir + csvFileName + " :"
		puts downloadedGDFs
	end
end



