# frozen_string_literal: true

require 'pathname'
require 'net/http'

describe 'Flame::CLI::New::App' do
	subject(:execute_command) do
		Bundler.with_original_env { `#{FLAME_CLI} new app #{app_name}` }
	end

	let(:app_name) { 'foo_bar' }

	let(:root_dir) { "#{__dir__}/../../../.." }
	let(:template_dir) { "#{root_dir}/template" }
	let(:template_dir_pathname) { Pathname.new(template_dir) }
	let(:template_ext) { '.erb' }

	after do
		FileUtils.rm_r "#{root_dir}/#{app_name}"
	end

	describe 'output' do
		let(:expected_words) do
			[
				"Creating '#{app_name}' directory...",
				'Copy template directories and files...',
				'Clean directories...',
				'Replace module names in template...',
				'- config.ru',
				'- constants.rb',
				'- application.rb',
				'- controllers/_controller.rb',
				'- controllers/site/_controller.rb',
				'- controllers/site/index_controller.rb',
				'- routes.rb',
				'- views/site/index.html.erb',
				'- views/site/layout.html.erb',
				'- rollup.config.js',
				'- config/config.rb',
				'- config/site.example.yaml',
				'- config/processors/logger.rb',
				'- config/processors/sequel.rb.bak',
				'Grant permissions to files...',
				'Done!'
			]
		end

		it { is_expected.to match_words(*expected_words) }
	end

	describe 'creates root directory with received app name' do
		subject { Dir.exist?(app_name) }

		before { execute_command }

		it { is_expected.to be true }
	end

	describe 'copies template directories and files into app root directory' do
		subject { File }

		before { execute_command }

		let(:files) do
			Dir.glob(File.join(template_dir, '**/*'), File::FNM_DOTMATCH)
				.map do |filename|
					filename_pathname = Pathname.new(filename)
						.relative_path_from(template_dir_pathname)

					next if filename_pathname.basename.to_s == '.keep'

					if filename_pathname.extname == template_ext
						filename_pathname = filename_pathname.sub_ext('')
					end

					File.join app_name, filename_pathname
				end
				.compact
		end

		it { files.each { |file| is_expected.to exist file } }
	end

	describe 'cleans directories' do
		subject { Dir.glob("#{app_name}/**/.keep", File::FNM_DOTMATCH) }

		before { execute_command }

		it { is_expected.to be_empty }
	end

	describe 'renders app name in files' do
		subject { File.read File.join(app_name, *path_parts) }

		let(:path_parts) { self.class.description.split('/') }

		before { execute_command }

		describe '.toys/config/check.rb' do
			let(:expected_words) do
				[
					'ExampleFile.all(FB::Application.config[:config_dir])'
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe '.toys/database/.preload.rb' do
			let(:expected_words) do
				[
					'@db_config = FB::Application.config[:database]',
					'@db_connection = FB::Application.db_connection'
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe '.toys/generate/form/template.rb.erb' do
			let(:expected_words) do
				[
					'module FooBar'
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe '.toys/generate/model/template.rb.erb' do
			let(:expected_words) do
				[
					'module FooBar'
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe '.toys/routes.rb' do
			let(:expected_words) do
				[
					'puts FB::Application.router.routes'
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'application.rb' do
			let(:expected_words) do
				[
					'module FooBar'
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'config.ru' do
			let(:expected_words) do
				[
					'FB::Application.require_dirs FB::APP_DIRS',
					'if FB::Application.config[:session]',
					'use Rack::Session::Cookie, ' \
						'FB::Application.config[:session][:cookie]',
					'use Rack::CommonLogger, FB::Application.logger',
					'run FB::Application'
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'config/config.rb' do
			let(:expected_words) do
				[
					'FB::Application.config.instance_exec do',
					'FB::ConfigProcessors.const_get(processor_name).new self'
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'config/processors/logger.rb' do
			let(:expected_words) do
				[
					'module FooBar'
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'config/processors/sequel.rb.bak' do
			let(:expected_words) do
				[
					'module FooBar',
					'FB::Application.db_connection.extension extension_name',
					'FB::Application.db_connection.loggers << FB::Application.logger',
					"FB::Application.db_connection.freeze unless ENV['RACK_CONSOLE']"
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'constants.rb' do
			let(:expected_words) do
				[
					'module FooBar',
					'::FB = ::FooBar',
					'APP_DIRS ='
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'controllers/_controller.rb' do
			let(:expected_words) do
				[
					'module FooBar',
					'FB::Application.logger'
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'controllers/site/_controller.rb' do
			let(:expected_words) do
				[
					'module FooBar',
					'class Controller < FB::Controller'
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'controllers/site/index_controller.rb' do
			let(:expected_words) do
				[
					'module FooBar',
					'class IndexController < FB::Site::Controller'
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'README.md' do
			let(:expected_words) do
				[
					'# FooBar',
					'`createuser -U postgres foo_bar`',
					'`createdb -U postgres foo_bar -O foo_bar`',
					'`psql -U postgres -c "CREATE EXTENSION citext" foo_bar`',
					'Add UNIX-user for project: `adduser foo_bar`',
					'Make symbolic link of project directory to `/var/www/foo_bar`'
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'rollup.config.js' do
			let(:expected_words) do
				[
					"name: 'FB'"
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'routes.rb' do
			let(:expected_words) do
				[
					'FB::Application.class_exec do'
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'views/site/layout.html.erb' do
			let(:expected_words) do
				[
					'<title><%= FB::Application.config[:site][:site_name] %></title>'
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end
	end

	describe 'generates RuboCop-satisfying app' do
		subject do
			Bundler.with_original_env do
				system 'bundle exec rubocop'
			end
		end

		before do
			Bundler.with_original_env do
				execute_command

				Dir.chdir app_name

				system 'bundle install'
			end
		end

		after do
			Dir.chdir '..'
		end

		it { is_expected.to be true }
	end

	describe 'generates working app' do
		subject do
			Bundler.with_original_env do
				pid = spawn './server start'

				Process.detach pid

				sleep 0.1

				number_of_attempts = 0

				begin
					number_of_attempts += 1
					## https://github.com/gruntjs/grunt-contrib-connect/issues/25#issuecomment-16293494
					response = Net::HTTP.get URI("http://127.0.0.1:#{port}/")
				rescue Errno::ECONNREFUSED => e
					sleep 1
					retry if number_of_attempts < 10
					raise e
				end

				response
			ensure
				Bundler.with_original_env { `./server stop` }
				Process.wait pid
			end
		end

		before do
			Bundler.with_original_env do
				ENV['RACK_ENV'] = 'development'

				execute_command

				Dir.chdir app_name

				%w[server session site].each do |config|
					FileUtils.cp(
						"config/#{config}.example.yaml", "config/#{config}.yaml"
					)
				end

				## HACK for testing while some server is running
				File.write(
					'config/server.yaml',
					File.read('config/server.yaml').sub('port: 3000', "port: #{port}")
				)

				system 'bundle install'
			end
		end

		after do
			Dir.chdir '..'
		end

		let(:port) do
			## https://stackoverflow.com/a/5985984/2630849
			socket = Socket.new(:INET, :STREAM, 0)
			socket.bind Addrinfo.tcp('127.0.0.1', 0)
			result = socket.local_address.ip_port
			socket.close
			result
		end

		let(:expected_response) do
			<<~RESPONSE
				<!DOCTYPE html>
				<html>
					<head>
						<meta charset="utf-8" />
						<title>FooBar</title>
					</head>
					<body>
						<h1>Hello, world!</h1>

					</body>
				</html>
			RESPONSE
		end

		it { is_expected.to eq expected_response }
	end

	describe 'grants `./server` file execution permissions' do
		subject { File.stat('server').mode.to_s(8)[3..5] }

		before do
			execute_command

			Dir.chdir app_name
		end

		after do
			Dir.chdir '..'
		end

		it { is_expected.to eq '744' }
	end
end
