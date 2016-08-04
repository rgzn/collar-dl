#!/usr/bin/env ruby
#

require 'mechanize'
require 'open-uri'
require 'logger'

# Login info
url = "https://webservice.lotek.com"
login = "DesertBighorn"
password = "MojaveCDFG123"

# Date Information
dateNow = Date.today
periodMonths = 1
dateStart = dateNow << periodMonths
dateFormat = "%B %d, %Y"

# Download info
downloadDir = "./data/lotek/"
fileName = "LotekDesertAll" +
	dateStart.strftime("%Y%m%d") + "-" +
	dateNow.strftime("%Y%m%d") +
	".csv"

# Lotek HTTP Magic
magicString1 = 
	"{\"isEnabled\":true,\"logEntries\":[],\"selectedIndices\":"
magicString2 = 
	",\"checkedIndices\":[],\"scrollPosition\":0}"

# Initialize browser
a = Mechanize.new

a.pluggable_parser.csv = Mechanize::Download
#a.pluggable_parser.txt = Mechanize::Download
a.log = Logger.new(STDOUT)

# Login
a.get(url)
loginForm = a.page.form
loginButton = loginForm.button_with(:name => /login/i)
loginForm.field_with(:name => /login/i).value = login
loginForm.field_with(:name => /password/i).value = password
loginForm.checkbox.check
a.submit(loginForm, loginButton)

dataPage = a.page.link_with(:text => /download/i).click
dlForm = dataPage.form

# Select Collars
nCollars = dataPage.parser.css("li[class='rlbItem']").length
collarIndices = Array.new(nCollars){ |index| index }
dlForm.field_with(:name => /device/i).value = 
	magicString1 + collarIndices.to_s + magicString2
dlForm.field_with(:name => /start/i).value = 
	dateStart.strftime(dateFormat)
dlForm.field_with(:name => /end/i).value = 
	dateNow.strftime(dateFormat)
dlForm.field_with(:name => /dloptions/i).value = 
	"Spread Sheet (CSV)"
dlButton = dlForm.button_with(:name => /download/i)

#experimental:
dlForm.add_field!('__EVENTTARGET','')
dlForm.add_field!('__EVENTARGUMENT','')

a.submit(dlForm, dlButton).save(downloadDir + fileName)

#dataPage.link_with(:text => /logout/i).click
