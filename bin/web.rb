#!/usr/local/bin/ruby
require 'webrick'
srv = WEBrick::HTTPServer.new({ :DocumentRoot => '/jails/data/',
	:BindAddess => '*',
	:Port => 3333})
trap("INT"){srv.shutdown}
srv.start
