# frozen_string_literal: true

require 'date'
require 'securerandom'

require 'project_generator'

require_relative 'app/process_files'

module Flame
	class CLI < Clamp::Command
		class New < Clamp::Command
			## Class for Flame Application
			class App < ProjectGenerator::Command
				include ProcessFiles

				attr_accessor :template

				parameter 'APP_NAME', 'application name', attribute_name: :name

				option ['-d', '--domain'], 'NAME', 'domain name for configuration'
				option ['-p', '--project-name'], 'NAME', 'project name for code and configuration'

				def execute
					check_target_directory

					self.template = "#{__dir__}/../../../../template"

					refine_template_parameter if git?

					process_files

					clean_dirs

					initialize_git

					setup_project

					FileUtils.rm_r @git_tmp_dir if git?

					done
				end

				private

				def clean_dirs
					puts 'Clean directories...'
					FileUtils.rm Dir.glob('**/.keep', File::FNM_DOTMATCH)
				end

				def setup_project
					puts 'Setup project...'

					Dir.chdir name do
						system 'exe/setup.sh'
					end
				end
			end
		end
	end
end
