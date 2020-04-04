# frozen_string_literal: true

require 'diffy'
require 'paint'

## Class for example file
class ExampleFile
	SUFFIX = '.example'

	class << self
		def all(directory)
			Dir[File.join(directory, '**', "*#{SUFFIX}*")]
				.map { |file_name| new file_name }
		end
	end

	def initialize(file_name)
		@file_name = file_name
		@regular_file_name = @file_name.sub SUFFIX, ''

		@example_basename =
			Paint[File.basename(@file_name), :green, :bold]
		@regular_basename =
			Paint[File.basename(@regular_file_name), :red, :bold]
	end

	def actualize_regular_file
		return create_regular_file unless regular_file_exist?

		return unless new?

		return update_regular_file if diff.chomp.empty?

		ask_question_and_get_answer
	end

	private

	def new?
		File.mtime(@file_name) > File.mtime(@regular_file_name)
	end

	def regular_file_exist?
		File.exist? @regular_file_name
	end

	def create_regular_file
		FileUtils.cp @file_name, @regular_file_name
		edit_file @regular_file_name
	end

	def update_regular_file
		FileUtils.touch @regular_file_name
	end

	def diff
		@diff ||= Diffy::Diff
			.new(@regular_file_name, @file_name, source: 'files', context: 3)
			.to_s(:color)
	end

	def ask_question_and_get_answer
		case answer = ask_question.answer
		when 'yes'
			edit_file @regular_file_name
		when 'replace'
			rewrite_regular_file
		when 'no'
			update_regular_file
			puts 'File modified time updated'
		end

		answer
	end

	def ask_question
		puts <<~WARN
			#{@basename} was modified after #{@regular_basename}.

			```diff
			#{diff}
			```

		WARN

		Question.new(
			"Do you want to edit #{@regular_basename} ?", %w[yes replace no]
		)
	end

	def edit_file(filename)
		system "eval $EDITOR #{filename}"
	end

	def rewrite_regular_file
		File.write @regular_file_name, File.read(@file_name)
	end
end
