# frozen_string_literal: true

require_relative 'process_files/render_variables'

module Flame
	class CLI < Clamp::Command
		class New < Clamp::Command
			## Class for Flame Application
			class App < ProjectGenerator::Command
				## Private instance methods for processing template files (copying, renaming, rendering)
				module ProcessFiles
					RENAME_FILES_PLACEHOLDERS = {
						name: 'app_name',
						path: 'app_path'
					}.freeze

					private

					def initialize_render_variables
						self.class::RenderVariables.new name, project_name, domain, indentation
					end
				end
			end
		end
	end
end
