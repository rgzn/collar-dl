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
require 'optparse/date'
require 'csv'
require 'fileutils'
require 'tempfile'

# Command Line Options
options = {:user => nil, 
		   :password => nil, 
		   :dir => "./data/tellus/",
		   :beginDate => Date.today,
		   :endDate => Date.today
}
parser = OptionParser.new do |opts|
	opts.banner = "Usage: tellus.rb [options]"
	opts.on('-u', '--username user', 'Username') do |user|
		options[:user] = user
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

# Login Information
tellusURL = "http://tellus.televilt.se/"

tellusLogin = options[:user] 
tellusPassword = options[:password]

# Download info 
downloadDir = options[:dir].gsub(/([^\/]$)/, '\1/') # append / if none
FileUtils::mkdir_p downloadDir unless File.exists?(downloadDir)

# Date Information
# Changed to reflect new cli options
dateNow = Date.today
periodMonths = 1
#dateStart = dateNow << periodMonths
dateStart = options[:beginDate]
dateEnd = options[:endDate]
# periodString = dateStart.strftime("%Y%m%d") + "-" + dateNow.strftime("%Y%m%d")
periodString = dateStart.strftime("%Y%m%d") + "-" + dateEnd.strftime("%Y%m%d")

# Initialize browsing agent
a = Mechanize.new
a.pluggable_parser.csv = Mechanize::Download

# Login

puts "loading URL: " + tellusURL

a.get(tellusURL)
loginForm = a.page.form
loginForm.field_with(:name => /user/).value = tellusLogin
loginForm.field_with(:name => /pass/).value= tellusPassword
loginForm.field_with(:name => /duration/).value= 480
loginButton = loginForm.button_with(:name => /login/)

puts "logging in as " + tellusLogin

a.submit(loginForm, loginButton)



# Get download links
pageLinks = a.page.links_with(:text => /Position/)
dataPage = pageLinks.first.click
pageLinks += dataPage.links_with(:href => /page=\d$/)

# Loop over download pages, start with current page
pageLinks.each do |pageLink|
	dataPage = pageLink.click
	# Download data for each collar for appropriate dates
	collarLinks = dataPage.links_with(:text => "Download Data")
	collarLinks.each do |collarLink|
		
		puts "downlaoding data from " + collarLink.pretty_inspect

		collarPage = collarLink.click
		downloadForm = collarPage.forms[1]
		downloadButton = downloadForm.button_with(:name => /download/)
		downloadForm.field_with(:name => /start_year/).value = dateStart.year
		downloadForm.field_with(:name => /start_month/).value = dateStart.month
		downloadForm.field_with(:name => /start_day/).value = dateStart.day
		downloadForm.field_with(:name => /end_year/).value = dateEnd.year
		downloadForm.field_with(:name => /end_month/).value = dateEnd.month
		downloadForm.field_with(:name => /end_day/).value = dateEnd.day
		r = a.submit(downloadForm, downloadButton)
		unless r.body.match(/(.*)No data.+/) then
			outputCSV = downloadDir + r.filename
			collarName = r.filename.scan(/[^_]+/).first
			2.times { r.body.sub!(/.*\n/,'') } 		# remove first 2 lines of csv content
			r.body.sub!(/^/,"Collar\t") 			# add a Collar column 
			#r.save(outputCSV)
			temp = Tempfile.new("csv")
			CSV.open(temp, "w", :col_sep => "\t") do |temp_csv|
				CSV.parse(r.body.match(/^.*\n/).to_s, :col_sep => "\t") do |orig|
					temp_csv << orig
				end
				CSV.parse(r.body.sub(/.*\n/,''), :col_sep => "\t") do |orig|
					temp_csv << [collarName] + orig.to_a
				end
			end
			
			puts "saving file as" + outputCSV
			FileUtils.mv(temp, outputCSV, :force => true)
		end
	end
end

# Logout
dataPage.link_with(:text => "Log out").click



	

