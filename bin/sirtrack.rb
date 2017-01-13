#!/usr/bin/env ruby

require 'os'
require 'certified' if OS.windows?
require 'fileutils'
require 'mechanize'
require 'optparse'

# Command Line Options
ARGV.push('-h') if ARGV.empty?		# show help if no arguments

options = {:user => nil, 
		   :password => nil, 
		   :dir => "data/",
		   :csv => nil, 
		   :csv_filename => nil,
}
parser = OptionParser.new do |opts|
	opts.banner = "Usage: sirtrack.rb [options]"
	
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



home_url = "https://data.sirtrack.com/"
login_url = "https://data.sirtrack.com/json-rpc"
projects_url = "https://data.sirtrack.com/restlet/projects"

user = options[:user]
password = options[:password]
download_dir = options[:dir].gsub(/([^\/]$)/, '\1/') # append / if none
output_file = options[:csv_filename]
FileUtils::mkdir_p download_dir unless File.exists?(download_dir)

login_body = "{id:2,method:\"loginFrontService.login\",params:[\"#{user}\", \"#{password}\"]}"
date_str = Time.new.strftime("%Y%m%d")

agent = Mechanize::new
agent.pluggable_parser.csv = Mechanize::Download

agent.get(home_url)
agent.post(login_url, login_body)
agent.get(projects_url)
projects = JSON.parse agent.page.body
projects.each do |project|
  name = project['name'].to_s
  id = project['id'].to_s
  csv_url = "https://data.sirtrack.com/serve/project/#{id}/#{name}.csv"
  csv_name = "sirtrack_" + id + "_" + date_str + ".csv"
  output_file = download_dir + csv_name
  agent.get(csv_url).save(output_file)
end



