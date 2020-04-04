# frozen_string_literal: true

desc 'Disable migration'

required_arg :filename

def run
	file = MigrationFile.find filename
	file.disable
end
