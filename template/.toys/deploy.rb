# frozen_string_literal: true

desc 'Deploy to production server'

long_desc <<~DESC
	Command for deploy code from git to server

	Example:
		Update from git master branch
			toys deploy
		Update from git development branch
			toys deploy development
DESC

optional_arg :branch, default: :master

def run
	require 'yaml'

	servers = YAML.load_file File.join(ROOT_DIR, 'config', 'deploy.yml')

	servers.each do |server|
		update_command = "cd #{server[:path]} && exe/update.sh #{branch}"
		sh "ssh -t #{server[:ssh]} 'bash --login -c \"#{update_command}\"'"
	end
end
