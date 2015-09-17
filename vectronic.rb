#!/usr/bin/env ruby

require 'nokogiri'
require 'mechanize'
require 'open-uri'
require 'fileutils'

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
	filename = downloadDir + collar + ".html"
	open(filename, 'w') { 
		|f| f << a.page.body 
	} unless a.page.body.include? "No data found"

	# Save GDF
	if a.page.link_with(:text => /gdf/i) then 
		r = a.page.link_with(:text => /gdf/i).click 
		r.save(downloadDir+r.filename)
	end

end

