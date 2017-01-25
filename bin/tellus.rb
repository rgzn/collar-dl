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

# Use bundled environment:
require 'bundler/setup'

# Windows has special needs:
require 'os' 
require 'certified' if OS.windows?

require 'mechanize'
require 'open-uri'
require 'optparse'
require 'optparse/date'
require 'csv'
require 'fileutils'
require 'tempfile'


############################################
CSV_DELIM = '\t'

def catCSV(inputFiles, outputFile)
	if inputFiles.empty? then exit end
	header = IO.readlines(inputFiles.first)[0]
	File.open(outputFile, 'w') do |f|
		f << header
	end
	inputFiles.each do |file|
		content = IO.readlines(file)[1..-1]
		File.open(outputFile, 'a') do |f|
			content.each {|line| f << line}
		end
	end
end


# Command Line Options
ARGV.push('-h') if ARGV.empty?		# show help if no arguments

options = {:user => nil, 
		   :password => nil, 
		   :dir => "data/tellus/",
		   :beginDate => Date.today,
		   :endDate => Date.today,
		   :csv => nil, 
		   :csv_filename => nil,
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
	opts.on("-v", "--[no-]verbose", "Run verbosely") do |v| 
		options[:verbose] = v
		puts "Verbose output ON ..."
	end
	opts.on("-x", "--csv [CSV_FILENAME]", 
			"Translate to single CSV/TXT", 
			" (using filename if supplied)") do |csv_arg|
		options[:csv] = true
		options[:csv_filename] = csv_arg || nil
	end
	opts.on("-z", "--debug", "Run in debug mode") do |z|
		options[:debug] = TRUE
		require 'pry'
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
a.user_agent_alias = 'Mac Firefox'
# a.keep_alive = true
# a.ignore_bad_chunking = true
# a.open_timeout = 25
# a.read_timeout = 25
# a.agent.http.retry_change_requests = true
a.pluggable_parser.csv = Mechanize::Download

# Login

if options[:verbose] 
	puts "Loading page: " + tellusURL
end


a.get(tellusURL)
loginForm = a.page.form
loginForm.field_with(:name => /user/).value = tellusLogin
loginForm.field_with(:name => /pass/).value= tellusPassword
loginForm.field_with(:name => /duration/).value= 480
loginButton = loginForm.button_with(:name => /login/)

if options[:verbose] 
	puts "Logging on with credentials: " 
	loginForm.fields.each { |f| puts f.name.to_s + ": " + f.value.to_s}
end
 
loginPage = a.page
# a.agent.http.tap { |http|
   # http.reset http.connection_for(loginPage.uri + loginForm.action)
# }

begin
	a.submit(loginForm, loginButton)
rescue
	a.submit(loginForm, loginButton)
end

if a.page.link_with(:text => /log out/i).nil?
	if options[:verbose]
		puts "Failed to log in with specified credentials"
		puts "Exiting program"
	end
	exit
else
	if options[:verbose]
		puts "Login successful."
	end
end


# Get download links
pageLinks = a.page.links_with(:text => /Position/)

if pageLinks.empty? 
	if options[:verbose]
		puts "Failed to find position data page"
		puts "Exiting program"
	end
	exit
else
	dataPage = pageLinks.first.click
	pageLinks += dataPage.links_with(:href => /page=\d$/)
end

downloadedFiles = []
# Loop over download pages, start with current page
pageLinks.each do |pageLink|
	dataPage = pageLink.click
	# Download data for each collar for appropriate dates
	collarLinks = dataPage.links_with(:text => "Download Data")
	collarLinks.each do |collarLink|
		
		# if options[:verbose]
			# puts "downloading data from:  " + tellusURL + collarLink.href.to_s
		# end

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
			
			if options[:verbose] 
				puts "Downloading #{collarName} data to file: #{outputCSV}"
			end
			
			#binding.pry
			
			FileUtils.copy(temp, outputCSV)
			downloadedFiles.push(outputCSV)
			temp.close
			temp.unlink
		else
			puts r.body if options[:verbose]
		end

	end
end


# Logout
if options[:verbose]
	puts "Finished with downloads"
	puts "Logging out..."
end

dataPage.link_with(:text => "Log out").click

if options[:csv] && downloadedFiles.any?
	if options[:verbose] 
		puts "Converting files to single CSV..."
	end
	#binding.pry
	if options[:csv_filename]
		csvFileName = options[:csv_filename]
	elsif options[:csv]
		csvFileName = tellusLogin + "_" + 
			dateStart.strftime("%Y%m%d") + "-" + 
			dateEnd.strftime("%Y%m%d") + ".txt"
	end
	catCSV(downloadedFiles, downloadDir + csvFileName)	
	if options[:verbose] 
		puts "The following files were combined and saved as text in " + 
			downloadDir + csvFileName + " :"
		puts downloadedFiles
	end
  puts "Data downloaded and saved as: " + downloadDir + csvFileName
end


