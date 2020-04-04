# frozen_string_literal: true

desc 'Show all migrations'

def run
	files = MigrationFile.find '*', only_one: false
	files.each(&:print)
end
