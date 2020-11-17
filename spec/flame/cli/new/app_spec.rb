# frozen_string_literal: true

require 'pathname'
require 'net/http'

describe 'Flame::CLI::New::App' do
	subject(:execute_command) do
		`#{FLAME_CLI} new app #{app_name}`
	end

	let(:app_name) { 'foo_bar' }

	let(:root_dir) { "#{__dir__}/../../../.." }
	let(:template_dir) { "#{root_dir}/template" }
	let(:template_dir_pathname) { Pathname.new(template_dir) }
	let(:template_ext) { '.erb' }
	let(:temp_app_dir) { "#{root_dir}/#{app_name}" }

	after do
		FileUtils.rm_r temp_app_dir
	end

	describe 'output' do
		let(:expected_words) do
			[
				"Creating '#{app_name}' directory...",
				'Copy template directories and files...',
				'Clean directories...',
				'Replace module names in template...',
				'- .toys/.toys.rb',
				'- README.md',
				'- application.rb',
				'- config.ru',
				'- config/database.example.yaml',
				'- config/mail.example.yaml',
				'- config/main.rb',
				'- config/processors/mail.rb',
				'- config/processors/r18n.rb',
				'- config/processors/sentry.rb',
				'- config/processors/server.rb',
				'- config/processors/sequel.rb',
				'- config/processors/shrine.rb',
				'- config/puma.rb',
				'- config/sentry.example.yaml',
				'- config/site.example.yaml',
				'- constants.rb',
				'- controllers/_controller.rb',
				'- controllers/site/_controller.rb',
				'- controllers/site/index_controller.rb',
				'- forms/_base.rb',
				'- mailers/_base.rb',
				'- mailers/mail/_base.rb',
				'- mailers/mail/default.rb',
				'- rollup.config.js',
				'- views/site/errors/400.html.erb',
				'- views/site/errors/404.html.erb',
				'- views/site/errors/500.html.erb',
				'- views/site/index.html.erb',
				'- views/site/layout.html.erb',
				# 'Grant permissions to files...',
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
		subject { Dir.glob("#{temp_app_dir}/**/.keep", File::FNM_DOTMATCH) }

		before { execute_command }

		it { is_expected.to be_empty }
	end

	describe 'renders app name in files' do
		subject { File.read File.join(app_name, *path_parts) }

		let(:path_parts) { self.class.description.split('/') }

		before { execute_command }

		describe '.toys/.toys.rb' do
			let(:expected_words) do
				[
					'FB::Application',
					'expand FlameGenerateToys::Template, namespace: FooBar'
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
					'FB::Application.setup',
					'if FB::Application.config[:session]',
					'use Rack::Session::Cookie, FB::Application.config[:session][:cookie]',
					'use Rack::CommonLogger, FB::Application.logger',
					'FB::App = FB::Application',
					'run FB::Application'
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'config/main.rb' do
			let(:expected_words) do
				[
					'config = FB::Application.config',
					'FB::Config::Processors.const_get(processor_name).new self'
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'config/puma.rb' do
			let(:expected_words) do
				[
					'config = FB::Application.config'
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'config/database.example.yaml' do
			let(:expected_words) do
				[
					":database: 'foo_bar'",
					":user: 'foo_bar'"
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'config/mail.example.yaml' do
			let(:expected_words) do
				[
					":name: 'FooBar.com'",
					":email: 'info@foobar.com'",
					":user_name: 'info@foobar.com'"
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'config/sentry.example.yaml' do
			let(:expected_words) do
				[
					':host: sentry.foobar.com'
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'config/server.example.yaml' do
			let(:expected_words) do
				[
					":unix: '/run/foo_bar/puma.sock'"
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'config/processors/mail.rb' do
			let(:expected_words) do
				[
					'module FooBar'
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'config/processors/r18n.rb' do
			let(:expected_words) do
				[
					'module FooBar'
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'config/processors/sentry.rb' do
			let(:expected_words) do
				[
					'module FooBar',
					'FB::APP_DIRS'
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'config/processors/server.rb' do
			let(:expected_words) do
				[
					'module FooBar'
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'config/processors/sequel.rb' do
			let(:expected_words) do
				[
					'module FooBar'
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'config/processors/shrine.rb' do
			let(:expected_words) do
				[
					'module FooBar'
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'constants.rb' do
			let(:expected_words) do
				[
					'module FooBar',
					'::FB = self'
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
					'module FooBar'
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'README.md' do
			let(:expected_words) do
				[
					'# FooBar',
					'`createuser -U postgres foo_bar`',
					'Run `exe/setup.sh`',
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

		describe 'forms/_base.rb' do
			let(:expected_words) do
				[
					'module FooBar',
					'FB::Application.db_connection'
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'mailers/_base.rb' do
			let(:expected_words) do
				[
					'module FooBar',
					'@from = FB::Application.config[:mail][:from]',
					'@controller = FB::MailController.new',
					## https://github.com/rubocop-hq/rubocop/issues/8416
					# rubocop:disable Lint/InterpolationCheck
					'FB::Application.logger.info "#{mail.log_message} [#{index}/#{count}]..."',
					'File.join(FB::Application.config[:tmp_dir], "mailing_#{object_id}")'
					# rubocop:enable Lint/InterpolationCheck
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'mailers/mail/_base.rb' do
			let(:expected_words) do
				[
					'module FooBar',
					'FB::Application.logger.error e'
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'mailers/mail/default.rb' do
			let(:expected_words) do
				[
					'module FooBar'
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'views/site/errors/400.html.erb' do
			let(:expected_words) do
				[
					'<h1><%= t.error.bad_request.title %></h1>',
					'<h4><%= t.error.bad_request.subtitle %></h4>',
					'<%= t.error.bad_request.text %>',
					'<a href="<%= path_to_back %>">',
					'<%= t.button.back %>'
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'views/site/errors/404.html.erb' do
			let(:expected_words) do
				[
					'<h1><%= t.error.page.itself.not_found %></h1>',
					'<a href="<%= path_to FB::Site::IndexController %>">',
					'<%= t.button.home %>'
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'views/site/errors/500.html.erb' do
			let(:expected_words) do
				[
					'<div class="page error <%= config[:environment] %>">',
					'<h1><%= t.error.unexpected_error.title %></h1>',
					'<h4><%= t.error.unexpected_error.subtitle %></h4>',
					'<%= t.error.unexpected_error.text %>',
					"<% if config[:environment] == 'development' %>",
					'<pre><h3><b><%==',
					'%></b></h3><%',
					'%><h4 class="sql"><%=',
					'%></h4><% end %><%=',
					'%></pre>',
					'<% end %>',
					'<a href="<%= path_to_back %>">',
					'<%= t.button.back %>'
				]
			end

			it { is_expected.to match_words(*expected_words) }
		end

		describe 'views/site/layout.html.erb' do
			let(:expected_words) do
				## https://github.com/rubocop-hq/rubocop/issues/8416
				# rubocop:disable Lint/InterpolationCheck
				[
					'<title><%= config[:site][:site_name] %></title>',
					'<link rel="stylesheet" href="<%= url_to "styles/#{name}.css", version: true %>" />',
					'<% if Raven.configuration.environments.include?(config[:environment]) &&',
					"environment: '<%= config[:environment] %>',",
					'src="<%= url_to "/scripts/#{dir}/#{name}.js", version: true %>"',
					'<a href="<%= path_to FB::Site::IndexController %>">',
					'<h1><%= config[:site][:site_name] %></h1>'
				]
				# rubocop:enable Lint/InterpolationCheck
			end

			it { is_expected.to match_words(*expected_words) }
		end
	end

	describe 'generates RuboCop-satisfying app' do
		subject do
			system 'bundle exec rubocop'
		end

		before do
			execute_command

			Dir.chdir app_name

			Bundler.with_unbundled_env do
				system 'exe/setup/ruby.sh'
			end
		end

		after do
			Dir.chdir '..'
		end

		it { is_expected.to be true }
	end

	describe 'generates assets linting satisfying app' do
		subject do
			system 'pnpm lint'
		end

		before do
			execute_command

			Dir.chdir app_name

			system 'exe/setup/node.sh'
		end

		after do
			Dir.chdir '..'
		end

		it { is_expected.to be true }
	end

	describe 'generates Bundler Audit satisfying app' do
		subject do
			system 'bundle audit check --update'
		end

		before do
			execute_command

			Dir.chdir app_name

			Bundler.with_unbundled_env do
				system 'exe/setup/ruby.sh'
			end
		end

		after do
			Dir.chdir '..'
		end

		it { is_expected.to be true }
	end

	describe 'generates working app' do
		subject do
			Bundler.with_unbundled_env do
				pid = spawn 'toys server start'

				Process.detach pid

				sleep 0.1

				number_of_attempts = 0

				begin
					number_of_attempts += 1
					## https://github.com/gruntjs/grunt-contrib-connect/issues/25#issuecomment-16293494
					response = Net::HTTP.get URI("http://127.0.0.1:#{port}/")
				rescue Errno::ECONNREFUSED => e
					sleep 1
					retry if number_of_attempts < 20
					raise e
				end

				response
			ensure
				Bundler.with_unbundled_env { `toys server stop` }
				Process.wait pid
			end
		end

		before do
			Bundler.with_unbundled_env do
				execute_command

				## HACK: https://github.com/dazuma/toys/issues/57
				toys_command = 'truncate_load_path!'
				temp_app_toys_file_path = "#{temp_app_dir}/.toys/.toys.rb"
				File.write(
					temp_app_toys_file_path,
					File.read(temp_app_toys_file_path).sub("# #{toys_command}", toys_command)
				)

				Dir.chdir app_name

				Dir['config/**/*.example.{yaml,conf}'].each do |config_example_file_name|
					FileUtils.cp config_example_file_name, config_example_file_name.sub('.example', '')
				end

				## HACK for testing while some server is running
				File.write(
					'config/server.yaml',
					File.read('config/server.yaml').sub('port: 3000', "port: #{port}")
				)

				system 'exe/setup.sh'
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

		let(:expected_response_lines) do
			[
				'<title>FooBar</title>',
				'<h1>Hello, world!</h1>'
			]
		end

		it { is_expected.to include(*expected_response_lines) }
	end
end
