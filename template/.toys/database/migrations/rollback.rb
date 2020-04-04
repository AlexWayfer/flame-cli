# frozen_string_literal: true

desc 'Rollback the database N steps'

optional_arg :step, accept: Integer, default: 1

def run
	exec_tool 'db:dump'

	file = MigrationFile.find('*', only_one: false)[-1 - step.abs]

	## https://github.com/dazuma/toys/issues/33
	exec_tool ['db:migrations:run', "--target=#{file.version}"]

	puts "Rolled back to #{file.basename}"
end
