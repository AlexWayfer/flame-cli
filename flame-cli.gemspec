# frozen_string_literal: true

Gem::Specification.new do |spec|
	spec.name        = 'flame-cli'
	spec.version     = '0.0.0'

	spec.summary     = 'CLI for Flame web framework'
	spec.description = 'Generate new application and maybe something else.'

	spec.authors     = ['Alexander Popov']
	spec.email       = ['alex.wayfer@gmail.com']
	spec.homepage    = 'https://github.com/AlexWayfer/flame-cli'
	spec.license     = 'MIT'

	spec.metadata = {
		'bug_tracker_uri' => 'https://github.com/AlexWayfer/flame-cli/issues',
		'documentation_uri' =>
			"http://www.rubydoc.info/gems/flame-cli/#{spec.version}",
		'homepage_uri' => 'https://github.com/AlexWayfer/flame-cli',
		'source_code_uri' => 'https://github.com/AlexWayfer/flame-cli',
		'wiki_uri' => 'https://github.com/AlexWayfer/flame-cli/wiki'
	}

	spec.required_ruby_version = '~> 2.6'

	spec.add_runtime_dependency 'clamp', '~> 1.3'
	spec.add_runtime_dependency 'gorilla_patch', '~> 4.0'

	spec.add_development_dependency 'pry-byebug', '~> 3.9'

	spec.add_development_dependency 'bundler', '~> 2.0'
	spec.add_development_dependency 'gem_toys', '~> 0.5.0'
	spec.add_development_dependency 'toys', '~> 0.11.0'

	spec.add_development_dependency 'bundler-audit', '~> 0.7.0'

	spec.add_development_dependency 'codecov', '~> 0.2.0'
	spec.add_development_dependency 'rspec', '~> 3.9'
	spec.add_development_dependency 'simplecov', '~> 0.20.0'

	spec.add_development_dependency 'example_file', '~> 0.2.0'
	spec.add_development_dependency 'rubocop', '~> 1.0'
	spec.add_development_dependency 'rubocop-performance', '~> 1.0'
	spec.add_development_dependency 'rubocop-rspec', '~> 2.0'

	spec.files = Dir.glob('{lib,template}/**/*', File::FNM_DOTMATCH)
	spec.bindir = 'exe'
	spec.executables = ['flame']
end
