# frozen_string_literal: true

desc 'Upload files for translation'

optional_arg :branch

def run
	crowdin 'upload sources', branch
end
