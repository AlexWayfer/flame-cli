# frozen_string_literal: true

desc 'Lint locales files'

def run
	require 'yaml'

	Dir["#{ROOT_DIR}/locales/*.y{a,}ml"].each do |locale_file|
		## `YAML.safe_load` doesn't work with anchors
		# rubocop:disable Security/YAMLLoad
		next if locale_file.end_with?('zh-CN.yml')

		locale = YAML.load File.read locale_file
		# rubocop:enable Security/YAMLLoad
		errors = %w[notice warning error].reduce([]) do |result, type|
			result.concat deep_lint_periods locale[type]
		end
		errors.map! { |error| "* `#{error}`" }
		raise "There is no period in:\n#{errors.join("\n")}" if errors.any?
	end
end

private

def deep_lint_periods(value, errors = [])
	if value.is_a?(Hash)
		value.each_value { |nested_value| send __method__, nested_value, errors }
	else
		errors << value unless value.end_with?('.') # chinese dot for Chinese
	end
	errors
end
