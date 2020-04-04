# frozen_string_literal: true

desc 'Drop DB'

flag :force, '-f', '--[no-]force'
flag :question, '-q', '--[no-]question', default: true

def run
	if question
		if Question.new(
			"Drop #{db_config[:database]} ?", %w[yes no]
		).answer == 'no'
			abort 'OK'
		end
	end

	exec_tool 'db:dump' unless force

	db_connection.disconnect
	sh "dropdb --if-exists #{db_access} #{db_config[:database]}"
end
