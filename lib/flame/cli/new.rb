# frozen_string_literal: true

require_relative 'new/app'

module Flame
	class CLI < Clamp::Command
		## Command for generating new entities
		class New < Clamp::Command
			subcommand %w[application app], 'Generate new application directory',
				Flame::CLI::New::App
		end
	end
end
