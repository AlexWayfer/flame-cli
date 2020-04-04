# frozen_string_literal: true

desc 'Change version of migration to latest'

required_arg :filename

def run
	file = MigrationFile.find filename
	file.reversion
end
