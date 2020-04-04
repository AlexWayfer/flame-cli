# frozen_string_literal: true

desc 'Create regular migration'

required_arg :name

def run
	create_migration_file name
end
