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



#  ugh???

# class Mechanize::HTTP::Agent
  # MAX_RESET_RETRIES = 10

  # # We need to replace the core Mechanize HTTP method:
  # #
  # #   Mechanize::HTTP::Agent#fetch
  # #
  # # with a wrapper that handles the infamous "too many connection resets"
  # # Mechanize bug that is described here:
  # #
  # #   https://github.com/sparklemotion/mechanize/issues/123
  # #
  # # The wrapper shuts down the persistent HTTP connection when it fails with
  # # this error, and simply tries again. In practice, this only ever needs to
  # # be retried once, but I am going to let it retry a few times
  # # (MAX_RESET_RETRIES), just in case.
  # #
  # def fetch_with_retry(
    # uri,
    # method    = :get,
    # headers   = {},
    # params    = [],
    # referer   = current_page,
    # redirects = 0
  # )
    # action      = "#{method.to_s.upcase} #{uri.to_s}"
    # retry_count = 0

    # begin
      # fetch_without_retry(uri, method, headers, params, referer, redirects)
    # rescue Net::HTTP::Persistent::Error => e
      # # Pass on any other type of error.
      # raise unless e.message =~ /too many connection resets/

      # # Pass on the error if we've tried too many times.
      # if retry_count >= MAX_RESET_RETRIES
        # puts "**** WARN: Mechanize retried connection reset #{MAX_RESET_RETRIES} times and never succeeded: #{action}"
        # raise
      # end

      # # Otherwise, shutdown the persistent HTTP connection and try again.
      # puts "**** WARN: Mechanize retrying connection reset error: #{action}"
      # retry_count += 1
      # self.http.shutdown
      # retry
    # end
  # end

  # # Alias so #fetch actually uses our new #fetch_with_retry to wrap the
  # # old one aliased as #fetch_without_retry.
  # alias_method :fetch_without_retry, :fetch
  # alias_method :fetch, :fetch_with_retry
# end


############################################



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
	
	opts.on("-v", "--[no-]verbose", "Run verbosely") do |v| 
		options[:verbose] = v
		puts "Verbose output ON ..."
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
	loginForm.fields.each { |f| puts f.name + ": " + f.value}
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


if options[:verbose] 
	puts "Logged on." 
end


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


