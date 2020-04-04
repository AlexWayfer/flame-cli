# frozen_string_literal: true

desc 'Enable migration'

required_arg :filename

def run
	file = MigrationFile.find filename
	file.enable
end
