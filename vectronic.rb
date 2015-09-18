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

# login stuff
url = "https://www.vectronic-wildlife.com"
userID = "cadfw1"
dbName = "desertbighorn"
password = "snbsrp407"
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
CSV_DELIM = "\1"

# Date Information
dateNow = Date.today
periodMonths = 1
dateStart = dateNow << periodMonths
# periodString = dateStart.strftime("%Y%m%d") + "-" + 
# 	dateNow.strftime("%Y%m%d")
startDateStr = dateStart.strftime("%Y-%m-%d")
endDateStr = dateNow.strftime("%Y-%m-%d")

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
		csvFile = downloadDir + collar + ".csv"
		doc = a.page.parser
		caption = doc.xpath('//table//caption').text
		name = caption.split[0]
		ID = caption.scan(/Animal ID: \d+/).first.scan(/\d+/)
		sex = caption.scan(/Gender: [A-Za-z]+/).first.split[1]
		header = ["Name", "ID", "Sex"]
		rowStart = [name, ID, sex]
		doc.xpath('//table//thead/th').each {|cell| header.push(cell.text)}
		open(csvFile, 'w') do |f|
			header.each { |cell| f << cell + "\t" }
			f << "\n"
		end
		#csvOut = CSV.new("", :headers => header, :write_headers => true, :return_headers => true)
		doc.xpath('//table//tr').each do |row|
			row = rowStart
			row.xpath('td') each do |cell|
				row += cell.text.gsub("\n", ' ').gsub('"', '\"').gsub(/(\s){2,}/m, '\1')
			end
			open(csvFile, 'w') do |f|
				row.each { |cell| f << cell + "\t" }
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

