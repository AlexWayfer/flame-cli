# frozen_string_literal: true

tool :check do
	desc 'Check static files'

	GREP_OPTIONS = '--exclude-dir={\.git,log,node_modules,extra} --color=always'

	def run
		Dir[File.join(ROOT_DIR, 'public', '**', '*')].each do |file|
			next if File.directory? file

			basename = File.basename(file)

			puts "Looking for #{basename}..."

			found = `grep -ir '#{basename}' #{ROOT_DIR} #{GREP_OPTIONS}`

			next unless found.empty? && File.dirname(file) != @skipping_dir

			ask_question file
		end
	end

	private

	def ask_question(file)
		filename = file.sub(ROOT_DIR, '')
		case Question.new("Delete #{filename} ?", %w[yes no skip]).answer
		when 'yes'
			`git rm #{file.gsub(' ', '\ ')}`
		when 'skip'
			@skipping_dir = File.dirname(file)
		end
	end
end
