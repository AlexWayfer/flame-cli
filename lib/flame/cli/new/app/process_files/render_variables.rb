# frozen_string_literal: true

require 'gorilla_patch/blank'

module Flame
	class CLI < Clamp::Command
		class New < Clamp::Command
			## Class for Flame Application
			class App < ProjectGenerator::Command
				## Private instance methods for processing template files (copying, renaming, rendering)
				module ProcessFiles
					## Class for a single object which should be a scope in render
					class RenderVariables < ProjectGenerator::Command::ProcessFiles::RenderVariables
						using GorillaPatch::Inflections

						attr_reader :module_name, :domain_name

						alias app_name name

						def initialize(name, project_name, domain, indentation)
							super(name, indentation)

							@module_name = project_name || app_name.camelize

							@domain_name = domain || "#{@module_name.downcase}.com"
						end

						memoize def short_module_name
							module_name.split(/([[:upper:]][[:lower:]]*)/).map! { |s| s[0] }.join
						end
					end
				end
			end
		end
	end
end
