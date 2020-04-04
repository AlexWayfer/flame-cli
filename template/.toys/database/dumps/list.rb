# frozen_string_literal: true

desc 'List DB dumps'

def run
	DumpFile.all.each(&:print)
end
