# frozen_string_literal: true

desc 'Benchmark code'

def run
	ExampleFile.new("#{ROOT_DIR}/benchmark/main.example.rb")
		.actualize_regular_file

	sh 'ruby benchmark/main.rb'
end
