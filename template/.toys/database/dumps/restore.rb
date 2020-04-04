# frozen_string_literal: true

desc 'Restore DB dump'

optional_arg :step, accept: Integer, default: -1

def run
	update_pgpass

	@dump_file = DumpFile.all[step]

	abort 'Dump file not found' unless @dump_file

	if Question.new("Restore #{@dump_file} ?", %w[yes no]).answer == 'no'
		abort 'Okay'
	end

	drop_if_exists

	exec_tool 'db:create'

	restore
end

private

def drop_if_exists
	return unless sh(
		"psql #{db_access} -l | grep '^\s#{db_config[:database]}\s'"
	)

	exec_tool 'db:dump'
	exec_tool 'db:drop'
end

def restore
	case @dump_file.format
	when 'custom'
		pg_restore
	when 'plain'
		sh "psql #{db_access}" \
		   " #{db_config[:database]} < #{@dump_file.path}"
	else
		raise 'Unknown DB dump file format'
	end
end

def pg_restore
	sh "pg_restore #{db_access} -n public" \
	   " -d #{db_config[:database]} #{@dump_file.path}" \
	   ' --jobs=4 --clean --if-exists'
end
