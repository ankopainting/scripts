#!/usr/local/bin/ruby
#
# Webdav put
# puts a file on a server via webdav
#
# (c) 2008 Anko Painting

require 'digest/md5'
require 'net/http'
require 'time'

PATH = '/path/list.csv'
WEBDAV_BASE = '/paththere/'
USERNAME = 'test'
PASSWORD = 'test'

def abort(string)
	STDERR.puts string
	exit(-1)
end

def webdav_get_date_modified(remote_server, remote_path, required_days_ago = 2, username = USERNAME, password =PASSWORD)
# check remote server protocol is specified
	if remote_server !~ %r!^http://!
		remote_server = 'http://' + remote_server
	end

	url = URI.parse(remote_server)

	res = false	
	Net::HTTP.start(url.host) do |http|
    req = Net::HTTP::Propfind.new(remote_path)
#		req = Net::HTTP::Put.new(remote_path)
#		req = Net::HTTP::Put.new("#{WEBDAV_BASE}#{File.basename(ARGV[2])}")
		req.basic_auth(username, password)
		response = http.request(req)
    if response.code.to_i == 207
      date_modified_str = response.body.match(/lp1:getlastmodified>(.+)</)[1]
      date_now = Time.now
      date_modified = Time.parse(date_modified_str)

#      puts response.body
#      puts "---"
#      puts date_modified
#      puts "---"
#      puts date_now
#      puts date_modified

      days_ago = ((date_now - date_modified).to_i / 60/60/24)

      if days_ago > required_days_ago
        puts "#{remote_path} was last updated #{days_ago} days ago on #{date_modified}."
      end
    end
#lp1:getlastmodified
#    puts req
#		puts response.code + " " + response.message
#		res = response
#    puts response
	end

#	if res.code.to_i >= 200 and res.code.to_i < 300
#		res.message
#	else
#		false
#	end
  
end

def webdav_push(local_path, remote_server, remote_path, username = USERNAME, password = PASSWORD)
# Check if local file exists
	if !File.exists?(local_path)
		throw "FileDoesNotExist"
	end

# check remote server protocol is specified
	if remote_server !~ %r!^http://!
		remote_server = 'http://' + remote_server
	end

	url = URI.parse(remote_server)

	res = false	
	Net::HTTP.start(url.host) do |http|
		req = Net::HTTP::Put.new(remote_path)
#		req = Net::HTTP::Put.new("#{WEBDAV_BASE}#{File.basename(ARGV[2])}")
		req.basic_auth(username, password)
		response = http.request(req, File.read(local_path))
		puts response.code + " " + response.message
		res = response
	end

	if res.code.to_i >= 200 and res.code.to_i < 300
		res.message
	else
		false
	end
end

days_ago = ARGV.first.to_i
if days_ago > 0
  webdav_get_date_modified('http://webdav', PATH, days_ago)
else
  webdav_get_date_modified('http://webdav', PATH)
end

