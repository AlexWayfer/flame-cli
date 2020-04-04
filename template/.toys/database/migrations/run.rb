# frozen_string_literal: true

desc 'Run migrations'

flag :target, '-t', '--target=VERSION'
flag :current, '-c', '--current=VERSION', default: 'current'
flag :force, '-f', '--force', desc: 'Allow missing migration files'

def run
	exec_tool 'db:dump' unless ENV['SKIP_DB_DUMP']

	## https://github.com/jeremyevans/sequel/issues/1182#issuecomment-217696754
	require 'sequel'
	%i[migration inflector].each { |extension| Sequel.extension extension }

	require_application_config

	Sequel::Migrator.run db_connection, DB_MIGRATIONS_DIR, options
end

private

def options
	result = { allow_missing_migration_files: force }

	return result.merge! target_options if target

	puts 'Migrating to latest'
	result
end

def target_options
	target_version =
		if target == '0'
			puts 'Migrating all the way down'
			target
		else
			find_target_file_version
		end

	{ current: current.to_i, target: target_version.to_i }
end

def find_target_file_version
	file = MigrationFile.find target, disabled: false

	abort 'Migration with this version not found' if file.nil?

	puts "Migrating from #{current} to #{file.basename}"
	file.version
end
