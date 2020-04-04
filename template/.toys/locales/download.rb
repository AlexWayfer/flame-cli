# frozen_string_literal: true

desc 'Download files for translation'

optional_arg :branch

def run
	crowdin 'download translations', branch
end
