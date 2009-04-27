#!/usr/local/bin/ruby
#
# Webdav put
# puts a file on a server via webdav
#
# (c) 2008 Anko painting

require 'digest/md5'
require 'net/http'

WEBDAV_BASE = '/whereitgoes/'
USERNAME = 'user'
PASSWORD = 'password'

def abort(string)
	STDERR.puts string
	exit -1
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

abort("Usage: #{$0} <path/to/file/to/upload>") unless ARGV.size==1

if File.exists?(ARGV[0])
	webdav_push(File.basename(ARGV[0]).to_s, "http://webdav", "#{WEBDAV_BASE}#{File.basename(ARGV[0])}")
else
	puts "No such file #{ARGV[0].inspect}" 
end


