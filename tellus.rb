#!/usr/bin/env ruby
#
# Tellus Collar Download script
# 
# This script logs into the Tellus collar data website and 
# 	downloads data from all available collars
# 
# To do: 
#  Currently login information, collar duration, etc, are all hardcoded
#  into the script. It would be better to make these inputs so this
#  could be easily included in a larger program.
#
# Jonathan Weissman
# CA Dept. of Fish and Wildlife
# jmw@demidi.eu
# 2015

require 'mechanize'
require 'open-uri'
require 'optparse'

options = {:user => nil, :password => nil}
parser = OptionParser.new do |opts|
	opts.banner = "Usage: tellus.rb [options]"
	opts.on('-u', '--username user', 'Username') do |user|
		options[:user] = user
	end
	opts.on('-p', '--password password', 'Password') do |password|
		options[:password] = password
	end
	opts.on('-h', '--help', 'Displays Help') do
		puts opts
		exit
	end
end

parser.parse!

# Login Information
tellusURL = "http://tellus.televilt.se/"
#tellusLogin = "Clinton@osu"
#tellusPassword = "8c000c"

tellusLogin = options[:user] 
tellusPassword = options[:password]

# Download info
downloadDir = "./data/tellus/"

# Date Information
dateNow = Date.today
periodMonths = 1
dateStart = dateNow << periodMonths
periodString = dateStart.strftime("%Y%m%d") + "-" + dateNow.strftime("%Y%m%d")

# Initialize browsing agent
a = Mechanize.new
a.pluggable_parser.csv = Mechanize::Download

# Login
a.get(tellusURL)
loginForm = a.page.form
loginForm.field_with(:name => /user/).value = tellusLogin
loginForm.field_with(:name => /pass/).value= tellusPassword
loginForm.field_with(:name => /duration/).value= 480
loginButton = loginForm.button_with(:name => /login/)
a.submit(loginForm, loginButton)

# Get download links
dataPage = a.page.link_with(:text => /Position/).click
collarLinks = dataPage.links_with(:text => "Download Data")

# Download data for each collar for appropriate dates
collarLinks.each do |collarLink|
	collarPage = collarLink.click
	downloadForm = collarPage.forms[1]
	downloadButton = downloadForm.button_with(:name => /download/)
	downloadForm.field_with(:name => /start_year/).value = dateStart.year
	downloadForm.field_with(:name => /start_month/).value = dateStart.month
	downloadForm.field_with(:name => /start_day/).value = dateStart.day
	r = a.submit(downloadForm, downloadButton);
	r.save(downloadDir+r.filename)
end

# Logout
dataPage.link_with(:text => "Log out").click



	

