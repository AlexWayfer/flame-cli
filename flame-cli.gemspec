# frozen_string_literal: true

Gem::Specification.new do |s|
	s.name        = 'flame-cli'
	s.version     = '0.0.0'

	s.summary     = 'CLI for Flame Web-framework'
	s.description = 'Generate new application and maybe something else.'

	s.authors     = ['Alexander Popov']
	s.email       = ['alex.wayfer@gmail.com']
	s.homepage    = 'https://github.com/AlexWayfer/flame-cli'
	s.license     = 'MIT'

	s.metadata = {
		'bug_tracker_uri' => 'https://github.com/AlexWayfer/flame-cli/issues',
		'documentation_uri' =>
			"http://www.rubydoc.info/gems/flame-cli/#{s.version}",
		'homepage_uri' => 'https://github.com/AlexWayfer/flame-cli',
		'source_code_uri' => 'https://github.com/AlexWayfer/flame-cli',
		'wiki_uri' => 'https://github.com/AlexWayfer/flame-cli/wiki'
	}

	s.required_ruby_version = '>= 2.6'

	s.add_runtime_dependency 'clamp', '~> 1.3'
	s.add_runtime_dependency 'gorilla_patch', '~> 4.0'

	s.add_development_dependency 'bundler', '~> 2.1'
	s.add_development_dependency 'codecov', '~> 0.1'
	s.add_development_dependency 'pry', '~> 0.12'
	s.add_development_dependency 'pry-byebug', '~> 3.5'
	s.add_development_dependency 'rake', '~> 13.0'
	s.add_development_dependency 'rspec', '~> 3.7'
	s.add_development_dependency 'rubocop', '~> 0.81.0'
	s.add_development_dependency 'rubocop-performance', '~> 1.5'
	s.add_development_dependency 'rubocop-rspec', '~> 1.38'
	s.add_development_dependency 'simplecov', '~> 0.16'

	s.files = Dir.glob('{lib,template}/**/*', File::FNM_DOTMATCH)
	s.bindir = 'exe'
	s.executables = ['flame']
end
