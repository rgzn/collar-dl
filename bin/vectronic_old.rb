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

ARGV.push('-h') if ARGV.empty?		# show help if no arguments

options = {:user => "cadfw1",
		   :db => "desertbighorn",
		   :password => nil, 
		   :dir => "data/vectronic/",
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

# userID = "cadfw1"
# dbName = "desertbighorn"
# password = "snbsrp407"
# userID = "snbs"
# dbName = "sierrabighorn"
# password = "snbsrp407"

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

downloadDir = "data/vectronic/" + dbName + "/"
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
# dateNow = Date.today
# periodMonths = 1
# dateStart = (dateNow << periodMonths) - 2
# periodString = dateStart.strftime("%Y%m%d") + "-" + 
#  	dateNow.strftime("%Y%m%d")
# startDateStr = dateStart.strftime("%Y-%m-%d")
# endDateStr = dateNow.strftime("%Y-%m-%d")

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

downloadedFiles = []
collarList.each do |collar|
	dataUrl = url + "/getData.php?"
	animalStr = "animal=" + collar
	dateStr = "&startDate=" + startDateStr + "&endDate=" + endDateStr
	dataUrl += animalStr + dateStr + "&type=table&tz=-420&maxCount=20000"
	a.get(dataUrl)

	# Save html table
	# filename = downloadDir + collar + ".html"
	# open(filename, 'w') { 
	# 	|f| f << a.page.body 
	# } unless a.page.body.include? "No data found"

	# Convert html to csv
	unless a.page.body.include? "No data found" then 
		csvFile = downloadDir + collar + "_" + periodString +  ".csv"
		doc = a.page.parser
		caption = doc.xpath('//table//caption').text
		name = caption.split[0]
		if caption.scan(/Animal ID: (\d+)/)[0] then 
			puts caption.scan(/Animal ID: (\d+)/)
			animalID = caption.scan(/Animal ID: (\d+)/)[0].to_s.match(/\d/)[0]
		else
			animalID = "_"
		end
		if caption.scan(/Gender: [A-Za-z]+/).first then
			sex = caption.scan(/Gender: [A-Za-z]+/).first.split[1]
		else 
			sex = "_"
		end
		header = ["Name", "Animal_ID", "Sex"]
		rowStart = [name, animalID, sex]
		doc.xpath('//table//thead/th').each {|cell| header.push(cell.text)}
		open(csvFile, 'w') do |f|
			header.each { |cell| f << cell + CSV_DELIM }
			f << "\n"
		end
		#csvOut = CSV.new("", :headers => header, :write_headers => true, :return_headers => true)
		doc.xpath('//table//tr').each do |row|
			rowEntry = rowStart
			row.xpath('td').each do |cell|
				rowEntry += [cell.text.gsub("\n", ' ').gsub('"', '\"').gsub(/(\s){2,}/m, '\1')]
			end
			open(csvFile, 'a') do |f|
				rowEntry.each { |cell| f << cell + CSV_DELIM }
				f << "\n"
			end
		end
	end

	# Save GDF
	# if a.page.link_with(:text => /gdf/i) then 
	# 	r = a.page.link_with(:text => /gdf/i).click 
	# 	r.save(downloadDir+r.filename)
	# end

end

