# frozen_string_literal: true

Gem::Specification.new do |spec|
	spec.name        = 'flame-cli'
	spec.version     = '0.0.0'

	spec.summary     = 'CLI for Flame web framework'
	spec.description = 'Generate new application and maybe something else.'

	spec.authors     = ['Alexander Popov']
	spec.email       = ['alex.wayfer@gmail.com']
	spec.license     = 'MIT'

	github_uri = "https://github.com/AlexWayfer/#{spec.name}"

	spec.homepage = github_uri

	spec.metadata = {
		'bug_tracker_uri' => "#{github_uri}/issues",
		'changelog_uri' => "#{github_uri}/blob/v#{spec.version}/CHANGELOG.md",
		'documentation_uri' => "http://www.rubydoc.info/gems/#{spec.name}/#{spec.version}",
		'homepage_uri' => spec.homepage,
		'rubygems_mfa_required' => 'true',
		'source_code_uri' => github_uri,
		'wiki_uri' => "#{github_uri}/wiki"
	}

	spec.required_ruby_version = '>= 2.6', '< 4'

	spec.add_runtime_dependency 'project_generator', '~> 0.2.0'

	spec.add_development_dependency 'pry-byebug', '~> 3.9'

	spec.add_development_dependency 'bundler', '~> 2.0'
	spec.add_development_dependency 'gem_toys', '~> 0.11.0'
	spec.add_development_dependency 'toys', '~> 0.13.0'

	spec.add_development_dependency 'bundler-audit', '~> 0.9.0'

	spec.add_development_dependency 'codecov', '~> 0.6.0'
	spec.add_development_dependency 'rspec', '~> 3.9'
	spec.add_development_dependency 'simplecov', '~> 0.21.2'

	spec.add_development_dependency 'example_file', '~> 0.3.0'
	spec.add_development_dependency 'rubocop', '~> 1.36.0'
	spec.add_development_dependency 'rubocop-performance', '~> 1.0'
	spec.add_development_dependency 'rubocop-rspec', '~> 2.0'

	spec.files = Dir.glob('{lib,template}/**/*', File::FNM_DOTMATCH)
	spec.bindir = 'exe'
	spec.executables = ['flame']
end
