# frozen_string_literal: true

def create_migration_file(name, content = nil)
	file = MigrationFile.new name: name, content: content

	file.generate
end
