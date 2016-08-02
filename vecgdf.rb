#!/usr/bin/env ruby

# vectronic.rb
# This script downloads all collar data from the 
# vectronic-wildlife website. 
# It ignores collars with no data for the 
# specified time period.

require 'nokogiri'
require 'mechanize'
require 'open-uri'
require 'fileutils'
require 'csv'
require 'optparse'
require 'optparse/date'
require 'geoutm'


# login stuff
url = "https://www.vectronic-wildlife.com"


# Command Line Options
options = {:user => "cadfw1",
		   :db => "desertbighorn",
		   :password => nil, 
		   :dir => "./data/vectronic/",
		   :beginDate => Date.today,
		   :endDate => Date.today
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
end
parser.parse!

userID = options[:user]
dbName = options[:db]
password = options[:password]


loginParams = { 'type' => 'full',
	'DB' => dbName, 
	'UID' =>  userID, 
	'PW' => password}
urlLogin = "https://www.vectronic-wildlife.com/login.php?DB=" + 
	dbName + "&PW=" + password + "&UID=" + userID + "&type=full"

#Download info
downloadDir = options[:dir].gsub(/([^\/]$)/, '\1/') # append / if none
downloadDir += dbName + "/"
FileUtils::mkdir_p downloadDir unless File.exists?(downloadDir)
#class AttachmentSaver < Mechanize::File
#	attr_reader :gdf
CSV_DELIM = "\t"

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
a.post(urlLogin, loginParams)

# Get list of collars
collarList = Array::new
a.page.parser.css("div#animalSelection option").each do |n|
	collarList.push(n.text)
end

collarList.each do |collar|
	dataUrl = url + "/getData.php?" + 
				"animal=" + collar +
				dateStr + 
				"&type=table&tz=-420&maxCount=9999999"
	a.get(dataUrl)

	# Save GDF
	if a.page.link_with(:text => /gdf/i) then 
		r = a.page.link_with(:text => /gdf/i).click 
		r.save(downloadDir+r.filename)
	end

end

