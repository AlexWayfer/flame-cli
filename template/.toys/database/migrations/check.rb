# frozen_string_literal: true

desc 'Check applied migrations'

def run
	if MigrationFile.applied_not_existing.any?
		puts 'Applied, but not existing'
		MigrationFile.applied_not_existing.each(&:print)
		puts "\n" if MigrationFile.existing_not_applied.any?
	end

	return unless MigrationFile.existing_not_applied.any?

	puts 'Existing, but not applied'
	MigrationFile.existing_not_applied.each(&:print)
end
