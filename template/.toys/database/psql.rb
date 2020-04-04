# frozen_string_literal: true

desc 'Start psql'

def run
	update_pgpass
	sh "psql #{db_access} #{db_config[:database]}"
end
