# frozen_string_literal: true

module Flame
	class CLI < Clamp::Command
		class New < Clamp::Command
			## Class for Flame Application
			class App < Clamp::Command
				using GorillaPatch::Inflections

				parameter 'APP_NAME', 'application name'

				def execute
					initialize_instance_variables

					make_dir do
						copy_template
						grant_permissions
					end

					puts 'Done!'
					system "cd #{@app_name}"
				end

				private

				def initialize_instance_variables
					@app_name = app_name

					@module_name = @app_name.camelize

					@short_module_name =
						@module_name.split(/([[:upper:]][[:lower:]]*)/).map! { |s| s[0] }.join

					@domain_name = @module_name.downcase
				end

				def make_dir(&block)
					puts "Creating '#{@app_name}' directory..."
					FileUtils.mkdir @app_name
					FileUtils.cd @app_name, &block
				end

				def copy_template
					puts 'Copy template directories and files...'
					FileUtils.cp_r File.join(__dir__, '../../../../template/.'), '.'
					clean_dirs
					render_templates
				end

				def clean_dirs
					puts 'Clean directories...'
					FileUtils.rm Dir.glob('**/.keep', File::FNM_DOTMATCH)
				end

				def render_templates
					puts 'Replace module names in template...'
					Dir.glob('**/*.erb', File::FNM_DOTMATCH).sort.each do |file|
						file_pathname = Pathname.new(file)
						basename_pathname = file_pathname.sub_ext('')
						puts "- #{basename_pathname}"
						content = ERB.new(File.read(file)).result(binding)
						File.write(basename_pathname, content)
						FileUtils.rm file
					end
				end

				PERMISSIONS = {}.freeze

				def grant_permissions
					return unless PERMISSIONS.any?

					puts 'Grant permissions to files...'
					PERMISSIONS.each { |file, permissions| File.chmod permissions, file }
				end
			end
		end
	end
end
