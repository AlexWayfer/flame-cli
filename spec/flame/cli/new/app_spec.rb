# frozen_string_literal: true

require 'pathname'
require 'net/http'

require 'example_file'

describe 'Flame::CLI::New::App' do
	subject(:execute_command) do
		`#{FLAME_CLI} new app #{options} #{app_name}`
	end

	let(:app_name) { 'foo_bar' }
	let(:options) { nil }

	let(:root_dir) { "#{__dir__}/../../../.." }
	let(:template_dir) { "#{root_dir}/template" }
	let(:template_dir_pathname) { Pathname.new(template_dir) }
	let(:template_ext) { '.erb' }
	let(:temp_app_dir) { "#{root_dir}/#{app_name}" }

	after do
		FileUtils.rm_r temp_app_dir
	end

	describe 'output' do
		let(:expected_output_start) do
			<<~OUTPUT
				Copying files...
				Renaming files...
				Rendering files...
				Clean directories...
				Installing dependencies...
			OUTPUT
		end

		let(:expected_output_end) do
			<<~OUTPUT
				Done.
				To checkout into a new directory:
					cd foo_bar
			OUTPUT
		end

		it { is_expected.to start_with(expected_output_start).and end_with(expected_output_end) }
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
		def read_app_file(name)
			File.read File.join(app_name, name)
		end

		before { execute_command }

		shared_examples 'include and match lines' do
			specify do
				expected_included_lines.each do |file_name, expected_lines|
					expect(read_app_file(file_name)).to include_lines expected_lines
				end

				expected_matched_lines.each do |file_name, expected_lines|
					expect(read_app_file(file_name)).to match_lines expected_lines
				end
			end
		end

		describe 'default behavior' do
			let(:expected_included_lines) do
				{
					'.toys/.toys.rb' =>
						[
							'FB::Application',
							'expand FlameGenerateToys::Template, namespace: FooBar'
						],

					'application.rb' =>
						[
							'module FooBar'
						],

					'config.ru' =>
						[
							'FB::Application.setup',
							'if FB::Application.config[:session]',
							'use Rack::Session::Cookie, FB::Application.config[:session][:cookie]',
							'use Rack::CommonLogger, FB::Application.logger',
							'FB::App = FB::Application',
							'run FB::Application'
						],

					'config/main.rb' =>
						[
							'config = FB::Application.config',
							'FB::Config::Processors.const_get(processor_name).new self'
						],

					'config/puma.rb' =>
						[
							'config = FB::Application.config'
						],

					'config/database.example.yaml' =>
						[
							":database: 'foo_bar'",
							":user: 'foo_bar'"
						],

					'config/mail.example.yaml' =>
						[
							":name: 'FooBar.com'",
							":email: 'info@foobar.com'",
							":user_name: 'info@foobar.com'"
						],

					'config/sentry.example.yaml' =>
						[
							':host: sentry.foobar.com'
						],

					'config/server.example.yaml' =>
						[
							":unix: '/run/foo_bar/puma.sock'"
						],

					'config/processors/mail.rb' =>
						[
							'module FooBar'
						],

					'config/processors/r18n.rb' =>
						[
							'module FooBar'
						],

					'config/processors/sentry.rb' =>
						[
							'module FooBar',
							'FB::APP_DIRS'
						],

					'config/processors/server.rb' =>
						[
							'module FooBar'
						],

					'config/processors/sequel.rb' =>
						[
							'module FooBar'
						],

					'config/processors/shrine.rb' =>
						[
							'module FooBar'
						],

					'constants.rb' =>
						[
							'module FooBar',
							'::FB = self'
						],

					'controllers/_controller.rb' =>
						[
							'module FooBar',
							'FB::Application.logger'
						],

					'controllers/site/_controller.rb' =>
						[
							'module FooBar',
							'class Controller < FB::Controller'
						],

					'controllers/site/index_controller.rb' =>
						[
							'module FooBar'
						],

					'forms/_base.rb' =>
						[
							'module FooBar',
							'FB::Application.db_connection'
						],

					'mailers/_base.rb' =>
						[
							'module FooBar',
							'@from = FB::Application.config[:mail][:from]',
							'@controller = FB::MailController.new',
							## https://github.com/rubocop-hq/rubocop/issues/8416
							# rubocop:disable Lint/InterpolationCheck
							'FB::Application.logger.info "#{mail.log_message} [#{index}/#{count}]..."',
							'File.join(FB::Application.config[:tmp_dir], "mailing_#{object_id}")'
							# rubocop:enable Lint/InterpolationCheck
						],

					'mailers/mail/_base.rb' =>
						[
							'module FooBar',
							'FB::Application.logger.error e'
						],

					'mailers/mail/default.rb' =>
						[
							'module FooBar'
						],

					'views/site/errors/400.html.erb' =>
						[
							'<h1><%= t.error.bad_request.title %></h1>',
							'<h4><%= t.error.bad_request.subtitle %></h4>',
							'<%= t.error.bad_request.text %>',
							'<a href="<%= path_to_back %>">',
							'<%= t.button.back %>'
						],

					'views/site/errors/404.html.erb' =>
						[
							'<h1><%= t.error.page.itself.not_found %></h1>',
							'<a href="<%= path_to FB::Site::IndexController %>">',
							'<%= t.button.home %>'
						],

					'views/site/errors/500.html.erb' =>
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
						],

					## https://github.com/rubocop-hq/rubocop/issues/8416
					# rubocop:disable Lint/InterpolationCheck
					'views/site/layout.html.erb' =>
						[
							'<title><%= config[:site][:site_name] %></title>',
							'<link rel="stylesheet" href="<%= url_to "styles/#{name}.css", version: true %>" />',
							'<%',
							<<~LINE.chomp,
								if Sentry.configuration.enabled_environments.include?(config[:environment]) && !request.bot?
							LINE
							'%>',
							"environment: '<%= config[:environment] %>',",
							"release: '<%= Sentry.configuration.release %>',",
							<<~LINE,
								type="text/javascript" src="<%= url_to "/scripts/\#{dir}/\#{name}.js", version: true %>"
							LINE
							'<a href="<%= path_to FB::Site::IndexController %>">',
							'<h1><%= config[:site][:site_name] %></h1>'
						]
					# rubocop:enable Lint/InterpolationCheck
				}
			end

			let(:expected_matched_lines) do
				{
					'README.md' =>
						[
							'# FooBar',
							'`createuser -U postgres foo_bar`',
							'Run `exe/setup.sh`',
							'Add UNIX-user for project: `adduser foo_bar`'
						]
				}
			end

			include_examples 'include and match lines'
		end

		describe 'with `--domain` option' do
			let(:options) { '--domain=foobar.net' }

			let(:expected_included_lines) do
				{
					'config/mail.example.yaml' =>
						[
							":name: 'FooBar.net'",
							":email: 'info@foobar.net'",
							":user_name: 'info@foobar.net'"
						],

					'config/sentry.example.yaml' =>
						[
							':host: sentry.foobar.net'
						]
				}
			end

			let(:expected_matched_lines) do
				{}
			end

			include_examples 'include and match lines'
		end

		describe 'with `--project-name` option' do
			let(:app_name) { 'foobar' }
			let(:options) { '--project-name=FooBar' }

			let(:expected_included_lines) do
				{
					'.toys/.toys.rb' =>
						[
							'FB::Application',
							'expand FlameGenerateToys::Template, namespace: FooBar'
						],

					'application.rb' =>
						[
							'module FooBar'
						],

					'config.ru' =>
						[
							'FB::Application.setup',
							'if FB::Application.config[:session]',
							'use Rack::Session::Cookie, FB::Application.config[:session][:cookie]',
							'use Rack::CommonLogger, FB::Application.logger',
							'FB::App = FB::Application',
							'run FB::Application'
						],

					'config/main.rb' =>
						[
							'config = FB::Application.config',
							'FB::Config::Processors.const_get(processor_name).new self'
						],

					'config/puma.rb' =>
						[
							'config = FB::Application.config'
						],

					'config/database.example.yaml' =>
						[
							":database: 'foobar'",
							":user: 'foobar'"
						],

					'config/mail.example.yaml' =>
						[
							":name: 'FooBar.com'",
							":email: 'info@foobar.com'",
							":user_name: 'info@foobar.com'"
						],

					'config/sentry.example.yaml' =>
						[
							':host: sentry.foobar.com'
						],

					'config/server.example.yaml' =>
						[
							":unix: '/run/foobar/puma.sock'"
						],

					'config/processors/mail.rb' =>
						[
							'module FooBar'
						],

					'config/processors/r18n.rb' =>
						[
							'module FooBar'
						],

					'config/processors/sentry.rb' =>
						[
							'module FooBar',
							'FB::APP_DIRS'
						],

					'config/processors/server.rb' =>
						[
							'module FooBar'
						],

					'config/processors/sequel.rb' =>
						[
							'module FooBar'
						],

					'config/processors/shrine.rb' =>
						[
							'module FooBar'
						],

					'constants.rb' =>
						[
							'module FooBar',
							'::FB = self'
						],

					'controllers/_controller.rb' =>
						[
							'module FooBar',
							'FB::Application.logger'
						],

					'controllers/site/_controller.rb' =>
						[
							'module FooBar',
							'class Controller < FB::Controller'
						],

					'controllers/site/index_controller.rb' =>
						[
							'module FooBar'
						],

					'forms/_base.rb' =>
						[
							'module FooBar',
							'FB::Application.db_connection'
						],

					'mailers/_base.rb' =>
						[
							'module FooBar',
							'@from = FB::Application.config[:mail][:from]',
							'@controller = FB::MailController.new',
							## https://github.com/rubocop-hq/rubocop/issues/8416
							# rubocop:disable Lint/InterpolationCheck
							'FB::Application.logger.info "#{mail.log_message} [#{index}/#{count}]..."',
							'File.join(FB::Application.config[:tmp_dir], "mailing_#{object_id}")'
							# rubocop:enable Lint/InterpolationCheck
						],

					'mailers/mail/_base.rb' =>
						[
							'module FooBar',
							'FB::Application.logger.error e'
						],

					'mailers/mail/default.rb' =>
						[
							'module FooBar'
						],

					'views/site/errors/404.html.erb' =>
						[
							'<a href="<%= path_to FB::Site::IndexController %>">'
						],

					'views/site/layout.html.erb' =>
						[
							'<a href="<%= path_to FB::Site::IndexController %>">'
						]
				}
			end

			let(:expected_matched_lines) do
				{
					'README.md' =>
						[
							'# FooBar',
							'`createuser -U postgres foobar`',
							'Run `exe/setup.sh`',
							'Add UNIX-user for project: `adduser foobar`',
							'Make symbolic link of project directory to `/var/www/foobar`'
						]
				}
			end

			include_examples 'include and match lines'
		end
	end

	describe 'generation' do
		let(:port) do
			## https://stackoverflow.com/a/5985984/2630849
			socket = Socket.new(:INET, :STREAM, 0)
			socket.bind Addrinfo.tcp('127.0.0.1', 0)
			result = socket.local_address.ip_port
			socket.close
			result
		end

		before do
			execute_command

			Dir.chdir app_name

			Bundler.with_unbundled_env do
				## HACK: https://github.com/dazuma/toys/issues/57
				toys_command = 'truncate_load_path!'
				temp_app_toys_file_path = "#{temp_app_dir}/.toys/.toys.rb"
				File.write(
					temp_app_toys_file_path,
					File.read(temp_app_toys_file_path).sub("# #{toys_command}", toys_command)
				)

				Dir['config/**/*.example.{yaml,conf,service}'].each do |config_example_file_name|
					FileUtils.cp(
						config_example_file_name, config_example_file_name.sub(ExampleFile::SUFFIX, '')
					)
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

		describe 'linting and testing' do
			let(:commands) do
				[
					'bundle exec rubocop',
					'pnpm lint',
					'bundle audit check --update',
					'bundle exec rspec'
				]
			end

			specify do
				Bundler.with_unbundled_env do
					commands.each do |command|
						expect(system(command)).to be true
					end
				end
			end
		end

		describe 'working app' do
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
						retry if number_of_attempts < 30
						raise e
					end

					response
				ensure
					Bundler.with_unbundled_env { `toys server stop` }
					begin
						Process.wait pid
					rescue Errno::ECHILD
						## process already stopped
					end
				end
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
end
