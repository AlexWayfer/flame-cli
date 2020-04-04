# frozen_string_literal: true

desc 'Create empty DB'

def run
	sh "createdb -U postgres #{db_config[:database]}" \
	   " -O #{db_config[:user]}"
	DB_EXTENSIONS.each do |db_extension|
		sh "psql -U postgres -c 'CREATE EXTENSION #{db_extension}'" \
			 " #{db_config[:database]}"
	end
end
