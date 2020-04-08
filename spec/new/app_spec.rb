# frozen_string_literal: true

require 'pathname'
require 'net/http'

describe 'FlameCLI::New::App' do
	let(:app_name) { 'foo_bar' }

	subject(:execute_command) do
		Bundler.with_original_env { `#{FLAME_CLI} new app #{app_name}` }
	end

	let(:template_dir)          { File.join(__dir__, '../../template') }
	let(:template_dir_pathname) { Pathname.new(template_dir) }
	let(:template_ext)          { '.erb' }

	after do
		FileUtils.rm_r File.join(__dir__, '../..', app_name)
	end

	describe 'output' do
		it do
			is_expected.to match_words(
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
			)
		end
	end

	describe 'creates root directory with received app name' do
		subject { Dir.exist?(app_name) }

		before { execute_command }

		it { is_expected.to be true }
	end

	describe 'copies template directories and files into app root directory' do
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

		subject { File }

		it { files.each { |file| is_expected.to exist file } }
	end

	describe 'cleans directories' do
		before { execute_command }

		subject { Dir.glob("#{app_name}/**/.keep", File::FNM_DOTMATCH) }

		it { is_expected.to be_empty }
	end

	describe 'renders app name in files' do
		before { execute_command }

		subject { File.read File.join(app_name, *path_parts) }

		let(:path_parts) { self.class.description.split('/') }

		describe '.toys/config/check.rb' do
			it do
				is_expected.to match_words(
					'ExampleFile.all(FB::Application.config[:config_dir])'
				)
			end
		end

		describe '.toys/database/.preload.rb' do
			it do
				is_expected.to match_words(
					'@db_config = FB::Application.config[:database]',
					'@db_connection = FB::Application.db_connection'
				)
			end
		end

		describe '.toys/generate/form/template.rb.erb' do
			it do
				is_expected.to match_words(
					'module FooBar'
				)
			end
		end

		describe '.toys/generate/model/template.rb.erb' do
			it do
				is_expected.to match_words(
					'module FooBar'
				)
			end
		end

		describe '.toys/routes.rb' do
			it do
				is_expected.to match_words(
					'puts FB::Application.router.routes'
				)
			end
		end

		describe 'application.rb' do
			it do
				is_expected.to match_words(
					'module FooBar'
				)
			end
		end

		describe 'config.ru' do
			it do
				is_expected.to match_words(
					'FB::Application.require_dirs FB::APP_DIRS',
					'if FB::Application.config[:session]',
					'use Rack::Session::Cookie, ' \
						'FB::Application.config[:session][:cookie]',
					'use Rack::CommonLogger, FB::Application.logger',
					'run FB::Application'
				)
			end
		end

		describe 'config/config.rb' do
			it do
				is_expected.to match_words(
					'FB::Application.config.instance_exec do',
					'FB::ConfigProcessors.const_get(processor_name).new self'
				)
			end
		end

		describe 'config/processors/logger.rb' do
			it do
				is_expected.to match_words(
					'module FooBar'
				)
			end
		end

		describe 'config/processors/sequel.rb.bak' do
			it do
				is_expected.to match_words(
					'module FooBar',
					'FB::Application.db_connection.extension extension_name',
					'FB::Application.db_connection.loggers << FB::Application.logger',
					"FB::Application.db_connection.freeze unless ENV['RACK_CONSOLE']"
				)
			end
		end

		describe 'constants.rb' do
			it do
				is_expected.to match_words(
					'module FooBar',
					'::FB = ::FooBar',
					'APP_DIRS ='
				)
			end
		end

		describe 'controllers/_controller.rb' do
			it do
				is_expected.to match_words(
					'module FooBar',
					'FB::Application.logger'
				)
			end
		end

		describe 'controllers/site/_controller.rb' do
			it do
				is_expected.to match_words(
					'module FooBar',
					'class Controller < FB::Controller'
				)
			end
		end

		describe 'controllers/site/index_controller.rb' do
			it do
				is_expected.to match_words(
					'module FooBar',
					'class IndexController < FB::Site::Controller'
				)
			end
		end

		describe 'README.md' do
			it do
				is_expected.to match_words(
					'# FooBar',
					'`createuser -U postgres foo_bar`',
					'`createdb -U postgres foo_bar -O foo_bar`',
					'`psql -U postgres -c "CREATE EXTENSION citext" foo_bar`',
					'Add UNIX-user for project: `adduser foo_bar`',
					'Make symbolic link of project directory to `/var/www/foo_bar`'
				)
			end
		end

		describe 'rollup.config.js' do
			it do
				is_expected.to match_words(
					"name: 'FB'"
				)
			end
		end

		describe 'rollup.config.js' do
			it do
				is_expected.to match_words(
					"name: 'FB'"
				)
			end
		end

		describe 'routes.rb' do
			it do
				is_expected.to match_words(
					'FB::Application.class_exec do'
				)
			end
		end

		describe 'views/site/layout.html.erb' do
			it do
				is_expected.to match_words(
					'<title><%= FB::Application.config[:site][:site_name] %></title>'
				)
			end
		end
	end

	describe 'generates RuboCop-satisfying app' do
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

		subject do
			Bundler.with_original_env do
				system 'bundle exec rubocop'
			end
		end

		it { is_expected.to be true }
	end

	describe 'generates working app' do
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

		let(:port) do
			## https://stackoverflow.com/a/5985984/2630849
			socket = Socket.new(:INET, :STREAM, 0)
			socket.bind Addrinfo.tcp('127.0.0.1', 0)
			result = socket.local_address.ip_port
			socket.close
			result
		end

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

		after do
			Dir.chdir '..'
		end

		it do
			is_expected.to eq <<~RESPONSE
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
	end

	describe 'grants `./server` file execution permissions' do
		before do
			execute_command

			Dir.chdir app_name
		end

		after do
			Dir.chdir '..'
		end

		subject { File.stat('server').mode.to_s(8)[3..5] }

		it { is_expected.to eq '744' }
	end
end
