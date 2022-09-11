# frozen_string_literal: true

require 'pry-byebug'

require 'simplecov'

## TODO: Update to a new uploader
if ENV['CODECOV_TOKEN']
	require 'codecov'
	SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

SimpleCov.start

FLAME_CLI = File.join(__dir__, '../exe/flame').freeze

RSpec.configure do |config|
	config.example_status_persistence_file_path = "#{__dir__}/examples.txt"
end

RSpec::Matchers.define :include_lines do |expected_lines|
	match do |actual_text|
		expected_lines.all? do |expected_line|
			actual_text.lines.any? do |actual_line|
				actual_line.strip == expected_line.strip
			end
		end
	end

	diffable
end

RSpec::Matchers.define :match_lines do |expected_matches|
	match do |actual_text|
		expected_matches.all? do |expected_match|
			actual_text.lines.any? do |actual_line|
				actual_line.match? expected_match
			end
		end
	end

	diffable
end
