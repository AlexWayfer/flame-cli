# frozen_string_literal: true

desc 'Start interactive console'

optional_arg :environment, default: 'development'

def run
	require 'rack/console'

	ARGV.clear
	ENV['RACK_CONSOLE'] = 'true'
	Rack::Console.new(environment: environment).start
end
