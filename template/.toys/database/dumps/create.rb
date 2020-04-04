# frozen_string_literal: true

desc 'Make DB dump'

flag :format, '-f', '--format=VALUE',
	default: DumpFile::DB_DUMP_FORMATS.first,
	handler: (lambda do |value, _previous|
		DumpFile::DB_DUMP_FORMATS.find do |db_dump_format|
			db_dump_format.start_with? value
		end
	end)

def run
	require 'benchmark'

	update_pgpass

	sh "mkdir -p #{DB_DUMPS_DIR}"
	time = Benchmark.realtime do
		sh "pg_dump #{db_access} -F#{format.chr}" \
		   " #{db_config[:database]} > #{filename}"
	end
	puts "Done in #{time.round(2)} s."
end

private

def filename
	DumpFile.new(format: format).path
end
